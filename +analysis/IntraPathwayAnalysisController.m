classdef IntraPathwayAnalysisController < analysis.PathwayAnalysisController
    %PATHWAYANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        pathwayUnification;

    end
    
    methods
        
        function obj = init(obj)
            obj.initThesauri();
            obj.initKeggApi();
            obj.initTargetData();
            obj.initPathwayUnification();
            obj.initDoseLethalityData();
            obj.initTrainingSetBuilder();
            obj.initExpressionData();
            obj.initMutationData();
            obj.initNeuralPathwayLearner();
            obj.buildTrainingSet();
            disp('INIT COMPLETE');
        end

        function obj = initWithDataSources(obj, thesauri, keggApi, targetData, pathwayUnification, doseLethalityData, expressionData, mutationData)
            obj.thesauri                  = thesauri;
            obj.keggApi                   = keggApi;
            obj.targetData                = targetData;
            obj.pathwayUnification        = pathwayUnification;
            obj.doseLethalityData         = doseLethalityData;
            
            obj.initTrainingSetBuilder();
            
            obj.expressionData            = expressionData;
            obj.mutationData              = mutationData;
            
            obj.initNeuralPathwayLearner();
            
            [exampleSet, targetSet] = obj.buildTrainingSet();
            
            obj.exampleSet = exampleSet;
            obj.targetSet  = targetSet;
            
            disp('INIT COMPLETE');
        end
        
        
        function initPathwayUnification(obj)
            disp('initPathwayUnification()');
            
            obj.pathwayUnification = data.pathway.KeggPathway().init(obj.thesauri.get('kegg'));

            pathwayFiles = dir([Config.SELECTED_PATHWAY_PATH '*.xml']);
            
            % @TODO: delete this later
            
            % obj.pathwayUnification.load([Config.PATHWAY_PATH 'hsa05200.xml']);
            % return;
            % delete up to this point
            for i = 1:length(pathwayFiles)
                pathwayFile = pathwayFiles(i).name;
                disp(['processing pathway file ' pathwayFile datestr(now)]);
                
                obj.pathwayUnification.load([Config.SELECTED_PATHWAY_PATH pathwayFile]);
            end
            disp(['processing pathway files done' datestr(now)]);
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

        function initNeuralPathwayLearner(obj)
            disp('initNeuralPathwayLearner()');
            
            inputCount = obj.trainingSetBuilder.getAttributeCount();
            inputIndices = obj.trainingSetBuilder.getInputIndices();
            
            obj.neuralPathwayLearner = learning.NeuralPathwayLearner().initPathway(learning.NeuralPathwayLearner.kernelLibrary.sigmoid, .1, inputCount, obj.pathwayUnification.getMatrix(), obj.pathwayUnification.getDiameter() + 2, inputIndices);
            
            function mapDrugToTarget(drugId, targetId)
                fromIndex = obj.trainingSetBuilder.entityIdToIndex(drugId);
                toIndex   = obj.trainingSetBuilder.entityIdToIndex(targetId);
                obj.neuralPathwayLearner.connect(fromIndex, toIndex, -1);
                
                targetSiblingIds = cell2mat(obj.pathwayUnification.getSiblings(targetId));
                
                arrayfun(@(targetSiblingId) obj.neuralPathwayLearner.connect(fromIndex, obj.trainingSetBuilder.entityIdToIndex(targetSiblingId), 0), targetSiblingIds);
            end
            
            obj.targetData.forEachDrugIdTargetKeggEntityIdCombination(@mapDrugToTarget);
        end
        
        function initNeuralPathwayLearnerWithIncreasedLinkCount(obj, kernel, transitiveStepDepth, mustIncludePotentialLinks, recursionDepth, proportionalBatchSize)
            disp('initNeuralPathwayLearner()');
            
            inputCount = obj.trainingSetBuilder.getAttributeCount();
            inputIndices = obj.trainingSetBuilder.getInputIndices();
            
            obj.neuralPathwayLearner = learning.NeuralPathwayLearner().initPathway(kernel, Config.INITIAL_LEARNING_RATE, inputCount, obj.pathwayUnification.getMatrixWithIncreasedLinkCount(transitiveStepDepth, mustIncludePotentialLinks), recursionDepth, inputIndices);

            obj.neuralPathwayLearner.setMomentumFactor(Config.DEFAULT_MOMENTUM_FACTOR);
            
            if proportionalBatchSize
                obj.neuralPathwayLearner.setMustApplyBoldDriver(true);
            end
            
            function mapDrugToTarget(drugId, targetId)
                fromIndex = obj.trainingSetBuilder.entityIdToIndex(drugId);
                toIndex   = obj.trainingSetBuilder.entityIdToIndex(targetId);
                obj.neuralPathwayLearner.connect(fromIndex, toIndex, -1);
                
                targetSiblingIds = cell2mat(obj.pathwayUnification.getSiblings(targetId));
                
                arrayfun(@(targetSiblingId) obj.neuralPathwayLearner.connect(fromIndex, obj.trainingSetBuilder.entityIdToIndex(targetSiblingId), 0), targetSiblingIds);
            end
            
            obj.targetData.forEachDrugIdTargetKeggEntityIdCombination(@mapDrugToTarget);
            disp('initNeuralPathwayLearner completed');
        end
        
        function nv = createNetworkVisualization(obj)
            disp('create visualization');
            labels   = obj.trainingSetBuilder.labelArray;
            pathwayX = obj.pathwayUnification.nodeTable.x;
            pathwayY = obj.pathwayUnification.nodeTable.y;
            deathX   = (max(pathwayX) - min(pathwayX)) / 2;
            deathY   =  min(pathwayY) - 50;
            
            nonPathwayNodeCount = length(obj.trainingSetBuilder.entityIdOrder) - height(obj.pathwayUnification.nodeTable) - 1;
            
            % create x y coordinates for drugs and left over targets such
            % that connections between a target that is not in a kegg pathway and a drug become clearly visible
            % I am making an arc shape to accomplish this goal. 
            
            % the vars I base my arc on
            halfArcWidth = max(pathwayX) - min(pathwayX);
            arcHeight   = .1 * halfArcWidth;
            
            radius    = (halfArcWidth ^ 2 + arcHeight ^ 2) / ( 2 * arcHeight);
            alpha     = acos(halfArcWidth / radius);
            
            angleRange = pi - 2 * alpha;
            
            angleIncreasePerPoint = angleRange / (nonPathwayNodeCount - 1);
            arcYOffsetCorrection = radius - arcHeight;
            
            nonPathwayNodeArcYOffset = max(pathwayY) + 50;
            
            nonPathwayNodeArcXOffset = (max(pathwayX) - min(pathwayX)) / 2;
            
            arcY = nonPathwayNodeArcYOffset + radius * sin(alpha:angleIncreasePerPoint:(alpha + angleRange))' - arcYOffsetCorrection;
            arcX = nonPathwayNodeArcXOffset + radius * cos(alpha:angleIncreasePerPoint:(alpha + angleRange))';
            
            positions = [deathX deathY; pathwayX pathwayY; arcX arcY];
            
            nv = visualization.NetworkVisualization().init(obj.neuralPathwayLearner.dampeningMatrix(2:end, :), positions, labels);
        end
        
        function bigErrorHistory = testTrainOnAllCellLines(obj)
            obj.initNeuralPathwayLearner();
            rawExampleList = obj.doseLethalityData.toExampleList();
            
            exampleList = cellfun(@(x) obj.trainingSetBuilder.createExample(x), rawExampleList, 'UniformOutput', false);
            exampleList = vertcat(exampleList{:});
            target = exampleList(:, 1);
            exampleList(:, 1) = 0;
            obj.neuralPathwayLearner.recursionDepth = 6;
            
            batchCount = 1;
            batchSize  = 1;
            cycleCount = 1;
            bigErrorHistory = zeros(batchCount * cycleCount, 1);
            for i = 1:batchCount
                exampleIndices = randperm(size(exampleList, 1), batchSize);
                errorHistory = obj.neuralPathwayLearner.train(cycleCount, exampleList(exampleIndices, :), target(exampleIndices));
                disp(['error' num2str(errorHistory(end))]);
                startIndex = 1 + (i - 1) * cycleCount;
                endIndex   = startIndex + cycleCount - 1;
                bigErrorHistory(startIndex:endIndex) = errorHistory(:);
            end
            figure
            plot(bigErrorHistory);
        end
        
        
        function bigErrorHistory = testTrainOnSingleCellLine(obj, cellLineId)
            obj.initNeuralPathwayLearner();
            rawExampleList = obj.doseLethalityData.exampleListForCellLine(cellLineId);
            
            exampleList = cellfun(@(x) obj.trainingSetBuilder.createExample(x), rawExampleList, 'UniformOutput', false);
            exampleList = vertcat(exampleList{:});
            target = exampleList(:, 1);
            exampleList(:, 1) = 0;
            obj.neuralPathwayLearner.recursionDepth = 6;
            
            batchCount = 5;
            batchSize  = 1;
            cycleCount = 10;
            bigErrorHistory = zeros(batchCount * cycleCount, 1);
            for i = 1:batchCount
                exampleIndices = randperm(size(exampleList, 1), batchSize);
                errorHistory = obj.neuralPathwayLearner.train(cycleCount, exampleList(exampleIndices, :), target(exampleIndices));
                disp(['error' num2str(errorHistory(end))]);
                startIndex = 1 + (i - 1) * cycleCount;
                endIndex   = startIndex + cycleCount - 1;
                bigErrorHistory(startIndex:endIndex) = errorHistory(:);
            end
            figure
            plot(bigErrorHistory);
        end
        
        function testTrainWhatever(obj)
        end
        
        
        function [errorHistory, vis] = testTrainingSingleLayer(obj)
            recursionDepth = 1;
            nodeCount = 3;
            
            model = learning.NeuralPathwayLearner().initRandom(learning.NeuralPathwayLearner.kernelLibrary.tanh, nodeCount, .1, recursionDepth);
            
            learner = learning.NeuralPathwayLearner().initRandom(learning.NeuralPathwayLearner.kernelLibrary.tanh, nodeCount, 100, recursionDepth);
            
            trainingSetSize    = 2;
            trainingCycleCount = 10;
            
            trainingSetInput = rand(trainingSetSize, nodeCount);
            
            trainingSetOutput = model.produceOutput(trainingSetInput);
            trainingSetOutput = trainingSetOutput{end};
            trainingSetOutput = trainingSetOutput(:, 1);

            [errorHistory, networkHistory] = learner.train(trainingCycleCount, trainingSetInput, trainingSetOutput);
            
            % vis = visualization.NeuralPathwayLearner().init(networkHistory);
        end
        
        function performanceTest(obj, allInput, neuralMatrix)
            
            iterationCount = 40;
            
            outputHistory = cell(iterationCount);
            currentState = allInput;
            disp('beginning test');
            tic;
            for i = 1:40
                currentState = currentState * neuralMatrix; 
                
                outputHistory{i} = currentState;
            end
            toc;
        end
        
        function sparseInput = createSparseTestInput(obj, inputCount, inputSize)
            sparseInput = sparse([ones(inputCount,2) zeros(inputCount, inputSize - 2)]); 
            for i = 1:inputCount
                sparseInput(i, :) = sparseInput(i, randperm(inputSize));
                if (mod(i, 10000) == 0)
                    disp(['processed ' num2str(i) ' inputs']);
                end
            end
        end
        
        function normalInput = createNormalTestInput(obj, inputCount, inputSize)
            normalInput = [ones(inputCount,2) zeros(inputCount, inputSize - 2)]; 
            for i = 1:inputCount
                normalInput(i, :) = normalInput(i, randperm(inputSize));
                if (mod(i, 10000) == 0)
                    disp(['processed ' num2str(i) ' inputs']);
                end
            end
        end
        
        
        function pathwaySelection(obj)
            uniqueTargetIds = obj.targetData.computeUniqueTargetIds().keys();
            drugToTarget = obj.targetData.drugToTargetAsMap();
            kipcm = data.pathway.KeggInterPathwayConnectionMap().init(obj.thesauri.get('kegg'), Config.ALL_PATHWAY_PATH, drugToTarget);
            
            maxPathwayCombinationCount = 10;
            pathwayCombinations = cell(maxPathwayCombinationCount);
            for pathwayCombinationCount = 1:maxPathwayCombinationCount
                disp(datestr(now));
                disp(['combination count ' num2str(pathwayCombinationCount)]);
                bestPathwayCombination = kipcm.bestPathwayCombination(uniqueTargetIds, pathwayCombinationCount);
                pathwayCombinations(pathwayCombinationCount, 1:length(bestPathwayCombination)) = num2cell(bestPathwayCombination);
            end
            
            data.csvwrite(pathwayCombinations, IDEAL_PATHWAY_COMBINATIONS_FILE_PATH);
        end
        
        function dreamChallenge(obj)
            obj.init();
            
            [exampleList, target] = buildTrainingSet();
            
            obj.training(exampleList, target);
            
            obj.writeSynergyPredictionForInputFile(Config.DREAM_MONO_LEADER1, [Config.RESULTS_ROOT 'prediction_leader_test.csv']);            
            obj.writeSynergyPredictionForInputFile(Config.DREAM_MONO_TEST1,   [Config.RESULTS_ROOT 'prediction_mono_test.csv']);
        end
                
        function writeSynergyPredictionForInputFile(obj, inputFilePath, outputFilePath)
            requested = readtable(inputFilePath);
            cellLineIds = obj.thesauri.get('cellLine').getIds(requested.CELL_LINE);
            drugAIds = obj.thesauri.get('drug').getIds(requested.COMPOUND_A);
            drugBIds = obj.thesauri.get('drug').getIds(requested.COMPOUND_B);
            
            SYNERGY = obj.predictSynergyForSet(cellLineIds, drugAIds, drugBIds);
            
            CELL_LINE = requested.CELL_LINE;
            COMPOUND_A = requested.COMPOUND_A;
            COMPOUND_B = requested.COMPOUND_B;
            
            predictionTable = table(CELL_LINE, COMPOUND_A, COMPOUND_B, SYNERGY);
            
            writetable(predictionTable, outputFilePath);
        end
        
        
        function synergySet = predictSynergyForSet(obj, cellLineIds, drugAIds, drugBIds)

            synergySet = zeros(size(cellLineIds));
            
            for i = 1:length(cellLineIds)
                cellLineId = cellLineIds(i);
                drugAId    = drugAIds(i);
                drugBId    = drugBIds(i);
                
                synergySet(i) = obj.predictSynergy(cellLineId, drugAId, drugBId);
                
            end
        end
        
        function synergy = predictSynergy(obj, cellLineId, drugAId, drugBId)
            
                
            dosagesA = obj.doseLethalityData.getDosageLevels(cellLineId, drugAId);
            dosagesB = obj.doseLethalityData.getDosageLevels(cellLineId, drugBId);
            
            combinationMatrix = zeros(length(dosagesA), length(dosagesB));
            
            cellLineMutationAndExpressionData = obj.createExampleWithJustCellLineMutationAndExpression(cellLineId);

            for i = 1:length(dosagesA)
            for j = 1:length(dosagesB)
                
                dosageA = dosagesA(i);
                dosageB = dosagesB(j);
                
                drugDosagePairs = [drugAId dosageA ; drugBId, dosageB];
                
                drugData   = obj.trainingSetBuilder.createExample(drugDosagePairs);
                example = cellLineMutationAndExpressionData + drugData;
                
                inputSet = example;
                
                outputArray = obj.neuralPathwayLearner.produceOutput(inputSet);
                finalOutput = outputArray{end};
                survivalRate   = 100 * (1 - finalOutput(1));

                combinationMatrix(i, j) = survivalRate;
            end
            end
            dr = chemistry.dream.Experiment().init(dosagesA, dosagesB, combinationMatrix);
            synergy = dr.synergy;
        end
        
        function run(obj, resultTracker)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'IntraPathwayAnalysisController run']);
            
            exampleThroughputPerTrainingFold = Config.EXAMPLE_THROUGHPUT_PER_TRAINING;
            foldCount                        = Config.FOLD_COUNT;
            
            recursionDepthCompactionLevelCombinations = [
                1 8;
                2 2;
                8 1;
                8 8
            ];
            
            for combination = size(recursionDepthCompactionLevelCombinations, 1)
            % for recursionDepth = [1, 25, 8]
            for proportionalBatchSize = [.25]%[0, .0625, 1]
            for missingLinkInference  = [0]
            % for linkCompactionLevel   = [1, 2, 8]
                recursionDepth = recursionDepthCompactionLevelCombinations(combination, 1);
                linkCompactionLevel = recursionDepthCompactionLevelCombinations(combination, 2);
                
                % sigmoid
                experimentId = ['intrapathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_missingLinkInference_' num2str(missingLinkInference) '_linkCompactionLevel_' num2str(linkCompactionLevel) '_activation_sigmoid'];
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'IntraPathwayAnalysisController run at ' experimentId]);
                
                obj.initNeuralPathwayLearnerWithIncreasedLinkCount(learning.NeuralPathwayLearner.kernelLibrary.sigmoid, linkCompactionLevel, missingLinkInference, recursionDepth, proportionalBatchSize);     
                
                obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
                
                % tanh    
                experimentId = ['intrapathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_missingLinkInference_' num2str(missingLinkInference) '_linkCompactionLevel_' num2str(linkCompactionLevel) '_activation_tanh'];
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'IntraPathwayAnalysisController run at ' experimentId]);
                
                obj.initNeuralPathwayLearnerWithIncreasedLinkCount(learning.NeuralPathwayLearner.kernelLibrary.tanh, linkCompactionLevel,    missingLinkInference, recursionDepth, proportionalBatchSize);
                
                obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
                
                % linear
                experimentId = ['intrapathwayAnalysis_recursion_' num2str(recursionDepth) '_proportionalBatchSize_' num2str(proportionalBatchSize) '_missingLinkInference_' num2str(missingLinkInference) '_linkCompactionLevel_' num2str(linkCompactionLevel) '_activation_linear'];
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'IntraPathwayAnalysisController run at ' experimentId]);
                
                obj.initNeuralPathwayLearnerWithIncreasedLinkCount(learning.NeuralPathwayLearner.kernelLibrary.linear, linkCompactionLevel,  missingLinkInference, recursionDepth, proportionalBatchSize);
                
                obj.crossValidationExperiment(experimentId, resultTracker, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold);
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'IntraPathwayAnalysisController completed loop ' experimentId]);
                
            % end
            end
            end
            % end
            end
        end
    end
    
end

