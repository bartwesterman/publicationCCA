classdef CombinationDataLoader 
    %DATALOADER Summary of this class goes here
    %   Detailed explanation goes here
    % How to use:
    % C = dream.CombinationDataLoader.loadExamples('~/Dropbox/VU AAA Chemogenomics/2 Resources/1 Data files/dream/csv/Raw_Data_csv/ch1_training_combinations/');
    
    properties
    end
    
    methods(Static)

        function examples = loadExamples(path)
            import dream.*;
            import utils.*;
            
            files = CombinationDataLoader.getCombinationFiles(path);
            
            parsedFileNames = CombinationDataLoader.getParsedFileNames(files);
            
            drugList = CombinationDataLoader.parsedFileNamesToDrugList(parsedFileNames);
            
            drugMap = MapToolkit.listToMap(drugList);
            
            cellLineList = CombinationDataLoader.parsedFileNamesToCellLineList(parsedFileNames);

            cellLineMap = MapToolkit.listToMap(cellLineList);
            
            examples = CombinationDataLoader.createExamples(drugMap, cellLineMap, path, parsedFileNames);
            
        end
        
        function examples = createExamples(drugMap, cellLineMap, path, parsedFileNames)
            import dream.*;
            
            examples = zeros(length(parsedFileNames), drugMap.length + 2);
            for i = 1:length(parsedFileNames)
                parsedFileName = parsedFileNames{i};
                
                examples(i,:) = CombinationDataLoader.createExample(drugMap, cellLineMap, path, parsedFileName);
            end
        end
        
        function example = createExample(drugMap, cellLineMap, path, parsedFileName)
            import dream.*;
            
            combinationMatrix = CombinationDataLoader.parseCombinationFileContents(strcat(path, '/', parsedFileName.fileName));
            combinationIndex = CombinationDataLoader.computeCombinationIndex(combinationMatrix);
                 
            drugVector = CombinationDataLoader.createDrugVector(drugMap, {parsedFileName.drugA, parsedFileName.drugB});
            
            example = [combinationIndex, cellLineMap(parsedFileName.cellLine) drugVector'];
        end
        
        function drugVector = createDrugVector(drugMap, drugNameList)
            import dream.*;
            
            drugVector = zeros(drugMap.length, 1);
            for i = 1:length(drugNameList)
                drugVector(drugMap(drugNameList{i})) = 1;
            end  
        end
        
        function cellLineList = parsedFileNamesToCellLineList(parsedFileNames)
            import dream.*;
            
            cellLineList = cell(0);

            for i = 1:length(parsedFileNames)
                parsedFileName = parsedFileNames{i};

                cellLineList{i}     = parsedFileName.cellLine;
            end
        end
        
        function drugList = parsedFileNamesToDrugList(parsedFileNames)
            import dream.*;
            
            drugList = cell(0);

            for i = 1:length(parsedFileNames)
                parsedFileName = parsedFileNames{i};

                drugList{2*i - 1}     = parsedFileName.drugA;

                drugList{2*i} = parsedFileName.drugB;
            end
            
        end
                
        function parsedFileNames = getParsedFileNames(files)
            import dream.*;
            
            parsedFileNames = cell(0);
            
            for i = 1:length(files)
                file = files(i);
                parsedFileName = CombinationDataLoader.parseCombinationFileName(file.name);
                parsedFileNames{i} = parsedFileName;                
            end
        end
        
        function files = getCombinationFiles(path)
            files = dir(strcat(path, '/*.csv'));
        end
        
        function parsedFileName = parseCombinationFileName(fileName)
            parsedFileName = struct;
            matches = regexp(fileName, '\.', 'split');
            
            parsedFileName.fileName = fileName;
            parsedFileName.drugA    = matches{1};
            parsedFileName.drugB    = matches{2};
            parsedFileName.cellLine = matches{3};
            
        end
        
        function combinationNumberMatrix = parseCombinationFileContents(fileName)
            import utils.*;
            import dream.*;
            
            csvCellMatrix = Csv.load(fileName, ',');
            combinationCellMatrix = CellMatrixToolkit.subCellMatrix(csvCellMatrix, 2, 2, 6, 6);
            combinationNumberMatrix = CellMatrixToolkit.toNumberMatrix(combinationCellMatrix, @CellCleaners.cleanNumeric);
            
        end

        
        function lowestCombinationIndex = computeCombinationIndex(matrix)
            lowestCombinationIndex = Inf;
            
            for x = 1:length(matrix)
                for y = 1:length(matrix(x))
                    combinationIndex = 100 / matrix(x,1) + 100 / matrix(1,y) + 100 / matrix(x,y);
                    
                    if combinationIndex < lowestCombinationIndex
                        lowestCombinationIndex = combinationIndex;
                    end
                end
            end
        end
    end    
end

