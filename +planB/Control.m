classdef Control < handle
    %CONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        resultFilePath;
        
    end
    
    methods
        function run(obj, targetPropertyName)
            exampleSet  = obj.prepareExampleSet();
            exampleSet  = obj.removeCellLineIds(exampleSet);
            
            dimensionReductionTasks = obj.createDimensionReductionTasks();
            
            
            reductionResults = cellfun(@(task) obj.reduceDimensions(task, exampleSet), dimensionReductionTasks);

            importantDimensions = obj.pickImportantDimensions(reductionResults);
            
            simpleExampleSet    = obj.removeUnimportantDimensions(exampleSet, importantDimensions);
            
            
            analysisTasks = obj.createAnalysisTasks();
            
            results = cellfun(@(analysisTask) obj.doAnalysis(analysisTask, simpleExampleSet), analysisTasks);
            
            obj.processResults(results);
        end
        
        function exampleSet = prepareExampleSet(obj)
            mainAnalysisController = initMainAnalysisController();
            
            exampleSet = planB.MainAnalysisControllerAdapter() ...
                            .init(mainAnalysisController) ...
                            .createExampleSet(targetPropertyName);
        end
        
        function filteredExampleSet = removeCellLineIds(obj, exampleSet)
            exampleSet  = exampleSet.filterAttributes(exampleSet.attributesExcludingType('cellLine'));            
        end
        
        function tasks = createDimensionReductionTasks(obj)
            tasks = planB.RandomForest.createDimensionReductionTasks();
        end
        
        function result = reduceDimensions(obj, task, exampleSet)
        end
        
        function importantDimensions = pickImportantDimensions(obj, dimensionReductionResults)
        end
        
        
        function tasks = createAnalysisTasks(obj)
            
        end
        
        function result = doAnalysis(obj, task, exampleSet)
        end
                
        function processResults(obj, results)
        end
    end
    methods(Static)
        function v = loadDataSource(dataSourceFilePath)
            load(dataSourceFilePath, 'obj');
            v = obj;
        end

    end
    
end

