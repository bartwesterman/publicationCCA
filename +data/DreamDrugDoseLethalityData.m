classdef DreamDrugDoseLethalityData < handle
    %DREAMDOSELETHALITYDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        deathRateId;
        
        drugDoseLethalityTable;
        uniqueDrugIdMap;
        uniqueCellLineIdMap;
        
        drugToDosageLevels;
    end
    
    methods
        
        function obj = init(obj, thesauri, combinationPath, qualityTableFilePath)
            if nargin < 3
                combinationPath = Config.DREAM_COMBINATIONS_PATH;
            end
            
            if nargin < 4
                qualityTableFilePath = Config.DREAM_MONO_AND_COMBINATION_TRAINING;
            end
            
            qualityTable = readtable(qualityTableFilePath);
            
            highQualityFileNames = obj.findHighQualityFileNames(combinationPath, qualityTableFilePath);
            
            obj.drugToDosageLevels = containers.Map();
            
            obj.uniqueDrugIdMap = [];
                        
            exampleCount = 36 * length(highQualityFileNames); % number of combinations per file * number of files
            
            drugDosePairList = cell(exampleCount, 1);
            cellLine         = zeros(exampleCount, 1);
            deathRate        = zeros(exampleCount, 1);
            exampleId        = zeros(exampleCount, 1);
            obj.drugDoseLethalityTable = table(cellLine, drugDosePairList, deathRate, exampleId);
            
            drugThesaurus     = thesauri.get('drug');
            cellLineThesaurus = thesauri.get('cellLine');
            
            evaluationCriteriumThesaurus = thesauri.get('evaluationCriterium');
            exampleIdThesaurus  = thesauri.get('exampleId');            
            obj.deathRateId = evaluationCriteriumThesaurus.getId('deathRate');
            
            nextExampleIndex = 1;
            for i = 1:length(highQualityFileNames)
                fileName = highQualityFileNames{i};
                csvCellMatrix = data.csvread([combinationPath fileName]);
                 
                survivalPercentageMatrix = cellfun(@str2double, csvCellMatrix(2:7, 2:7));

                if (any(any(survivalPercentageMatrix < -.4)))
                    drugNameA = csvCellMatrix{ 9, 2};
                    drugNameB = csvCellMatrix{10, 2};
                    
                    cellName  = csvCellMatrix{13, 2};

                    problemRowIndices = find(strcmp(qualityTable.CELL_LINE, cellName) & strcmp(qualityTable.COMPOUND_A, drugNameA) & strcmp(qualityTable.COMPOUND_B, drugNameB));
                    qualityTable.QA(problemRowIndices) = -1;
                    writetable(qualityTable, qualityTableFilePath);
                    disp(['Warning!, file contains survival rate lower than 0: ' fileName ' at lines ' mat2str(problemRowIndices) ' in ' qualityTableFilePath]);
                    
                    continue
                end
                
                drugNameA    = csvCellMatrix{ 9, 2};
                drugNameB    = csvCellMatrix{10, 2};
                
                drugComboNames = sort({drugNameA; drugNameB})';
                
                cellLineName = csvCellMatrix{13, 2};
                
                exampleName  = strcat(cellLineName, '@', drugComboNames{1}, '@', drugComboNames{2});
                exampleEntityId = exampleIdThesaurus.getId(exampleName);
                drugA = drugThesaurus.getId(drugNameA);
                drugB = drugThesaurus.getId(drugNameB);
                
%                 unitDrugA = csvCellMatrix{11, 2};
%                 unitDrugB = csvCellMatrix{12, 2};
                
                cellLine = cellLineThesaurus.getId(cellLineName);
                
                
                
                dosageLevelsA = cellfun(@str2double, csvCellMatrix(2:7, 1) );
                dosageLevelsB = cellfun(@str2double, csvCellMatrix(1, 2:7)');
                
                obj.addDosageLevelsForCellLineDrugCombo(cellLine, drugA, dosageLevelsA);
                obj.addDosageLevelsForCellLineDrugCombo(cellLine, drugB, dosageLevelsB);
                
                % convert to number matrix
                
                for aIndex = 1:length(dosageLevelsA)
                for bIndex = 1:length(dosageLevelsB)
                    
                    deathRate = (100 - survivalPercentageMatrix(aIndex, bIndex)) / 100;
                    
                    doseA = dosageLevelsA(aIndex);
                    doseB = dosageLevelsB(bIndex);
                    
                    drugDosePairMatrix = [[drugA, drugB]' [doseA, doseB]'];
                    
                    obj.drugDoseLethalityTable.drugDosePairList(nextExampleIndex) = {drugDosePairMatrix};
                    obj.drugDoseLethalityTable.cellLine(nextExampleIndex)         = cellLine;
                    obj.drugDoseLethalityTable.deathRate(nextExampleIndex)        = deathRate;
                    obj.drugDoseLethalityTable.exampleId(nextExampleIndex)        = exampleEntityId;
                    
                    nextExampleIndex = nextExampleIndex + 1;
                end
                end
            end    
            obj.drugDoseLethalityTable = obj.drugDoseLethalityTable(1:(nextExampleIndex - 1), :);

            disp('Imported dream combination files');
        end
        
        function addDosageLevelsForCellLineDrugCombo(obj, cellLine, drug, newDosageLevels)
%             cellLineKey = num2str(cellLine);
%             
%             drugToDosageLevels = containers.Map();
%             if obj.cellLineToDrugToDosageLevels.isKey(cellLineKey)
%                 drugToDosageLevels = obj.cellLineToDrugToDosageLevels(cellLineKey);
%             end
            drugKey = num2str(drug);
            
            if (~obj.drugToDosageLevels.isKey(drugKey))
                obj.drugToDosageLevels(drugKey) = java.util.Vector();
            end
            
            obj.drugToDosageLevels(drugKey).add(newDosageLevels);
            
            % obj.cellLineToDrugToDosageLevels(cellLineKey) = drugToDosageLevels;
        end
        
        function dosageLevels = getDosageLevels(obj, cellLine, drug)
            % cellLineKey = num2str(cellLine);
            drugKey     = num2str(drug);
            
            dosageLevelsVector = obj.drugToDosageLevels(drugKey);
            
            if isa(dosageLevelsVector, 'double')
                dosageLevels = dosageLevelsVector;
                return;
            end
                        
            dosageLevelsCount = dosageLevelsVector.size();
            
            dosageLevelMatrix = zeros(6, dosageLevelsCount);
            
            for i = 1:dosageLevelsCount
                dosageLevelMatrix(:, i) = dosageLevelsVector.get(i-1);
            end
            
            highestDosageLevels = dosageLevelMatrix(6, :);
            [sortedHighestDosageLevels, sortedHighestDosageIndexes] = sort(highestDosageLevels, 'ascend');
            
            bestMedianIndex = dosageLevelsCount / 2 + .5;
            
            if mod(bestMedianIndex, 1) ~= 0
                lowerMedianIndex = floor(bestMedianIndex);
                higherMedianIndex = ceil(bestMedianIndex);

                lowerMedianValue = sortedHighestDosageLevels(lowerMedianIndex);
                higherMedianValue = sortedHighestDosageLevels(higherMedianIndex);

                bestMedianIndex = lowerMedianIndex + (sum(highestDosageLevels == lowerMedianValue) < sum(highestDosageLevels == higherMedianValue));
                bestMedianIndex = sortedHighestDosageIndexes(bestMedianIndex);
            end
            
            dosageLevels = dosageLevelMatrix(:, bestMedianIndex);
            
            obj.drugToDosageLevels(drugKey) = dosageLevels;
        end
        
        function drugIds = getUniqueDrugIds(obj)
            
            if isempty(obj.uniqueDrugIdMap)
                obj.uniqueDrugIdMap = containers.Map();
            end

            function storeDrugEntityId(drugEntityId) 
                obj.uniqueDrugIdMap(num2str(drugEntityId)) = true;
            end
            
            function storeDrugEntityIdsInDrugDosePairList(drugDosePairListMatrix)
                arrayfun( @storeDrugEntityId, drugDosePairListMatrix(:,1));
            end
            
            cellfun(@storeDrugEntityIdsInDrugDosePairList ,obj.drugDoseLethalityTable.drugDosePairList);
            
            drugIds = cellfun(@str2num, obj.uniqueDrugIdMap.keys());
        end
        
        function cellLineIds = getUniqueCellLineIds(obj)
            
            if isempty(obj.uniqueCellLineIdMap)
                obj.uniqueCellLineIdMap = containers.Map();
            end

            function storeCellLineEntityId(entityId) 
                obj.uniqueCellLineIdMap(num2str(entityId)) = true;
            end
            
            
            arrayfun(@storeCellLineEntityId ,obj.drugDoseLethalityTable.cellLine);
            
            cellLineIds = cellfun(@str2num, obj.uniqueCellLineIdMap.keys());
        end
        
        function propertyValueList = rowToEntityIdValueList(obj, rowIndex)
            cellLine = obj.drugDoseLethalityTable.cellLine(rowIndex);
            deathRate = obj.drugDoseLethalityTable.deathRate(rowIndex);
            
            drugDosePairList = obj.drugDoseLethalityTable.drugDosePairList{rowIndex};
            
            propertyValueList = [obj.deathRateId, deathRate;
                                 cellLine,        1        ; 
                                 drugDosePairList];
        end

        function exampleList = exampleListForCellLine(obj, cellLineId)
            rowIds = find(obj.drugDoseLethalityTable.cellLine == cellLineId);
            
            exampleList = cell(length(rowIds), 1);
            
            for i = 1:length(exampleList)
                exampleList(i) = {obj.rowToEntityIdValueList(rowIds(i))};
            end
        end
        
        function exampleList = exampleListForCellLines(obj, cellLineIds)
            rowIds = find(arrayfun(@(cellLineId) ismember(cellLineId, cellLineIds), obj.drugDoseLethalityTable.cellLine));
            
            exampleList = cell(length(rowIds), 1);
            
            for i = 1:length(exampleList)
                exampleList(i) = {obj.rowToEntityIdValueList(rowIds(i))};
            end
        end
        
        function exampleList = toExampleList(obj)
            
            exampleList = cell(height(obj.drugDoseLethalityTable), 1);
            
            for i = 1:length(exampleList)
                exampleList(i) = {obj.rowToEntityIdValueList(i)};
            end
        end
        
        function exampleCount = getExampleCount(obj)
            exampleCount = height(obj.drugDoseLethalityTable);
        end
        
        function [essentialEntityIds, essentialValues, cellLineId, drugAId, drugBId, exampleId]  = getExampleData(obj, exampleIndex)
            deathRate        = obj.drugDoseLethalityTable.deathRate(exampleIndex);
            cellLineId       = obj.drugDoseLethalityTable.cellLine(exampleIndex);
            exampleId        = obj.drugDoseLethalityTable.exampleId(exampleIndex);
            drugDosePairList = obj.drugDoseLethalityTable.drugDosePairList{exampleIndex};
            drugIds    = drugDosePairList(:, 1);
            drugValues = drugDosePairList(:, 2);

            drugAId = drugIds(1);
            drugBId = drugIds(2);
            
            essentialEntityIds = [obj.deathRateId; drugIds;    cellLineId];
            essentialValues    = [deathRate;       drugValues; 1         ];
            
        end
        
        function entityIds = getEntityIds(obj)
            entityIds = [obj.deathRateId obj.getUniqueDrugIds() obj.getUniqueCellLineIds]';
        end
        
        function highQualityFiles = findHighQualityFileNames(obj, combinationPath, qualityTableFilePath)

            % WARNING: CODE HAS BEEN TESTED MANUALLY, NO UNIT TEST
            % EXISTS!!!!
            
            files = dir([combinationPath '/*.csv']);
            
            files = files(arrayfun(@(file)~isempty(regexp(file.name, '^[^\.].+\..+\..+\.csv$', 'once')), files));
            
            qualityTable = readtable(qualityTableFilePath);
            
            lowQualityTable = qualityTable(qualityTable.QA ~=1, :);
            
            lowQualityFileIds = strcat(lowQualityTable.COMPOUND_A, '.', lowQualityTable.COMPOUND_B, '.', lowQualityTable.CELL_LINE);
            
            sourceFileNames = {files.('name')}';
            
            sourceFileIds   = cellfun(@(fileName) fileName(1:end - 9), sourceFileNames, 'UniformOutput', false);
            
            highQualityFiles = sourceFileNames;

            highQualityFiles = obj.removeLowQualityFiles(highQualityFiles, lowQualityFileIds);            
            
            highQualityFiles = obj.removeLowerRepetitions(highQualityFiles);
        end
        
        function highQualityFiles = removeLowerRepetitions(obj, highQualityFiles)
            % WARNING: CODE HAS BEEN TESTED MANUALLY, NO UNIT TEST
            % EXISTS!!!!            
            repeatedFiles = highQualityFiles(obj.strContains(highQualityFiles, 'Rep2') + obj.strContains(highQualityFiles, 'Rep3') == 1);
            
            lowQualityFileNameIndices = zeros(size(repeatedFiles));
            for i = 1:size(repeatedFiles, 1)
                repeatedFile = repeatedFiles{i};
                repetitionCount = num2str(str2double(repeatedFile(end - 4)) - 1);  % parse num to int, subract 1, convert back to string
                
                poorEarlierFile = repeatedFile;
                poorEarlierFile(end-4) = repetitionCount;
                removalCandidateIndex = find(strcmp(poorEarlierFile, highQualityFiles));
                if isempty(removalCandidateIndex)
                    continue;
                end
                lowQualityFileNameIndices(i) = removalCandidateIndex;
            end
            lowQualityFileNameIndices = lowQualityFileNameIndices(lowQualityFileNameIndices ~= 0);
            highQualityFiles(lowQualityFileNameIndices) = [];
        end
        
        function highQualityFiles = removeLowQualityFiles(obj, highQualityFiles, lowQualityFileIds)
            % WARNING: CODE HAS BEEN TESTED MANUALLY, NO UNIT TEST
            % EXISTS!!!!            
            uniqueLowQualityFileIds = unique(lowQualityFileIds);
            frequencyLowQualityFileIds = cellfun(@(x) sum(ismember(lowQualityFileIds,x)),uniqueLowQualityFileIds);
            
            lowQualityFileNameIndices = zeros(sum(frequencyLowQualityFileIds), 1);
            
            processedLowQualityFileCounter = 0;
            for i = 1:size(uniqueLowQualityFileIds, 1)
                
                removalCandidateIndices = find(~(cellfun(@isempty, strfind(highQualityFiles, [uniqueLowQualityFileIds{i} '.Rep']))));
                removalCandidates = highQualityFiles(removalCandidateIndices);
                removalCandidatesRepitionCounter = cellfun(@(v) str2double(v(end-4)), removalCandidates);
                
                [~, ascendingRepetitionOrder] = sort(removalCandidatesRepitionCounter);
                
                lowQualityFileCount = frequencyLowQualityFileIds(i);
                
                removedFileCount = min(lowQualityFileCount, length(removalCandidates));
                lowQualityFileNameIndices((1:removedFileCount) + processedLowQualityFileCounter) = removalCandidateIndices(ascendingRepetitionOrder(1:removedFileCount)); 
                processedLowQualityFileCounter = processedLowQualityFileCounter + removedFileCount;

            end
            lowQualityFileNameIndices = lowQualityFileNameIndices(lowQualityFileNameIndices ~= 0);
            highQualityFiles(lowQualityFileNameIndices) = [];
        end
        
        function res = strContains(obj, c, pattern)
            res = ~(cellfun(@isempty, strfind(c, pattern)));
        end
    end
    
end

