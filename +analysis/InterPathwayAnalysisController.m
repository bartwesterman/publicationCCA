classdef InterPathwayAnalysisController < analysis.PathwayAnalysisController
    %INTERPATHWAYANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pathwayConnectionMap;
        currentParameters;
    end
    
    methods
        function obj = init(obj)
            obj.initThesauri();
            obj.initKeggApi();
            obj.initTargetData();
            obj.initPathwayConnectionMap();
            obj.initDoseLethalityData();
            obj.initTrainingSetBuilder();
            obj.initExpressionData();
            obj.initMutationData();
            obj.initNeuralPathwayLearner();
            obj.buildTrainingSet();
            disp('INIT COMPLETE');
        end
        
        function obj = initWithDataSources(obj, thesauri, keggApi, targetData, pathwayConnectionMap, doseLethalityData, expressionData, mutationData)
            obj.thesauri                  = thesauri;
            obj.keggApi                   = keggApi;
            obj.targetData                = targetData;
            obj.pathwayConnectionMap      = pathwayConnectionMap;
            obj.doseLethalityData         = doseLethalityData;
            
            obj.initTrainingSetBuilder();
            
            obj.expressionData            = expressionData;
            obj.mutationData              = mutationData;
            
            obj.initNeuralPathwayLearner();
        end
        
        function initPathwayConnectionMap(obj)
            obj.pathwayConnectionMap = data.pathway.KeggInterPathwayConnectionMap().init(obj.thesauri.get('kegg'), Config.ALL_PATHWAY_PATH, obj.targetData.targetData, obj.doseLethalityData.getUniqueCellLineIds(),obj.mutationData);
        end
        
        function initTrainingSetBuilder(obj)
            disp('initTrainingSetBuilder()');            
            
            obj.trainingSetBuilder = data.TrainingSetBuilder().init();
            
            entityIdDeathRate = obj.thesauri.acquireEntityId('deathRate', 'evaluationCriterium');
            
            % define goal
            obj.trainingSetBuilder.assureAttribute(entityIdDeathRate, 'DEATH');

            % add all unique entity ids corresponding to the keggIds in
            % KeggPathway pathwayUnification
            % entityIdSet = rowfun(@(keggId, keggType, label, x, y) obj.keggIdsToEntityId(label, keggId, keggType), obj.pathwayUnification.nodeTable, 'ExtractCellContents', true);
            % entityIdSet = entityIdSet.(1);
            entityIdSet = obj.pathwayConnectionMap.getOrderedEntityIds();
            inputCount   = obj.pathwayConnectionMap.inputCount();
            entityCount = length(entityIdSet);
            inputOffset  = entityCount - inputCount + 1;
            for i = 1:length(entityIdSet)
                entityId = entityIdSet(i);
                obj.trainingSetBuilder.assureAttribute(entityId, obj.thesauri.getLabel(entityId), i >= inputOffset);
                
                % obj.trainingSetBuilder.mapMultipleEntityIdsToSingleEntityId(entityId, obj.pathwayConnectionMap.getEntityIdsOfPathway(entityId));
            end
        end
        
        function fixedInputIndices = getFixedInputIndices(obj)
            inputIndices = obj.trainingSetBuilder.getInputIndices(); 
            inputEntityIds = obj.trainingSetBuilder.indexesToEntityIds(inputIndices);
            cellLineInputEntityIds = obj.thesauri.isType(inputEntityIds, 'cellLine');
            fixedInputIndices = inputIndices(cellLineInputEntityIds);
        end
        
        function initNeuralPathwayLearner(obj)
            disp('initNeuralPathwayLearner()');
            
            inputCount = obj.trainingSetBuilder.getAttributeCount();
            inputIndices = obj.trainingSetBuilder.getInputIndices();            
            fixedInputIndices = obj.getFixedInputIndices();

            obj.neuralPathwayLearner = learning.NeuralPathwayLearner().initPathway(learning.NeuralPathwayLearner.kernelLibrary.sigmoid, Config.INITIAL_LEARNING_RATE, inputCount, obj.pathwayConnectionMap.getMatrix(), 3, inputIndices, fixedInputIndices);
        end
        function initNeuralPathwayLearnerForInterPathwayAnalysis(obj, recursionDepth, proportionalBatchSize)
            disp('initNeuralPathwayLearner()');
            
            inputCount = obj.trainingSetBuilder.getAttributeCount();
            inputIndices = obj.trainingSetBuilder.getInputIndices();
            fixedInputIndices = obj.getFixedInputIndices();
            
            inputKnowledgeIsNotDirectlyLethal = true;

            obj.neuralPathwayLearner = learning.NeuralPathwayLearner().initPathway(learning.NeuralPathwayLearner.kernelLibrary.sigmoid, Config.INITIAL_LEARNING_RATE, inputCount, obj.pathwayConnectionMap.getMatrix(), recursionDepth, inputIndices, inputKnowledgeIsNotDirectlyLethal, fixedInputIndices);
            obj.neuralPathwayLearner.setMomentumFactor(Config.DEFAULT_MOMENTUM_FACTOR);
            
            if proportionalBatchSize
                % obj.neuralPathwayLearner.setMustApplyBoldDriver(true);
                % obj.neuralPathwayLearner.learningRateIsBatchSizeAdapted = true;
                obj.neuralPathwayLearner.learningRate = Config.INITIAL_LEARNING_RATE_BATCHES;
            end
        end
        
        function experimentId = makeExperimentId(obj, recursionDepth, proportionalBatchSize, activation)
            experimentId = ['interpathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_activation_' activation]; 
        end
        
        function kernel = getKernel(obj, activation)
            kernel = learning.NeuralPathwayLearner.kernelLibrary.(activation);
        end
        
        function runParameterFindingExperiment(obj, parameters, resultTracker)
            
            experimentId = obj.makeExperimentId(parameters.recursionDepth, parameters.proportionalBatchSize, parameters.activation);
            obj.currentParameters = parameters;
           
            obj.crossValidationExperiment(experimentId, resultTracker, parameters, Config.FOLD_COUNT, parameters.proportionalBatchSize, Config.EXAMPLE_THROUGHPUT_PER_TRAINING);    
        end
        
        function initLearnerWithCurrentParameters(obj)
            parameters = obj.currentParameters;
            obj.neuralPathwayLearner.recursionDepth = parameters.recursionDepth;
            
            obj.initNeuralPathwayLearnerForInterPathwayAnalysis(parameters.recursionDepth, parameters.proportionalBatchSize);
            obj.neuralPathwayLearner.kernel = obj.getKernel(parameters.activation);            
            
        end
        
        function run(obj, resultTracker)
%             exampleThroughputPerTrainingFold = Config.EXAMPLE_THROUGHPUT_PER_TRAINING;
%             foldCount                        = Config.FOLD_COUNT;
            
            % use {'tanh', 'sigmoid'}; for a quick test 
            activationFunctions = {'tanh', 'sigmoid'} ; %flip(sort(fieldnames(learning.NeuralPathwayLearner.kernelLibrary))); % flipped to start with tanh, which is the most likely kernel to match the data (see chooseKernel() function results)
            for activation  = 1:length(activationFunctions)
                activation = activationFunctions{activation};                
            for recursionDepth = [2] % for quick test use [1, 3] 
            for proportionalBatchSize = [(0.03125/4)] % for quick test use [0, 1] 
                % we want to loop the value of all activation functions, 
                % having that value in a single cell array is impractical
                
                parameters = struct();
                parameters.recursionDepth = recursionDepth;
                parameters.proportionalBatchSize = proportionalBatchSize;
                parameters.activation = activation;
                
                obj.runParameterFindingExperiment(parameters, resultTracker);
                
%                obj.neuralPathwayLearner.recursionDepth = recursionDepth;
                
%                 experimentId = ['interpathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_activation_linear'];
%                 
%                 obj.initNeuralPathwayLearnerForInterPathwayAnalysis(recursionDepth, proportionalBatchSize);
%                 obj.neuralPathwayLearner.kernel = learning.NeuralPathwayLearner.kernelLibrary.linear;
%                 
%                 obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
%                 
%                 
%                 experimentId = ['interpathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_activation_sigmoid'];
%                 
%                 obj.initNeuralPathwayLearnerForInterPathwayAnalysis(recursionDepth, proportionalBatchSize);
%                 obj.neuralPathwayLearner.kernel = learning.NeuralPathwayLearner.kernelLibrary.sigmoid;
%                 
%                 obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
%                 
%                 
%                 
%                 experimentId = ['interpathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_activation_tanh'];
%                 
%                 obj.initNeuralPathwayLearnerForInterPathwayAnalysis(recursionDepth, proportionalBatchSize);
%                 obj.neuralPathwayLearner.kernel = learning.NeuralPathwayLearner.kernelLibrary.tanh;
%                 
%                 obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
            end
            end
            end
            if strcmp(Config.stoppingPoint(), 'interPathwayAnalysisController.beforeValidateBestParameters')
                Config.stoppingPoint(''); 
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point interPathwayAnalysisController.beforeValidateBestParameters reached'));
            end
            if resultTracker.hasFinalResult()
                return;
            end
            
            [bestParameters, trainingCycleCount] = resultTracker.getParametersOfBestResult();
            obj.validateBestParameters(bestParameters, trainingCycleCount, resultTracker);
        end
        
        function validateBestParameters(obj, parameters, trainingCycleCount, resultTracker)
            obj.neuralPathwayLearner.recursionDepth = parameters.recursionDepth;
            
            obj.initNeuralPathwayLearnerForInterPathwayAnalysis(parameters.recursionDepth, parameters.proportionalBatchSize);
            obj.neuralPathwayLearner.kernel = obj.getKernel(parameters.activation);

            obj.finalValidationExperiment(resultTracker, parameters, parameters.proportionalBatchSize, Config.EXAMPLE_THROUGHPUT_PER_TRAINING * (Config.FOLD_COUNT -1) / Config.FOLD_COUNT, trainingCycleCount);    

        end
        function [pathwayIds, sortedPathwayImportance] = identifyImportantPathways(obj, exampleSet)
            [pathwayIds, sortedPathwayImportance] = obj.identifyImportantNodes(exampleSet);
        end
        function pathwayFiles = pathwayIdsToPathwayFiles(obj, pathwayEntityIds)
            pathwayFiles = cell(size(pathwayEntityIds));
            for i = 1:length(pathwayEntityIds)
                pathwayFiles{i} = [obj.thesauri.getLabel(pathwayEntityIds(i)) '.xml'];
            end
        end
    end
    
end

