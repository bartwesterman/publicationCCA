classdef RandomForest < handle
    %RANDOMFORESTANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        EXPRESSION_ANALYSIS_TREE_COUNT = 20;
        
    end
    
    properties
        randomForest;
        
        targetFile;
        treeCount;
    end
    
    methods
        function obj = init(obj, treeCount)
            if nargin < 2
                treeCount = planB.RandomForest.EXPRESSION_ANALYSIS_TREE_COUNT;
            end
            
            obj.treeCount   = treeCount;
        end
        
        function result = prioritize(obj, trainingSet, testSet)
            
            % fit learner
            % obj.randomForest = TreeBagger(obj.treeCount, full(trainingSet.getInput()), full(trainingSet.getOutput()), 'Method', 'regression','OOBPredictorImportance','on');
            obj.randomForest = fitrensemble(full(trainingSet.getInput()), full(trainingSet.getOutput()),'Method','bag','NumLearningCycles',obj.treeCount);
            
            % compute performance statistics
            prediction = obj.randomForest.predict(full(testSet.getInput()));
            performance = testSet.analyzePerformance(prediction);

            % determine important attributes, and their labels
            % predictorImportance = obj.randomForest.OOBPermutedPredictorDeltaError';            
            % importance = obj.formatImportance(predictorImportance, trainingSet.getInputEntityIds(), trainingSet.getInputLabels());
            [labels, types] = trainingSet.getInputLabels();
            importance = obj.formatImportance(obj.randomForest.predictorImportance()', trainingSet.getInputEntityIds(), labels, types);
            
            % store/return results
            result = obj.packageResults(importance, performance);
        end
        
        function result = formatImportance(obj, predictorImportance, predictorEntityIds, predictorLabel, predictorType)
            
            
            [sortedPredictorImportance, predictorOrder] = sort(predictorImportance, 'descend');
            
            label      = predictorLabel(predictorOrder);
            type       = predictorType(predictorOrder);
            entityId   = predictorEntityIds(predictorOrder);
            importance = sortedPredictorImportance;
            
            result = table(type, label, importance, entityId);
        end
        
        function storedData = packageResults(obj, importance, performance)
            storedData = struct();
            storedData.importance  = importance;
            storedData.performance = performance;
            storedData.learner = obj;
        end
        
        function hash = getHash(obj)
            hash = ['planB.RandomForest().init(' num2str(obj.treeCount) ')'];
        end
    end
    
    methods (Static)
        function tasks = createTasks()
            tasks = cell(8, 1);
            
            task = planB.RandomForest().init(1);
            tasks{1} = task;

            task = planB.RandomForest().init(2);
            tasks{2} = task;
            
            task = planB.RandomForest().init(4);
            tasks{3} = task;
            
            task = planB.RandomForest().init(8);
            tasks{4} = task;
            
            task = planB.RandomForest().init(16);
            tasks{5} = task;
            
            task = planB.RandomForest().init(32);
            tasks{6} = task;
            
            task = planB.RandomForest().init(64);
            tasks{7} = task;
            
            task = planB.RandomForest().init(128);
            tasks{8} = task;
        end
    end
end

