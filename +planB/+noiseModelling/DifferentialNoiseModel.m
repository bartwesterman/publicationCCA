classdef DifferentialNoiseModel
    %THEORETICALNOISEMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function [sumOfNoiseImpact, counter] = computeNoiseImpactOfHighQualityFiles(obj)
            highQualityFileNames = data.DreamDrugDoseLethalityData().findHighQualityFileNames(Config.DREAM_COMBINATIONS_PATH, Config.DREAM_MONO_AND_COMBINATION_TRAINING);
            disp(datestr(now));

            counter = 0;
            sumOfNoiseImpact = zeros(6);
            
            for i = 1:size(highQualityFileNames, 1)
                highQualityFileName = highQualityFileNames{i};
                [combinationMatrix, dosesA, dosesB] = obj.parseLethalityFile([Config.DREAM_COMBINATIONS_PATH highQualityFileName]);
                
                if isempty(combinationMatrix)
                    continue;
                end
                
                counter = counter + 1;
                if (mod(counter, 100) == 0)
                    disp(counter);
                    disp(datestr(now));
                end
                sumOfNoiseImpact = sumOfNoiseImpact + obj.computeNoiseImpact(dosesA, dosesB, combinationMatrix);
            end
        end
        
        function [combinationMatrix, dosesA, dosesB] = parseLethalityFile(obj, filePath)
            csvCellMatrix = data.csvread(filePath);
                 
            combinationMatrix = cellfun(@str2double, csvCellMatrix(2:7, 2:7));
            dosesA = cellfun(@str2double, csvCellMatrix(2:7, 1) );
            dosesB = cellfun(@str2double, csvCellMatrix(1, 2:7)');
            if (any(any(combinationMatrix < -.4)))
                combinationMatrix = [];
                dosesA = [];
                dosesB = [];
                return;
            end
            
            
        end
        
        function noiseImpactMatrix = computeNoiseImpact(obj, dosesA, dosesB, combinationMatrix)
            
            correctSynergy = obj.computeSynergy(dosesA, dosesB, combinationMatrix);
            
            noiseImpactMatrix = zeros(6); 
           
            for x = 1:6
            for y = 1:6
                increasedMatrix = combinationMatrix;
                increasedMatrix(x,y) = increasedMatrix(x,y) + 1;
                
                decreasedMatrix = combinationMatrix;
                decreasedMatrix(x,y) = decreasedMatrix(x,y) - 1;
                
                noiseImpactMatrix(x,y) = ...
                    abs(obj.computeSynergy(dosesA, dosesB, increasedMatrix) - correctSynergy) +...
                    abs(obj.computeSynergy(dosesA, dosesB, decreasedMatrix) - correctSynergy);
            end
            end
            

        end
        
        function s = computeSynergy(obj, dosesA, dosesB, responseMatrix)
            s = combenefit.doseMatrixToSynergyScore(dosesA, dosesB, responseMatrix);
        end
        
        function h = drawNoiseImpactMatrix(obj, noiseImpactMatrix)
            h = HeatMap(noiseImpactMatrix);
            h.Colormap = cool;
            h.Annotate = 'on';
        end
    end
    
end

