function totalSynergy = synergy( dosesA, dosesB, observedEffectMatrix, precision )
%DREAMSYNERGY Summary of this function goes here
%   Detailed explanation goes here

    effectOnlyA = observedEffectMatrix(:,1);
    effectOnlyB = observedEffectMatrix(1,:);
    
    paramsA = ec50(dosesA, effectOnlyA);
    paramsB = ec50(dosesB, effectOnlyB');

    doseEffectConstantsA = struct('minVal', paramsA(1), 'maxVal', paramsA(2), 'ic50', paramsA(3), 'hillSlope', paramsA(4));
    doseEffectConstantsB = struct('minVal', paramsB(1), 'maxVal', paramsB(2), 'ic50', paramsB(3), 'hillSlope', paramsB(4));
    
    doseEffectConstantsA.minVal = 0;
    doseEffectConstantsB.minVal = 0;
    doseEffectConstantsA.maxVal = 100;
    doseEffectConstantsB.maxVal = 100;
    
    doseEffectConstantsB.ic50 = 34.8;
    doseEffectConstantsB.hillSlope = .554;
    
    doseEffectConstantsA.ic50 = 0.020731106;
    doseEffectConstantsA.hillSlope = 2.0999805;
    
    additiveEffectMatrix = chemistry.constructAdditiveMatrix(doseEffectConstantsA, doseEffectConstantsB, dosesA, dosesB, precision);
    
    synergyMatrix = observedEffectMatrix - additiveEffectMatrix ;
    
    totalSynergy = 0;
    
    for aIndex = 1:length(dosesA)
        lowATileCorner = 0;
        if aIndex > 1
            lowATileCorner = highATileCorner;
        end
        
        highATileCorner = dosesA(aIndex);
        if aIndex < length(dosesA)
            highATileCorner = (dosesA(aIndex) + dosesA(aIndex + 1)) / 2;
        end
        
        for bIndex = 1:length(dosesB)
            lowBTileCorner = 0;
            if bIndex > 1
                lowBTileCorner = highBTileCorner;
            end

            highBTileCorner = dosesB(bIndex);
            if bIndex < length(dosesB)
                highBTileCorner = (dosesB(bIndex) + dosesB(bIndex + 1)) / 2;
            end
            
            aLength = (highATileCorner - lowATileCorner);
            bLength = (highBTileCorner - lowBTileCorner);
            surfaceArea = aLength * bLength;
            % logSurfaceArea = log(aLength) * log(bLength);
            % logALength = log(highATileCorner) / log(2) - log(lowATileCorner) / log(2);
            % logBLength = log(highBTileCorner) / log(2) - log(lowBTileCorner) / log(2);
            
            %logSurfaceArea = logALength * logBLength;
            
            totalSynergy = totalSynergy + synergyMatrix(aIndex, bIndex) / surfaceArea;
        end
    end
        
end

