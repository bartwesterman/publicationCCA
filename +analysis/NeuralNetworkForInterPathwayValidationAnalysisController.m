classdef NeuralNetworkForInterPathwayValidationAnalysisController < analysis.PathwayAnalysisController
    %INTERPATHWAYANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        neuralNetwork;
    end
    
    methods

        
        function obj = initWithDataSources(obj, thesauri, keggApi, targetData, pathwayConnectionMap, doseLethalityData, expressionData, mutationData)
            obj.thesauri                  = thesauri;
            obj.keggApi                   = keggApi;
            obj.targetData                = targetData;
            obj.pathwayConnectionMap      = pathwayConnectionMap;
            obj.doseLethalityData         = doseLethalityData;
            
            obj.initTrainingSetBuilder();
            
            obj.expressionData            = expressionData;
            obj.mutationData              = mutationData;
            
            obj.initNeuralNetwork();
        end
        
        function learner = getLearner(obj)
            learner = obj.neuralNetwork;
        end
        
        function initPathwayConnectionMap(obj)
            obj.pathwayConnectionMap = data.pathway.KeggInterPathwayConnectionMap().init(obj.thesauri.get('kegg'), Config.ALL_PATHWAY_PATH, obj.targetData.targetData);
        end
        
        function initTrainingSetBuilder(obj)
            disp('initTrainingSetBuilder()');            
            
            obj.trainingSetBuilder = data.TrainingSetBuilder().init();
            
            entityIdDeathRate = obj.thesauri.acquireEntityId('deathRate', 'evaluationCriterium');
            
            % define goal
            % obj.trainingSetBuilder.assureAttribute(entityIdDeathRate, 'DEATH');

            % add all unique entity ids corresponding to the keggIds in
            % KeggPathway pathwayUnification
            % entityIdSet = rowfun(@(keggId, keggType, label, x, y) obj.keggIdsToEntityId(label, keggId, keggType), obj.pathwayUnification.nodeTable, 'ExtractCellContents', true);
            % entityIdSet = entityIdSet.(1);
            entityIdSet = obj.pathwayConnectionMap.getOrderedEntityIds();
            inputCount   = obj.pathwayConnectionMap.inputCount();
            entityCount = length(entityIdSet);
            inputOffset  = entityCount - inputCount + 1;
            
            inputEntityIdSet = entityIdSet(inputOffset:end);
            
            for i = 1:length(inputEntityIdSet)
                entityId = entityIdSet(i);
                obj.trainingSetBuilder.assureAttribute(entityId, obj.thesauri.getLabel(entityId), i >= inputOffset);
                
                % obj.trainingSetBuilder.mapMultipleEntityIdsToSingleEntityId(entityId, obj.pathwayConnectionMap.getEntityIdsOfPathway(entityId));
            end
        end
        
        function initNeuralNetwork(obj, nodesPerHiddenLayer)
            disp('initNeuralPathwayLearner()');
            
            obj.neuralNetwork = feedforwardnet(nodesPerHiddenLayer);
            obj.neuralNetwork.trainParam.showWindow=0;
        end
        
        function performanceData = trainNeuralNetwork(obj, inputData, targetData)
            [trainedNet, performanceData] = train(obj.neuralNetwork, inputData, targetData);
            obj.neuralNetwork = trainedNet;
        end
        
        
        function run(obj, resultTracker)
            % @TODO fill in this function for a default neural network
            
            
            
            
%             exampleThroughputPerTrainingFold = Config.EXAMPLE_THROUGHPUT_PER_TRAINING;
%             foldCount                        = Config.FOLD_COUNT;
%             
%             for recursionDepth = [1, 2, 4]
%             for proportionalBatchSize = [0, .625, .25, 1]
%                 obj.neuralPathwayLearner.recursionDepth = recursionDepth;
%                 
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
%             end
%             end
        end
        
    end
    
end

