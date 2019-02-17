classdef RandomForestAnalysisController < analysis.BaseAnalysisController
    %RANDOMFORRESTANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        randomForest;
        
        targetData;
        expressionScope;
    end
    
    methods
        
        function obj = initWithDataSources(obj, thesauri, doseLethalityData, expressionData, expressionScope)
            obj.initMembers(thesauri, doseLethalityData, expressionData, expressionScope);

            obj.initTrainingSetBuilder();
                                    
            [exampleSet, targetSet] = obj.buildTrainingSet();
            
            obj.exampleSet = exampleSet;
            obj.targetSet  = targetSet;
            
            disp('INIT COMPLETE');
        end
        
        function obj = initMembers(obj, thesauri, doseLethalityData, expressionData, expressionScope)
            obj.thesauri                  = thesauri;
            obj.doseLethalityData         = doseLethalityData;
            
            obj.expressionData            = expressionData;
            obj.expressionScope           = expressionScope;
            
        end
        
        function initTrainingSetBuilder(obj)
            obj.trainingSetBuilder = data.TrainingSetBuilder().init();
            
            entityIdDeathRate = obj.thesauri.acquireEntityId('deathRate', 'evaluationCriterium');
            
            % define goal
            obj.trainingSetBuilder.assureAttribute(entityIdDeathRate, 'DEATH');
            
            % arrayfun(@(drugId)   obj.trainingSetBuilder.assureAttribute(mutatedGeneId,   obj.thesauri.getLabel(mutatedGeneId), 1),   obj.mutationData.getUniqueMutations());
            arrayfun(@(expressedGeneId)   obj.trainingSetBuilder.assureAttribute(expressedGeneId, obj.thesauri.getLabel(expressedGeneId), 1), intersect(obj.expressionData.getUniqueExpressedGenes(), obj.expressionScope ));
            
            arrayfun(@(drugId)   obj.trainingSetBuilder.assureAttribute(drugId,   obj.thesauri.getLabel(drugId), 1), obj.doseLethalityData.getUniqueDrugIds());
            % arrayfun(@(cellId)   obj.trainingSetBuilder.assureAttribute(cellId,   obj.thesauri.getLabel(cellId)),    obj.doseLethalityData.getUniqueCellLineIds());            
        end

        function [exampleList, target] = buildTrainingSet(obj)
            exampleList = zeros(obj.doseLethalityData.getExampleCount(), obj.trainingSetBuilder.getAttributeCount());
            
            allCellLineIds = obj.doseLethalityData.getUniqueCellLineIds();

            currentExampleCount = 0;
            for i = 1:length(allCellLineIds)
                cellLineId = allCellLineIds(i); 
                exampleListForCellLine = obj.createExampleListForCellLineWithExpression(cellLineId);
                newExampleCount = size(exampleListForCellLine, 1);
                startIndex = currentExampleCount + 1;
                endIndex   = startIndex + newExampleCount - 1;
                exampleList(startIndex:endIndex, :) = exampleListForCellLine;
                currentExampleCount = currentExampleCount + newExampleCount;
            end
            
            target = sparse(exampleList(:, 1));
            exampleList(:, 1) = 0; % this eliminates all information from this feature, but keeps the positions of the output matching the indexing of TrainingSetBuilder
            exampleList = sparse(exampleList);
            
            % shuffle the examples first, so everything else later on
            % becomes easy
            rng(Config.RANDOM_NUMBER_SEED); 
            exampleCount = length(target);
            randomShuffle = randperm(exampleCount);
            rng('shuffle'); % restore random number generator to produce random numbers
            exampleList   = exampleList(randomShuffle, :);
            target        = target(randomShuffle);
            
            obj.exampleSet = exampleList;
            obj.targetSet  = target;
            
            trainingProportion = 1 - Config.TEST_PROPORTION;
            trainingExampleCount = floor(exampleCount * trainingProportion);
            
            obj.trainingExampleSet = exampleList(1:trainingExampleCount, :);
            obj.trainingTargetSet  = target(1:trainingExampleCount, :);
            
            obj.testExampleSet = exampleList((1 + trainingExampleCount) : end, :);
            obj.testTargetSet  = target((1 + trainingExampleCount) : end, :);            
        end
        
        % returns 
        function storedData = run(obj, targetFile, treeCount)
            if nargin < 2
                targetFile = Config.RELEVANT_EXPRESSION_ANALYSIS_RESULT_PATH;
            end
            
            if nargin < 3
                treeCount = Config.EXPRESSION_ANALYSIS_TREE_COUNT;
            end
            % @TODO: remove this quick hack to reduce processing power need
            randomSelection = randperm(size(obj.trainingExampleSet, 1), min(5000, size(obj.trainingExampleSet, 1)));
            
            smallerTrainingExampleSet = full(obj.trainingExampleSet(randomSelection, :));
            smallerTrainingTargetSet  = full(obj.trainingTargetSet(randomSelection, :));
            obj.randomForest = TreeBagger(treeCount, smallerTrainingExampleSet, smallerTrainingTargetSet, 'Method', 'regression','OOBPredictorImportance','on');
            % @TODO: make this old correct code active again after finding
            % sane values
            % obj.randomForest = TreeBagger(treeCount, full(obj.trainingExampleSet), full(obj.trainingTargetSet), 'Method', 'regression','OOBPredictorImportance','on');
            
            prediction = obj.randomForest.predict(full(obj.testExampleSet));
            errorVector = prediction - obj.testTargetSet;
            
            rootMeanSquaredError  = sqrt(mean(errorVector .^2));
            meanAbsoluteError     = mean(abs(errorVector));
            relativeAbsoluteError = sum(abs( full(errorVector))) / sum( abs( full(obj.testTargetSet) - mean(full(obj.testTargetSet)) ));
            relativeSquaredError  = var(errorVector) / var(full(obj.testTargetSet));
            
            expressionIndices = obj.getExpressionIndices();
            
            predictorImportance = obj.randomForest.OOBPermutedPredictorDeltaError;
            
            relevantPredictorImportance = predictorImportance(expressionIndices);
            relevantPredictorLabel      = obj.trainingSetBuilder.labelArray(expressionIndices);
            relevantPredictorEntityIds  = obj.trainingSetBuilder.entityIdOrder(expressionIndices);
           
            [sortedRelevantPredictorImportance, predictorOrder] = sort(relevantPredictorImportance, 'descend');
            
            sortedRelevantPredictorLabel      = relevantPredictorLabel(predictorOrder)';
            sortedRelevantEntityIds           = relevantPredictorEntityIds(predictorOrder)';
            sortedRelevantPredictorImportance = sortedRelevantPredictorImportance';

            predictorLabel      = sortedRelevantPredictorLabel;
            predictorImportance = sortedRelevantPredictorImportance;
            entityId            = sortedRelevantEntityIds;

            importance = table(predictorLabel, predictorImportance, entityId);
                        
            storedData = struct();
            storedData.importance = importance;
            storedData.rootMeanSquaredError  = rootMeanSquaredError;
            storedData.meanAbsoluteError     = meanAbsoluteError;
            storedData.relativeAbsoluteError = relativeAbsoluteError;
            storedData.relativeSquaredError  = relativeSquaredError;
            
            save(targetFile, 'storedData', '-v7.3');
        end
        
        function expressionIndices = getExpressionIndices(obj)
            entityIdOrder =  obj.trainingSetBuilder.entityIdOrder;
            expressionIndices = obj.thesauri.isType(entityIdOrder, 'kegg');
        end
    end
    
end

