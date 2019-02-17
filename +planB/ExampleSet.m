classdef ExampleSet < handle
    %EXAMPLES Summary of this class goes here
    %   Detailed explanation goes here

    properties
        toEntityId;

        exampleMatrix;

        entityManager;

        exampleIds;

        combinationTable;
    end

    methods

        function obj = init(obj, toEntityId, exampleCount, entityManager)
            assert(size(toEntityId, 2) == 1, 'ExampleSet.init(toEntityId, exampleCount): toEntityId must be column vector');

            obj.toEntityId = toEntityId;
            obj.exampleMatrix   = zeros(exampleCount, size(toEntityId, 1));
            obj.entityManager = entityManager;

            obj.exampleIds = zeros(exampleCount, 1);

            drugAId    = zeros(exampleCount, 1);
            drugBId    = zeros(exampleCount, 1);
            cellLineId = zeros(exampleCount, 1);

            obj.combinationTable = table(cellLineId, drugAId, drugBId);
        end

        function obj = initByMatrix(obj, toEntityId, exampleMatrix, entityManager, exampleIds, combinationTable)

            obj.toEntityId = toEntityId;
            obj.exampleMatrix = exampleMatrix;
            obj.entityManager = entityManager;
            obj.exampleIds    = exampleIds;
            exampleCount = size(exampleMatrix,1);
%             drugAId    = zeros(exampleCount, 1);
%             drugBId    = zeros(exampleCount, 1);
%             cellLineId = zeros(exampleCount, 1);

            obj.combinationTable = combinationTable; %table(cellLineId, drugAId, drugBId);
        end

        function obj = initCopy(obj, original)
            obj.initByMatrix(original.toEntityId, original.exampleMatrix, original.entityManager, original.exampleIds, original.combinationTable);
        end

        function addToExampleMatrixRow(obj, rowIndex, entityIds, values, exampleId, cellLineId, drugAId, drugBId)
            exampleMatrixRow = obj.createExampleMatrixRow(entityIds, values);

            obj.exampleMatrix(rowIndex, :) = obj.exampleMatrix(rowIndex, :) + exampleMatrixRow;

            if exist('exampleId','var')
                obj.exampleIds(rowIndex, 1) = exampleId;
            end

            if exist('cellLineId','var') && exist('drugAId','var') && exist('drugBId','var')
                obj.combinationTable.cellLineId(rowIndex) = cellLineId;
                obj.combinationTable.drugAId(rowIndex) = drugAId;
                obj.combinationTable.drugBId(rowIndex) = drugBId;
            end

            obj.combinationTable.cellLineId(rowIndex) = cellLineId;
            obj.combinationTable.drugAId(rowIndex) = drugAId;
            obj.combinationTable.drugBId(rowIndex) = drugBId;
        end

        function exampleMatrixRow = createExampleMatrixRow(obj, entityIds, values)
            [existsInEntityIds, atPosition] = ismember(entityIds, obj.toEntityId);

            relevantPositions = atPosition(existsInEntityIds);

            exampleMatrixRow = zeros(1, length(obj.toEntityId));
            exampleMatrixRow(relevantPositions) = values(existsInEntityIds);
        end

        function exampleSet = filterEntityIds(obj, importantEntityIds)

            assert(size(importantEntityIds, 2) == 1, 'ExampleSet.filterEntityIds(importantEntityIds): importantEntityIds should be column vector');

           [isInExamples, importantEntityIdIndexToLocalIndex] = ismember(importantEntityIds, obj.toEntityId);

           filteredEntityIds       = importantEntityIds(isInExamples);
           filteredEntityIdIndexes = importantEntityIdIndexToLocalIndex(isInExamples);

           filteredExampleMatrix = obj.exampleMatrix(:, filteredEntityIdIndexes);

           exampleSet = planB.ExampleSet().init(filteredEntityIds, size(obj.exampleMatrix, 1), obj.entityManager);

           exampleSet.exampleMatrix = filteredExampleMatrix;
           exampleSet.exampleIds = obj.exampleIds;
           exampleSet.combinationTable = obj.combinationTable;
        end


        function holdOutSplit = getHoldOutSplit(obj, testProportion, seed)
            if nargin < 3
                seed = 'shuffle';
            end

            if nargin < 2
                testProportion = Config.TEST_PROPORTION;
            end

            rng(seed);

            exampleCount = size(obj.exampleMatrix, 1);
            testSetCount = round(exampleCount * testProportion);

            testIndices = randsample(exampleCount, testSetCount);
            testIndices = ismember(1:exampleCount, testIndices);

            trainIndices = ~testIndices;

            holdOutSplit = struct();

            holdOutSplit.trainingSet = obj.selectRows(trainIndices);
            holdOutSplit.testSet     = obj.selectRows(testIndices);
            rng('shuffle');
        end

        function i = getInput(obj)
            i = obj.exampleMatrix(:, 2:end);
        end

        function o = getOutput(obj)
            o = obj.exampleMatrix(:, 1);
        end

        function inputEntityIds = getInputEntityIds(obj)
            inputEntityIds = obj.toEntityId(2:end);
        end

        function [labels, types] = getInputLabels(obj)
            inputEntityIds = obj.getInputEntityIds();

            [labels, types] = obj.entityManager.getLabels(inputEntityIds);
        end

        function [labels, types] = getLabels(obj)

            [labels, types] = obj.entityManager.getLabels(obj.toEntityId);
        end

        function outputEntityId = getOutputEntityId(obj)
            outputEntityId = obj.toEntityId(1);
        end

        % prediction is the output of the learner, obj is the test set used to
        % benchmark performance against
        function result = analyzePerformance(obj, prediction)
            correctVector = obj.getOutput();
            errorVector = prediction - correctVector;
            featureCount = size(obj.exampleMatrix, 2) - 1;

            rootMeanSquaredError   = sqrt(mean(errorVector .^2));
            meanAbsoluteError      = mean(abs(errorVector));
            relativeAbsoluteError  = sum(abs( full(errorVector))) / sum( abs( correctVector - mean(correctVector)));
            relativeSquaredError   = var(errorVector) / var(correctVector);
            pearsonCorrelation     = corr(prediction, correctVector);
            weightedPearson        = obj.getWeightedPearson(correctVector, prediction);

            combinationPerformance = {obj.getCombinationPerformance(correctVector, prediction)};
            cellLinePerformance    = {obj.getCellLinePerformance(correctVector, prediction)};
            drugPerformance        = {obj.getDrugPerformance(correctVector, prediction)};

            r2 = statistics.r2(prediction, correctVector);
            adjustedR2 = statistics.adjustedR2(prediction, correctVector, featureCount);

            prediction = {prediction};
            correct    = {correctVector};

            result = table(correct, prediction, featureCount, rootMeanSquaredError, meanAbsoluteError, relativeAbsoluteError, relativeSquaredError, pearsonCorrelation, r2, adjustedR2, weightedPearson, combinationPerformance, cellLinePerformance, drugPerformance);
        end

        function weightedPearson = getWeightedPearson(obj, output, prediction)
            drugAIdColumn = obj.combinationTable.drugAId;
            drugBIdColumn = obj.combinationTable.drugBId;
            sortedColumns = sort([drugAIdColumn drugBIdColumn], 2);
            [combinationGroups, drugAId, drugBId] = findgroups(sortedColumns(:, 1), sortedColumns(:, 2));

            predictionTable   = table(prediction, output);
            fullTable         = [predictionTable obj.combinationTable];
            [combinationCounts, pearsonCorrelation] = splitapply(@(prediction, output) deal(length(prediction), corr(prediction, output)), fullTable.prediction, fullTable.output, combinationGroups);

            indices = combinationCounts >= 2; % pearson correlations make no sense for cases with only 1 measurement point

            combinationCounts  = combinationCounts(indices);
            pearsonCorrelation = pearsonCorrelation(indices);

            weight = sqrt(combinationCounts - 1);

            weightedPearson = sum(weight .* pearsonCorrelation) / sum(weight);
        end

        function performanceTable = getCombinationPerformance(obj, output, prediction)
            drugAIdColumn = obj.combinationTable.drugAId;
            drugBIdColumn = obj.combinationTable.drugBId;
            sortedColumns = sort([drugAIdColumn drugBIdColumn], 2);
            [combinationGroups, drugAId, drugBId] = findgroups(sortedColumns(:, 1), sortedColumns(:, 2));
            predictionTable   = table(prediction, output);
            fullTable         = [predictionTable obj.combinationTable];
            [combinationCounts, pearsonCorrelation] = splitapply(@(prediction, output) deal(length(prediction), corr(prediction, output)), fullTable.prediction, fullTable.output, combinationGroups);

            drugALabel = obj.entityManager.getLabels(drugAId);
            drugBLabel = obj.entityManager.getLabels(drugBId);

            [~, indexOrder] = sort(-pearsonCorrelation);

            drugALabel         = drugALabel(indexOrder);
            drugBLabel         = drugBLabel(indexOrder);
            pearsonCorrelation = pearsonCorrelation(indexOrder);
            combinationCounts  = combinationCounts(indexOrder);
            drugAId            = drugAId(indexOrder);
            drugBId            = drugBId(indexOrder);

            performanceTable = table(drugALabel, drugBLabel, pearsonCorrelation, combinationCounts, drugAId, drugBId);
        end

        function performanceTable = getCellLinePerformance(obj, output, prediction)
            [combinationGroups, cellLineId] = findgroups(obj.combinationTable.cellLineId);

            [combinationCount, pearsonCorrelation] = splitapply(@(prediction, output) deal(length(prediction), corr(prediction, output)), prediction, output, combinationGroups);

            [~, indexOrder] = sort(-pearsonCorrelation);

            pearsonCorrelation = pearsonCorrelation(indexOrder);
            cellLineId         = cellLineId(indexOrder);
            combinationCount   = combinationCount(indexOrder);
            cellLineLabel      = obj.entityManager.getLabels(cellLineId);

            performanceTable = table(cellLineLabel, pearsonCorrelation, combinationCount, cellLineId);
        end

        function performanceTable = getDrugPerformance(obj, correctVector, prediction)

            drugIds = unique([obj.combinationTable.drugAId; obj.combinationTable.drugBId]);

            pearsonCorrelation = zeros(length(drugIds), 1);
            combinationCount   = zeros(length(drugIds), 1);
            for i = 1:length(drugIds)
                drugId = drugIds(i);
                selectedRows = (obj.combinationTable.drugAId == drugId) | (obj.combinationTable.drugBId == drugId);
                combinationCount(i) = sum(selectedRows);
                selectedPredictions = prediction(selectedRows);
                selectedOutput      = correctVector(selectedRows);
                pearsonCorrelation(i) = corr(selectedPredictions, selectedOutput);
            end

            [~, indexOrder] = sort(-pearsonCorrelation);

            drugId             = drugIds(indexOrder);
            drugLabel          = obj.entityManager.getLabels(drugId);
            pearsonCorrelation = pearsonCorrelation(indexOrder);
            combinationCount   = combinationCount(indexOrder);

            performanceTable = table(drugLabel, pearsonCorrelation, combinationCount, drugId);
        end

        function merged = concat(obj, exampleSet)
            assert(isequal(obj.entityManager, exampleSet.entityManager), 'planB.ExampleSet.merge() conflicting entityManagers');
            assert(isequal(obj.toEntityId, exampleSet.toEntityId),       'planB.ExampleSet.merge() conflicting entityId mapping');

            merged = planB.ExampleSet().initByMatrix(obj.toEntityId, [obj.exampleMatrix; exampleSet.exampleMatrix], obj.entityManager, [obj.exampleIds; exampleSet.exampleIds], [obj.combinationTable ; exampleSet.combinationTable]);
        end

        function types = indicesToTypes(obj, indices)
            [~, types] = obj.getLabels(obj.toEntityId(indices));
        end

        function entityIds = attributesOfType(obj, type)
            [~, types] = obj.getLabels();

            correctTypes = strcmp(types, type);

            entityIds = obj.toEntityId(correctTypes);
        end

        function entityIds = attributesExcludingType(obj, type)
            [~, types] = obj.getLabels();

            incorrectTypes = strcmp(types, type);

            entityIds = obj.toEntityId(~incorrectTypes);
        end

        function levels = getLevels(obj, entityId)
            [~, indices] = ismember(obj.toEntityId, entityId);
            values = obj.exampleMatrix(:, indices == 1);

            levels = sort(unique(values));
        end

        function indices = entityIdsToIndices(obj, entityIds)
            [~, indices] = ismember(entityIds, obj.toEntityId);
        end

        function exampleSet = getExampleSetWithAttributesGreaterThanZero(obj, entityIds)
            indices = obj.entityIdsToIndices(entityIds);

            relevantAttributesExampleMatrix    = obj.exampleMatrix(:, indices);
            relevantValuesOfRelevantAttributes = relevantAttributesExampleMatrix > 0;
            relevantRows                       = all(relevantValuesOfRelevantAttributes, 2);

            exampleSet = obj.selectRows(relevantRows);
%             relevantExampleMatrix = obj.exampleMatrix(relevantRows, :);
%             relevantExampleIds    = obj.exampleIds(relevantRows, 1);
%
%             exampleSet = planB.ExampleSet().initByMatrix(obj.toEntityId, relevantExampleMatrix, obj.entityManager, relevantExampleIds);
        end

        function [exampleSet, matchingIndices] = getExamplesByAttributesWithExactValue(obj, entityIds, values)
            indices = obj.entityIdsToIndices(entityIds);
            relevantAttributesExampleMatrix    = obj.exampleMatrix(:, indices);

            correctExampleValueMatrix = repmat(values', size(relevantAttributesExampleMatrix, 1), 1);

            matchingRows = all(relevantAttributesExampleMatrix == correctExampleValueMatrix, 2);

            exampleSet = obj.selectRows(matchingRows);
            matchingIndices = find(matchingRows);
%             matchingExampleMatrix = obj.exampleMatrix(matchingRows, :);
%             matchingExampleIds    = obj.exampleIds(matchingRows, 1);
%
%             exampleSet = planB.ExampleSet().initByMatrix(obj.toEntityId, matchingExampleMatrix, obj.entityManager, matchingExampleIds);
        end

        function [exampleSet, indices] = getSubExampleSetByExampleIds(obj, exampleIds)
            matchingRows = ismember(obj.exampleIds, exampleIds);

            exampleSet = obj.selectRows(matchingRows);
            indices = find(matchingRows);
%             matchingExampleIds    = obj.exampleIds(matchingRows, 1);
%             matchingExampleMatrix = obj.exampleMatrix(matchingRows,:);
%             exampleSet = planB.ExampleSet().initByMatrix(obj.toEntityId, matchingExampleMatrix, obj.entityManager, matchingExampleIds);
        end

        function [combinationMatrix, drugALevels, drugBLevels, indexMatrix] = getSubExampleAsDoseResponseData(obj, exampleId)
            % exampleId = obj.entityManager.get('exampleId').getId(exampleLabel);
            [subSet, subSetIndices] = obj.getSubExampleSetByExampleIds(exampleId);

            [cellLineId, drugAId, drugBId] = obj.getCombinationEntityIds(obj.entityManager.getLabel(exampleId));

            drugALevels = subSet.getLevels(drugAId);
            drugBLevels = subSet.getLevels(drugBId);

            combinationMatrix = zeros(size(drugALevels, 1), size(drugBLevels, 1));
            indexMatrix       = zeros(size(drugALevels, 1), size(drugBLevels, 1));

            for x = 1:size(drugALevels, 1)
            for y = 1:size(drugBLevels, 1)
                [row, indexMatrix(x,y)]  = subSet.getExamplesByAttributesWithExactValue([drugAId; drugBId], [drugALevels(x, 1); drugBLevels(y, 1)]);
                combinationMatrix(x, y) = row.getOutput();
                indexMatrix(x, y) = subSetIndices(indexMatrix(x, y));
            end
            end


        end

        function [cellLineId, drugAId, drugBId] = getCombinationEntityIds(obj, label)
            tokenizedLabel = strsplit(label, '@');

            cellLineName = tokenizedLabel{1};
            drugBName = tokenizedLabel{2};
            drugAName = tokenizedLabel{3};

            cellLineId = obj.entityManager.get('cellLine').getId(cellLineName);
            drugAId    = obj.entityManager.get('drug').getId(drugAName);
            drugBId    = obj.entityManager.get('drug').getId(drugBName);
        end

        function reducedExampleSet = getRandomSubSet(obj, reducedExampleCount)

            fullExampleCount     = obj.getExampleCount();

            if (fullExampleCount <= reducedExampleCount)
                reducedExampleSet = planB.ExampleSet().initCopy(obj);
                return;
            end

            selectedRowIndices   = randperm(fullExampleCount, reducedExampleCount);

            reducedExampleSet = obj.selectRows(selectedRowIndices);
        end

        function subSet = selectRows(obj, selectedRowIndices)

            reducedExampleMatrix    = obj.exampleMatrix(selectedRowIndices, :);
            reducedExampleIds       = obj.exampleIds(selectedRowIndices);
            reducedCombinationTable = obj.combinationTable(selectedRowIndices, :);

            subSet = planB.ExampleSet().initByMatrix(obj.toEntityId, reducedExampleMatrix, obj.entityManager, reducedExampleIds, reducedCombinationTable);
        end

        function c = getExampleCount(obj)
            c = size(obj.exampleMatrix,1);
        end
    end

end

