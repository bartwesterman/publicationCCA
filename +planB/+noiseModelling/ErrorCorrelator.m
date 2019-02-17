classdef ErrorCorrelator < handle
    %ERRORCORRELATOR Summary of this class goes here
    %   Detailed explanation goes here

    properties
    	errorTable;
    end

    methods

    	function [lethalityPredictionMatrix, lethalityErrorMatrix, lethalityCorrectMatrix] = getErrorTableRow(obj, exampleId, lethalityTestSet, lethalityResult)
    		[lethalityCorrectMatrix, ~, ~, lethalityCorrectIndeces] = lethalityTestSet.getSubExampleAsDoseResponseData(exampleId);
            lethalityPredictionMatrix = zeros(6);
    		lethalityPredictionMatrix(:) = lethalityResult.prediction{1}(lethalityCorrectIndeces(:));
    		lethalityErrorMatrix = lethalityPredictionMatrix - lethalityCorrectMatrix;
    	end


    	function [lethalityPredictionMatrices, lethalityErrorMatrices, synergyVector, synergyErrorVector] =...
                getErrorTableMatricesFromResults(obj, lethalityResult, lethalityTestSet, convertedResult, synergyTestSet)

    		synergyVector = convertedResult.correct{1};
    		synergyErrorVector = convertedResult.prediction{1} - convertedResult.correct{1};

    		lethalityPredictionMatrices = cell(size(synergyVector,1),1);
    		lethalityErrorMatrices = cell(size(synergyVector,1),1);

    		lethalityCorrectMatrices = cell(size(synergyVector,1),1);

    		for i = 1:size(synergyTestSet.exampleIds, 1)
    			exampleId = synergyTestSet.exampleIds(i);

    			[lethalityPredictionMatrices{i}, lethalityErrorMatrices{i}, lethalityCorrectMatrices{i}] = obj.getErrorTableRow(exampleId, lethalityTestSet, lethalityResult);
    		end
    	end

    	function obj = initFromResults(obj, lethalityResultFilePath, lethalityTestSetFilePath, convertedResultFilePath, synergyTestSetFilePath)

    		load(lethalityResultFilePath, 'result');
    		lethalityResult = result;
    		load(convertedResultFilePath, 'result');
    		convertedResult = result;

    		load(lethalityTestSetFilePath, 'exampleSet');
    		lethalityTestSet = exampleSet;

    		load(synergyTestSetFilePath, 'exampleSet');
    		synergyTestSet = exampleSet;

		    [lethalityPredictionMatrices, lethalityErrorMatrices, synergyVector, synergyErrorVector] = ...
                obj.getErrorTableMatricesFromResults(lethalityResult, lethalityTestSet, convertedResult, synergyTestSet);

    		obj.initErrorTable(lethalityPredictionMatrices, lethalityErrorMatrices, synergyVector, synergyErrorVector);
    	end

    	function obj = initErrorTable(obj, lethalityMatrix, lethalityErrorMatrix, synergy, synergyError)
    		obj.errorTable = table(lethalityMatrix, lethalityErrorMatrix, synergy, synergyError);
        end
        
    	function errorCorrelationMatrix = computeErrorCorrelationMatrix(obj)

    		outputValues = obj.errorTable.synergyError;

    		errorCorrelationMatrix = zeros(6);

    		for x = 1:6
    		for y = 1:6
    			inputValues = obj.extractLethalityErrorColumn(x, y);
    			errorCorrelationMatrix(x,y) = corr(inputValues, outputValues);
    		end
    		end
        end

    	function values = extractLethalityErrorColumn(obj, x, y)
    		values = zeros(height(obj.errorTable), 1);

    		for i = 1:height(obj.errorTable)
    			m = obj.errorTable.lethalityErrorMatrix{i};

    			values(i) = m(x,y);
    		end
        end
        
        function flattenedExamples = flattenMatrixCellArray(obj, matrixCellArray)
            flattenedExamples = zeros(length(matrixCellArray), 6 * 6);
            
            for i = 1:height(obj.errorTable)
                m = matrixCellArray{i};
                flattenedExamples(i, :) = m(:);
            end 
        end
        
        function [hiddenFeatureColumns, hiddenFeatureVariance] = hiddenLethalityErrorFeatures(obj)
            flattenedExamples = obj.flattenMatrix(obj.errorTable.lethalityErrorMatrix);
            [hiddenFeatureColumns, ~, hiddenFeatureVariance] = pca(flattenedExamples);            
        end
        
        function [hiddenFeatureColumns, hiddenFeatureVariance] = hiddenCombinationExampleSetFeatures(obj, combinationExampleSetFilePath, synergyExampleSetFilePath)
            
            load(combinationExampleSetFilePath, 'exampleSet');
            combinationExampleSet = exampleSet;
            
            load(synergyExampleSetFilePath, 'exampleSet');
            synergyExampleSet = exampleSet;
            
            flattenedExamples = obj.flattenMatrix(obj.toCombinationMatrixArray(combinationExampleSet, synergyExampleSet));
            [hiddenFeatureColumns, ~, hiddenFeatureVariance] = pca(flattenedExamples);  
        end
        
        function combinationMatrixArray = toCombinationMatrixArray(obj, combinationExampleSet, synergyExampleSet)
                        
            combinationMatrixArray = cell(size(synergyExampleSet.exampleIds, 1),1);
    		for i = 1:size(synergyExampleSet.exampleIds, 1)
    			exampleId = synergyExampleSet.exampleIds(i);

    			[combinationMatrixArray{i}] = combinationExampleSet.getSubExampleAsDoseResponseData(exampleId);
    		end
    	end
        
        
        function h = drawHeatMapOfFlattenedFeatureMatrix(obj, flattenedFeatureMatrix)
            featureMatrix = zeros(6);
            featureMatrix(:) = flattenedFeatureMatrix(:);
            
            h = HeatMap(featureMatrix);
        end
    end

end

