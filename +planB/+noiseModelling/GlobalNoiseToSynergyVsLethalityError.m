classdef GlobalNoiseToSynergyVsLethalityError
    %GLOBALNOISETOSYNERGYVSLETHALITYERROR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods

        function [lethalityPerformances, synergyPerformances] = runAnalysis(obj, lethalityExampleSetFilePath, synergyExampleSetFilePath, levels)
            load(lethalityExampleSetFilePath, 'exampleSet');
    		lethalityExampleSet = exampleSet;

    		load(synergyExampleSetFilePath, 'exampleSet');
    		synergyExampleSet = exampleSet;
            
            [lethalityPerformances, synergyPerformances] = obj.analyzePerformanceAfterNoise(lethalityExampleSet, synergyExampleSet, levels);
            figure;
            hold on;
            plot(lethalityPerformances);
            plot(synergyPerformances);
            hold off;
        end
        
        function [lethalityPerformances, synergyPerformances] = analyzePerformanceAfterNoise(obj, lethalityExampleSet, synergyExampleSet, levels)
            lethalityPerformances = zeros(length(levels), 1);
            synergyPerformances = zeros(length(levels), 1);
            
            for i = 1:length(levels)
                noiseSigma = levels(i);
                [synergyResult, lethalityResult] = obj.computeNoiseImpact(lethalityExampleSet, synergyExampleSet, noiseSigma);
                lethalityPerformances(i) = lethalityResult.pearsonCorrelation;
                synergyPerformances(i) = synergyResult.pearsonCorrelation;
            end
        end
        
        function [synergyResult, lethalityResult] = computeNoiseImpact(obj, lethalityExampleSet, synergyExampleSet, noiseSigma)
            lethalityOutput = lethalityExampleSet.getOutput();
            lethalityOutput = lethalityOutput + normrnd(0, noiseSigma, size(lethalityOutput, 1), 1);
            
            lethalityResult = lethalityExampleSet.analyzePerformance(lethalityOutput);
            
            synergyPrediction = obj.convertLethalityToSynergy(lethalityResult, lethalityExampleSet, synergyExampleSet);
            
            synergyResult = synergyExampleSet.analyzePerformance(synergyPrediction);
        end
        
        
        function synergy = synergyForExampleId(obj, exampleId, lethalityTestSet, lethalityResult)
    		[lethalityCorrectMatrix, dosesA, dosesB, lethalityCorrectIndices] = lethalityTestSet.getSubExampleAsDoseResponseData(exampleId);
            m = zeros(6);
            m(:) = lethalityResult.prediction{1}(lethalityCorrectIndices(:));
            synergy = obj.computeSynergy(dosesA, dosesB, (-m + 1) * 100);
    	end


    	function synergy =...
                convertLethalityToSynergy(obj, lethalityResult, lethalityTestSet, synergyTestSet)

            synergy = zeros(size(synergyTestSet.exampleIds, 1),1);
    		for i = 1:size(synergyTestSet.exampleIds, 1)
    			exampleId = synergyTestSet.exampleIds(i);

    			synergy(i) = obj.synergyForExampleId(exampleId, lethalityTestSet, lethalityResult);
    		end
    	end
        
        function s = computeSynergy(obj, dosesA, dosesB, responseMatrix)
            s = combenefit.doseMatrixToSynergyScore(dosesA, dosesB, responseMatrix);
        end
    end
    
end

