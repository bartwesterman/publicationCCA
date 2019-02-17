classdef NeuralNetworkForIntraPathwayValidationAnalysisController < analysis.PathwayAnalysisController
    %INTERPATHWAYANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        neuralNetwork;
    end
    
    methods

        
        
        function obj = initWithDataSources(obj, thesauri, keggApi, targetData, pathwayUnification, doseLethalityData, expressionData, mutationData)
            obj.thesauri                  = thesauri;
            obj.keggApi                   = keggApi;
            obj.targetData                = targetData;
            obj.pathwayUnification        = pathwayUnification;
            obj.doseLethalityData         = doseLethalityData;
            
            obj.initTrainingSetBuilder();
            
            obj.expressionData            = expressionData;
            obj.mutationData              = mutationData;
                        
            [exampleSet, targetSet] = obj.buildTrainingSet();
            
            obj.exampleSet = exampleSet;
            obj.targetSet  = targetSet;
            
            disp('INIT COMPLETE');
        end
        
        function learner = getLearner(obj)
            learner = obj.neuralNetwork;
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
            entityIdSet = cell2mat(obj.pathwayUnification.nodeTable.entityId);
            
            rowfun(@(entityId, label) obj.trainingSetBuilder.assureAttribute(entityId, label), table(entityIdSet, obj.pathwayUnification.nodeTable.label), 'NumOutputs', 0);

            % add all unique entity ids from data sets            
            arrayfun(@(targetId) obj.trainingSetBuilder.assureAttribute(targetId, obj.thesauri.getLabel(targetId)),  obj.targetData.getUniqueTargetIds());
            arrayfun(@(drugId)   obj.trainingSetBuilder.assureAttribute(drugId,   obj.thesauri.getLabel(drugId), 1), obj.doseLethalityData.getUniqueDrugIds());
            arrayfun(@(cellId)   obj.trainingSetBuilder.assureAttribute(cellId,   obj.thesauri.getLabel(cellId)),    obj.doseLethalityData.getUniqueCellLineIds());
            
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

