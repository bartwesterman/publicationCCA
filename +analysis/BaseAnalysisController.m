classdef BaseAnalysisController < handle
    %BASEANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesauri;
        doseLethalityData;
        
        trainingSetBuilder;
        expressionData;
        mutationData;
        
        exampleSet;
        targetSet;
        
        trainingExampleSet;
        trainingTargetSet;
        
        testExampleSet;
        testTargetSet;
    end
    
    methods
        function initThesauri(obj)
            disp('initThesauri()');
            obj.thesauri = data.EntityManager().init();
            
            for i = 1:length(Config.THESAURI_NAMES)
                type = Config.THESAURI_NAMES{i};
                synonymArrayArray = data.thsread([Config.THESAURI_PATH type '.ths']);
                obj.thesauri.unsafeThesaurusInsert(type, synonymArrayArray);
            end
            
            pathwayFiles = dir([Config.SELECTED_PATHWAY_PATH '*.xml']);

            obj.expandThesaurusFromKGML(pathwayFiles);
        end
        
        function expandThesaurusFromKGML(obj, kgmlFilePathArray)
            for i = 1:length(kgmlFilePathArray)
                nextKgmlFilePath = kgmlFilePathArray(i).name;
                
                domTree = xmlread([Config.SELECTED_PATHWAY_PATH nextKgmlFilePath]);
                
                entries = domTree.getElementsByTagName('entry');
               
                for j = 0:(entries.getLength() - 1)
                    entry = entries.item(j);
                    
                    keggIds = strsplit(char(entry.getAttribute('name')), ' ');
                    
                    obj.thesauri.mergeSynonymArrayInsert('kegg', keggIds);
                end
            end
        end
        
        function initDoseLethalityData(obj)
            disp('initDoseLethalityData()');            
            obj.doseLethalityData = data.DreamDrugDoseLethalityData().init(obj.thesauri);
        end
        
        function initExpressionData(obj)
            disp('initExpressionData()');
            obj.expressionData = data.DreamGeneExpression().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'));
        end
        
        function initMutationData(obj)
            disp('initMutationData()');
            obj.mutationData = data.DreamMutation().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'));
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
            exampleList(:, 1) = 0;
            
            maxValuePerColumn = max(abs(exampleList));
            maxValuePerColumn(maxValuePerColumn == 0) = 1; % we need to eliminate 0s so we do not get NaNs
            exampleList = sparse(exampleList ./ maxValuePerColumn);
            
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
        
        function exampleList = createExampleListForCellLineWithExpression(obj, cellLineId)
            
            cellLineData = obj.createExampleWithJustCellLineAndExpression(cellLineId);
            
            rawExampleList = obj.doseLethalityData.exampleListForCellLine(cellLineId);
            
            exampleList = cellfun(@(x) obj.trainingSetBuilder.createExample(x) + cellLineData, rawExampleList, 'UniformOutput', false);
            exampleList = vertcat(exampleList{:});
        end
        
        function example = createExampleWithJustCellLineAndExpression(obj, cellLineId) % remove mutations and refactor names accordingly

            cellLineAndExpression = [obj.expressionData.getCellLineExpression(cellLineId); cellLineId 1];
            
            cellLineExpressionToExample = obj.trainingSetBuilder.createExample(cellLineAndExpression);
            
            example = cellLineExpressionToExample; % cellLineMutationToExample +
        end
        
        % old untested code
        function example = createExampleWithJustCellLineMutationAndExpression(obj, cellLineId)
            cellLineMutation = obj.mutationData.getCellLineMutations(cellLineId);
            
            cellLineMutation = [cellLineMutation -100 * ones(size(cellLineMutation))]; % create an example vector of entityId -100
            % i.e. each gene with a cellLineMutation is associated with a
            % value of -100
            cellLineExpression = obj.expressionData.getCellLineExpression(cellLineId);
             
            cellLineMutationToExample   = obj.trainingSetBuilder.createExample(cellLineMutation);
            cellLineExpressionToExample = obj.trainingSetBuilder.createExample(cellLineExpression);
            
            example = cellLineMutationToExample + cellLineExpressionToExample;
         end
        
        function [trainingExampleList, trainingTarget, validationExampleList, validationTarget] = exampleSetToTrainingValidation(obj, exampleList, target, trainingSetProportion)
            exampleCount = length(exampleList);
            
            trainingSetSize   = floor(trainingSetProportion * exampleCount);
            
            trainingIndexes   = randsample(1:exampleCount, trainingSetSize);
            validationIndexes = ones(size(target));
            validationIndexes(trainingIndexes) = false;
            validationIndexes = validationIndexes ~= 0;
            
            trainingExampleList = exampleList(trainingIndexes, :);
            trainingTarget      = target(trainingIndexes, :);
            
            validationExampleList = exampleList(validationIndexes, :);
            validationTarget = target(validationIndexes, :);
        end
        
        function [trainingExampleList, trainingTarget, validationExampleList, validationTarget] = exampleSetToCrossValidationFold(obj, exampleList, target, trainingSetProportion, foldCount, currentFoldIndex)
            exampleCount = length(exampleList);
            
            trainingSetSize   = floor(trainingSetProportion * exampleCount);
            
            firstExampleIndexCurrentFold = 1 + floor(exampleCount / foldCount) * (currentFoldIndex - 1);
            
            trainingIndexes   = firstExampleIndexCurrentFold:(firstExampleIndexCurrentFold + trainingSetSize - 1);
            trainingIndexes(trainingIndexes > exampleCount) = trainingIndexes(trainingIndexes > exampleCount) - exampleCount;
            
            validationIndexes = ones(size(target));
            validationIndexes(trainingIndexes) = false;
            validationIndexes = validationIndexes ~= 0;
            
            trainingExampleList = exampleList(trainingIndexes, :);
            trainingTarget      = target(trainingIndexes, :);
            
            validationExampleList = exampleList(validationIndexes, :);
            validationTarget = target(validationIndexes, :);
        end
        
        
        function basicPerformanceReport(obj, description, path, propertyCount, prediction, target)
 
            pearsonCorrelation = corr(target, prediction);
            
            r2 = statistics.r2(prediction, target);
            adjustedR2 = statistics.adjustedR2(prediction, target, propertyCount);
            
            reportContent = table({description}, pearsonCorrelation, r2, adjustedR2);
            
            writetable(reportContent, [path description '.csv']);
        end
        
        
        function [rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2] = performanceMetrics(obj, propertyCount, prediction, target)
            pearsonCorrelation = corr(utils.verticalizeVector(target), utils.verticalizeVector(prediction));
            
            r2 = statistics.r2(prediction, target);
            adjustedR2 = statistics.adjustedR2(prediction, target, propertyCount);
            
            error = target - prediction;
            rootMeanSquaredError = sqrt(mean(error .* error));
        end
        
        function basicExperiment(obj)
            obj.init();
            [exampleList, target] = obj.buildTrainingSet(); 
            
            [trainingExampleList, trainingTarget, validationExampleList, validationTarget] =...
                obj.exampleSetToTrainingValidation(exampleList, target, .7);
                        
            obj.training(trainingExampleList, trainingTarget);
            
            prediction = obj.generatePrediction(validationExampleList);
            
            propertyCount = size(validationExampleList, 2);
            
            obj.basicPerformanceReport(strrep(['basicIntraPathwayExperiment_' datestr(now)], ' ', '_'), Config.RESULTS_ROOT, propertyCount, prediction, validationTarget);
        end
        
        function finalValidationExperiment(obj, resultTracker, parameters, proportionalBatchSize, exampleThroughputPerTraining, trainingCycleCount)
            trainingExampleList = obj.trainingExampleSet;
            trainingTargetSet   = obj.trainingTargetSet;
            
            propertyCount       = size(trainingExampleList, 2);
            exampleCount        = size(trainingExampleList, 1);

            batchSize = round(proportionalBatchSize * exampleCount);
            
            if batchSize == 0
                batchSize = 1;
            end
            
            for j = 1:trainingCycleCount
                obj.trainingStep(trainingExampleList, trainingTargetSet, batchSize);
            end

            testExampleList = obj.testExampleSet;
            testTargetSet   = obj.testTargetSet;
            
            prediction = obj.generatePrediction(testExampleList);
                    
            [rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2] =...
                obj.performanceMetrics(propertyCount, prediction, testTargetSet);
            
            resultTracker.recordFinalResult(parameters, rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2, utils.deepCopy(obj.neuralPathwayLearner));
        end
        
        function crossValidationExperiment(obj, experimentId, resultTracker, parameters, foldCount, proportionalBatchSize, exampleThroughputPerTrainingFold)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController crossValidationExperiment ' experimentId]);
            
            % get full trainingset
            if (isempty(obj.exampleSet) || isempty(obj.targetSet))
                [exampleList, target] = obj.buildTrainingSet();     
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController crossValidationExperiment built training set' experimentId]);
            end
            exampleList = obj.trainingExampleSet;
            target      = obj.trainingTargetSet;
            
            exampleCount        = size(exampleList, 1);
            
            % process paramters
            batchSize = round(proportionalBatchSize * exampleCount);
            
            if batchSize == 0
                batchSize = 1;
            end
            
            if batchSize > exampleThroughputPerTrainingFold
                batchSize = exampleThroughputPerTrainingFold;
                disp(['WARNING: batchSize is greater than the exampleThroughputPerTrainingFold. That means that only one training is done, and this training iteration is done, and it is done on exampleThroughputPerTrainingFold examples.']);
            end
            
            maxCycleCount = max(1, round(exampleThroughputPerTrainingFold / batchSize));
            
            % parameter for performance metrics
            propertyCount = size(exampleList, 2);
                        
            % measure performance for each cross validation fold
            for i = 1:foldCount
                % prepare label in result tracker
                experimentIdForFold = [experimentId num2str(i)];
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController fold ' experimentIdForFold]);
                
                if ~resultTracker.startIfUnassigned(experimentIdForFold)
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController already assigned ' experimentIdForFold]);
                    
                    continue;
                end
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController unassigned ' experimentIdForFold]);
                
                % prepare parameters for result tracker
                bestPearson         = 0;
                bestPearsonTC       = -1;
                bestR2                = -Inf;
                bestR2TC              = -1;
                bestAdjustedR2        = -Inf;
                bestAdjustedR2TC      = -1;
                bestRootMeanSquared   = Inf;
                bestRootMeanSquaredTC = -1;
                
                historyElementCounter   = 0;
                
                % to decide when to validate keep track of how many
                % examples have been processed, and when the next
                % validation should take place

                examplesProcessedSoFar = 0;
                examplesPerValidationPhase = exampleThroughputPerTrainingFold / 20;                
                validateAtExampleCount = 0;
                
                historySize    = obj.computeSizeOfValidationResultArrays(maxCycleCount, batchSize, examplesPerValidationPhase);
                learnerHistory = cell(historySize,1);
                errorHistory   = zeros(historySize, 1);
                
                [trainingExampleList, trainingTarget, validationExampleList, validationTarget] =...
                    obj.exampleSetToCrossValidationFold(exampleList, target, 1 - 1/foldCount, foldCount, i);
            
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController entering loop ' experimentIdForFold ' maxCycleCount ' num2str(maxCycleCount)]);
                obj.initLearnerWithCurrentParameters();
                for j = 1:maxCycleCount
                    if j > 1 % make sure that the first validation is without training
                        obj.trainingStep(trainingExampleList, trainingTarget, batchSize);
                    end
                    
                    examplesProcessedSoFar = examplesProcessedSoFar + batchSize;
                    
                    if j ~= maxCycleCount && examplesProcessedSoFar < validateAtExampleCount
                        continue;
                    end
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController validating ' experimentIdForFold ' loop iteration ' num2str(j)]);
                    
                    validateAtExampleCount = validateAtExampleCount + examplesPerValidationPhase;
%                     
%                     if ~(obj.mustValidate(j) || j == maxCycleCount)
%                         continue;
%                     end
                    

                    validationIndexes = randperm(size(validationExampleList, 1));
                    validationIndexes = validationIndexes(1:min(Config.EXAMPLES_PER_VALIDATION, end));
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController generating prediction ' experimentIdForFold ' loop iteration ' num2str(j)]);

                    prediction = obj.generatePrediction(validationExampleList(validationIndexes, :));
                    
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController prediction made ' experimentIdForFold ' loop iteration ' num2str(j)]);
                    
                    [rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2] =...
                        obj.performanceMetrics(propertyCount, prediction, validationTarget(validationIndexes));
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController performance measured ' experimentIdForFold ' loop iteration ' num2str(j)]);

                    
                    if rootMeanSquaredError < bestRootMeanSquared
                        bestRootMeanSquared = rootMeanSquaredError;
                        bestRootMeanSquaredTC = j;
                    end
                    
                    if ~isnan(pearsonCorrelation) && (abs(pearsonCorrelation) > abs(bestPearson) || bestPearson == 0)
                        bestPearson   = pearsonCorrelation;
                        bestPearsonTC = j;
                    end
                    
                    if r2 > bestR2
                        bestR2   = r2;
                        bestR2TC = j;
                    end
                    if adjustedR2 > bestAdjustedR2
                        bestAdjustedR2   = adjustedR2;
                        bestAdjustedR2TC = j;
                    end
                    historyElementCounter = historyElementCounter + 1;
                    learnerCopy = utils.deepCopy(obj.getLearner());
                    
                    learnerHistory{historyElementCounter} = learnerCopy;
                    errorHistory(historyElementCounter)   = rootMeanSquaredError;
                    
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController determined highest performance metrics so far ' experimentIdForFold ' loop iteration ' num2str(j)]);
                    if j == 1 % make sure that the first validation is without training
                        obj.trainingStep(trainingExampleList, trainingTarget, batchSize);
                    end
                end
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController loop completed ' experimentIdForFold]);
                
                resultTracker.recordResult(experimentId, parameters, experimentIdForFold, i, bestRootMeanSquared, bestRootMeanSquaredTC, bestPearson, bestPearsonTC, bestR2, bestR2TC, bestAdjustedR2, bestAdjustedR2TC, maxCycleCount, learnerHistory, errorHistory);
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'BaseAnalysisController result recorded ' experimentIdForFold]);

            end
            
        end
        
        function s = computeSizeOfValidationResultArrays(obj, maxCycleCount, batchSize, examplesPerValidationPhase)
            s = 0;
            examplesProcessedSoFar = 0;
            validateAtExampleCount = 0;

            for j = 1:maxCycleCount
                    
                    examplesProcessedSoFar = examplesProcessedSoFar + batchSize;
                    if j ~= maxCycleCount && examplesProcessedSoFar < validateAtExampleCount
                        continue;
                    end
                    validateAtExampleCount = validateAtExampleCount + examplesPerValidationPhase;

                    s = s + 1;
            end
        end
        
        function learner = getLearner(obj)
            learner = {};
        end
        
        function isTrue = mustValidate(obj, i)
            isTrue = true;
            
            if i < 10
                return;
            end
            
            if i >= 10 && i < 25 && mod(i, 3) == 0
                return
            end
            
            if i >= 25 && i < 60 && mod(i, 5) == 0
                return;
            end
            
            if i >= 60 && i < 120 && mod(i, 10) == 0
                return;
            end
            
            if i >= 120 && i < 1000 && mod(i, 25) == 0
                return;
            end
            
            if i >= 1000 && i < 10000 && mod(i, 50) == 0
                return;
            end
            
            if i >= 10000 && mod(i, 100) == 0
                return;
            end
            
            isTrue = false;
            
            return;
        end
        
    end
    
end

