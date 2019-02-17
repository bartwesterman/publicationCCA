classdef Importer < handle
    %IMPORTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        DROPBOX_ROOT  = '~/Dropbox/VU AAA Chemogenomics/';
        DATA_ROOT     = [data.Importer.DROPBOX_ROOT '2 Data/'];
        RAW_DATA_ROOT = [data.Importer.DATA_ROOT '1 Raw sources/'];
        INPUT_DATA_ROOT = [data.Importer.DATA_ROOT '2 Input files/'];
        DREAM_ROOT = [data.Importer.RAW_DATA_ROOT '3 Dream/'];
        DREAM_PHARMA_DATA = [data.Importer.DREAM_ROOT 'csv/'];
        
        DREAM_COMBINATIONS_PATH = [data.Importer.DREAM_PHARMA_DATA 'Raw_Data_csv/ch1_training_combinations/'];
        
        DREAM_MONO_AND_COMBINATION_TRAINING = [data.Importer.DREAM_PHARMA_DATA 'ch1_train_combination_and_monoTherapy.csv'];
        
        DREAM_MONO_TEST1 = [data.Importer.DREAM_PHARMA_DATA 'ch1_test_monoTherapy.csv'];
        DREAM_MONO_TEST2 = [data.Importer.DREAM_PHARMA_DATA 'ch2_test_monoTherapy.csv'];
        
        DREAM_MONO_LEADER1 = [data.Importer.DREAM_PHARMA_DATA 'ch1_leaderBoard_monoTherapy_no_double_eol.csv'];        
        DREAM_MONO_LEADER2 = [data.Importer.DREAM_PHARMA_DATA 'ch2_leaderBoard_monoTherapy.csv'];

        DREAM_DRUG_INFO = [data.Importer.DREAM_PHARMA_DATA 'Drug_info_release.csv'];

        THESAURI_PATH = 'resources/thesauri/';
        
        DATABASE_FILEPATH = 'resources/databases/database.db';
        
    end
    
    properties
        drugThesaurus;
        cellLineThesaurus;
        tissueThesaurus;
        cancerTypeThesaurus;
        geneThesaurus;
        
        synergyThesaurus;
        checkedThesaurus;
       
        % reader;
    end
    
    methods
        
        function obj = init(obj)
            obj.reconstructDatabase();
        end
        
        function reconstructDatabase(obj)
            % make sure the database is really closed
            for i= 1:200
                sqlite3.close()
            end
            delete(data.Importer.DATABASE_FILEPATH);
            sqlite3.open(data.Importer.DATABASE_FILEPATH);
            
            obj.initThesauri();
            
            obj.processDream();            
        end
        
        function initThesauri(obj)
            import data.Thesaurus;
            disp('Importing Thesauri');

            path = data.Importer.THESAURI_PATH;
            obj.geneThesaurus       = Thesaurus().init('gene',       [path 'gene.ths']);
            obj.drugThesaurus       = Thesaurus().init('drug',       [path 'drug.ths']);
            obj.cellLineThesaurus   = Thesaurus().init('cellLine',   [path 'cellLine.ths']);
            obj.tissueThesaurus     = Thesaurus().init('tissue',     [path 'tissue.ths']);
            obj.cancerTypeThesaurus = Thesaurus().init('cancerType', [path 'cancerType.ths']);
            
            obj.synergyThesaurus = Thesaurus().init('synergy', [path 'synergy.ths']);
            obj.checkedThesaurus = Thesaurus().init('checked', [path 'checked.ths']);
            
            
            obj.geneThesaurus.completeConstruction();
            obj.drugThesaurus.completeConstruction();
            obj.cellLineThesaurus.completeConstruction();
            obj.tissueThesaurus.completeConstruction();
            obj.cancerTypeThesaurus.completeConstruction();
            
            obj.synergyThesaurus.completeConstruction();
            obj.checkedThesaurus.completeConstruction();
            disp('Thesauri imported');
            
        end
        
        function initLinkThesauri(obj)
            import data.Thesaurus;
            
            sqlite3.open(data.Importer.DATABASE_FILEPATH);
            
            path = data.Importer.THESAURI_PATH;
            obj.geneThesaurus       = Thesaurus().initLink('gene');
            obj.drugThesaurus       = Thesaurus().initLink('drug');
            obj.cellLineThesaurus   = Thesaurus().initLink('cellLine');
            obj.tissueThesaurus     = Thesaurus().initLink('tissue');
            obj.cancerTypeThesaurus = Thesaurus().initLink('cancerType');
            
            obj.synergyThesaurus = Thesaurus().initLink('synergy');
            obj.checkedThesaurus = Thesaurus().initLink('checked');
        end
        
        function saveUnknownSynonyms(obj)
            obj.geneThesaurus.saveUnknownSynonyms();
            obj.drugThesaurus.saveUnknownSynonyms();
            obj.cellLineThesaurus.saveUnknownSynonyms();
            obj.tissueThesaurus.saveUnknownSynonyms();
            obj.cancerTypeThesaurus.saveUnknownSynonyms();
            obj.synergyThesaurus.saveUnknownSynonyms();
        end
        
        function processDream(obj)
            disp('Importing Dream');

            obj.processDreamSynergyFile();
            obj.processDreamCombinationFiles();

            disp('Imported combination data');
            
            obj.processDreamMonoFile([data.Importer.DREAM_MONO_TEST1], 'DreamMonoTest1');
            obj.processDreamMonoFile([data.Importer.DREAM_MONO_LEADER1], 'DreamMonoLeader1');
            
            disp('Imported mono files challenge 1');
     
            obj.processDreamMonoFile([data.Importer.DREAM_MONO_TEST2], 'DreamMonoTest2');
            obj.processDreamMonoFile([data.Importer.DREAM_MONO_LEADER2], 'DreamMonoLeader2');
            
            disp('Dream imported');
        end
        
        function processDreamDrugInfoFile(obj)
            table = data.DataTable().init('DreamDrugInfo', {
                struct('name', 'ChallengeName',         'type', obj.drugThesaurus);
                struct('name', 'target',                'type', 'TEXT(100)'); % @TODO; this smells like drama
                struct('name', 'hba',                   'type', 'REAL');
                struct('name', 'cLogP',                 'type', 'REAL');
                struct('name', 'hbd',                   'type', 'REAL');                                
                struct('name', 'Lipinski',          'type', 'REAL');
                struct('name', 'SMILESOrPubChemID',  'type', 'TEXT(100)');
                struct('name', 'MW',                    'type', 'REAL');
            });
        
            rows = data.csvread(data.Importer.DREAM_DRUG_INFO);

            table.save(rows(2:end, :));
            disp('Imported dream drug info');
            
        end
        
        function processDreamMonoFile(obj, filePath, tableName)
            
            table = data.DataTable().init(tableName, {
                struct('name', 'cellLine',            'type', obj.cellLineThesaurus);
                struct('name', 'drugA',               'type', obj.drugThesaurus);
                struct('name', 'drugB',               'type', obj.drugThesaurus);
                struct('name', 'MAX_CONC_A',          'type', 'REAL');
                struct('name', 'MAX_CONC_B',          'type', 'REAL');
                struct('name', 'IC50_A',              'type', 'REAL');
                struct('name', 'H_A',                 'type', 'REAL');
                struct('name', 'Einf_A',              'type', 'REAL');
                struct('name', 'IC50_B',              'type', 'REAL');
                struct('name', 'H_B',                 'type', 'REAL');
                struct('name', 'Einf_B',              'type', 'REAL');
                struct('name', 'QA',                  'type', 'INTEGER');
                struct('name', 'COMBINATION_ID',      'type', 'TEXT(100)');
                
            });
        
            rows = data.csvread(filePath);
            rows = [rows(:,1:11) rows(:,13:14)]; %no synergy data

            table.save(rows(2:end, :));
            disp('Imported mono file');
            
        end
        
        function processDreamSynergyFile(obj)
            rows = data.csvread(data.Importer.DREAM_MONO_AND_COMBINATION_TRAINING);
            
            dreamSynergyTable = data.DataTable().init('dreamSynergies', {
                struct('name', 'cellLine',            'type', obj.cellLineThesaurus);
                struct('name', 'drugA',               'type', obj.drugThesaurus);
                struct('name', 'drugB',               'type', obj.drugThesaurus);
                struct('name', 'MAX_CONC_A',          'type', 'REAL');
                struct('name', 'MAX_CONC_B',          'type', 'REAL');
                struct('name', 'IC50_A',              'type', 'REAL');
                struct('name', 'H_A',                 'type', 'REAL');
                struct('name', 'Einf_A',              'type', 'REAL');
                struct('name', 'IC50_B',              'type', 'REAL');
                struct('name', 'H_B',                 'type', 'REAL');
                struct('name', 'Einf_B',              'type', 'REAL');
                struct('name', 'SYNERGY_SCORE',       'type', 'REAL');
                struct('name', 'QA',                  'type', 'INTEGER');
                struct('name', 'COMBINATION_ID',      'type', 'TEXT(100)');
                
            });
        
            dreamSynergyTable.save(rows(2:end, :));
            disp('Imported dream synergy file');
            
        end
        
        
        function processDreamCombinationFiles(obj)

            dreamSynergyTable = data.DataTable().init('dreamCombinationFileSynergies', {
                struct('name', 'cellLine',            'type', obj.cellLineThesaurus);
                struct('name', 'drugA',               'type', obj.drugThesaurus);
                struct('name', 'drugB',               'type', obj.drugThesaurus);
                struct('name', 'maxSynergyDoseA',     'type', 'REAL');
                struct('name', 'maxSynergyDoseB',     'type', 'REAL');
                struct('name', 'unitDrugA',           'type', 'TEXT(50)');
                struct('name', 'unitDrugB',           'type', 'TEXT(50)');
                struct('name', 'combinationIndex',    'type', 'REAL');
                struct('name', 'dosageLevelsACsv',    'type', 'TEXT(250)');
                struct('name', 'dosageLevelsBCsv',    'type', 'TEXT(250)');
                struct('name', 'drugCombinationMatrixCsv',    'type', 'TEXT(3000)')
            });            
            files = dir([data.Importer.DREAM_COMBINATIONS_PATH '/*.csv']);
            for i = 1:length(files)
                file = files(i);
                
                csvCellMatrix = data.csvread([data.Importer.DREAM_COMBINATIONS_PATH file.name]);
                
                drugA = csvCellMatrix{ 9, 2};
                drugB = csvCellMatrix{10, 2};
                
                unitDrugA = csvCellMatrix{11, 2};
                unitDrugB = csvCellMatrix{12, 2};
                
                cellLine = csvCellMatrix{13, 2};
                
                dosageLevelsA = csvCellMatrix(2:7, 1);
                dosageLevelsB = csvCellMatrix(1, 2:7)';
                
                drugCombinationCellMatrix = csvCellMatrix(2:7, 2:7);
                
                % convert to number matrix
                drugCombinationCellMatrix = cellfun(@str2num, drugCombinationCellMatrix);
                drugCombinationMatrix = zeros(size(drugCombinationCellMatrix));
                drugCombinationMatrix(:,:) = drugCombinationCellMatrix(:,:);
               
                [lowestCombinationIndex, lowestRow, lowestColumn] = obj.findLowestCombinationIndex(drugCombinationMatrix);
                
                maxSynergyDoseA = dosageLevelsA{lowestColumn};
                maxSynergyDoseB = dosageLevelsB{lowestRow};
                
                dosageLevelsACsv = data.csvstring(dosageLevelsA);
                dosageLevelsBCsv = data.csvstring(dosageLevelsB);
                drugCombinationMatrixCsv = data.csvstring(drugCombinationMatrix);
                
                row = {...
                    cellLine,...
                    drugA,...
                    drugB,...
                    maxSynergyDoseA,...
                    maxSynergyDoseB,...
                    unitDrugA,...
                    unitDrugB,...
                    lowestCombinationIndex,...
                    dosageLevelsACsv,...
                    dosageLevelsBCsv,...
                    drugCombinationMatrixCsv...
                };
                dreamSynergyTable.insertSemanticRow(row);
            end    
            disp('Imported dream combination files');
            
        end
        
        function [lowestCombinationIndex, lowestRow, lowestColumn] = findLowestCombinationIndex(obj, matrix)
            lowestCombinationIndex = Inf;
            lowestRow = Inf;
            lowestColumn = Inf;
            
            [rowCount, columnCount] = size(matrix);
            
            for row = 1:rowCount
                for column = 1:columnCount
                    combinationIndex = obj.computeCombinationIndex(matrix(row,1), matrix(1,column), matrix(row,column));
                    
                    if combinationIndex < lowestCombinationIndex
                        lowestCombinationIndex = combinationIndex;
                        lowestRow = row;
                        lowestColumn = column;
                    end
                end
            end
        end
        
        function combinationIndex = computeCombinationIndex(obj, lethalityA, lethalityB, lethalityAB)
            combinationIndex = ( 100/lethalityA + 100/lethalityB - 1) / (100/lethalityAB);
        end
        
        function results = normalizeResults(obj, results, normalizeFieldsArray)
            
            fieldCount = length(normalizeFieldsArray);
            for i = 1:fieldCount
                nextField = normalizeFieldsArray{i};
                
                values    = cell2mat(utils.multiAnsToArray(results.(nextField)));
                normalizedCellValues = num2cell(obj.normalizeArray(values));
                
                [results.(nextField)] = normalizedCellValues{:};
            end
        end
        
 
        function drugCount = getDrugCount(obj)
            result = sqlite3.execute('SELECT max(entityId) as highestEntityId FROM drug');
            drugCount = result.highestentityid;
        end
        
        function schema = drugVectorSchema(obj)
            highestEntityId = obj.getDrugCount();

            schema = cell(highestEntityId, 1);
            
            for i = 1:highestEntityId
                schema{i} = struct('name', 'drugId','type', 'id', 'value', i);
            end
        end
        
        function drugVector = createDrugVector(obj, drugList)

            highestEntityId = obj.getDrugCount();
            
            drugVector = zeros(1, highestEntityId);
            for i = 1:length(drugList)
                drugVector(1, drugList(i)) = 1;
            end  
        end
    end
    
end

