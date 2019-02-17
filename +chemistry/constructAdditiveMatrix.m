function additiveMatrix = constructAdditiveMatrix(doseEffectConstantsA, doseEffectConstantsB, doseColumnA, doseColumnB, precision)
%CONSTRUCTADDITIVEMATRIX Summary of this function goes here
%   Detailed explanation goes here

    effectDoseFunctionA = chemistry.response2doseFunction(doseEffectConstantsA);
    effectDoseFunctionB = chemistry.response2doseFunction(doseEffectConstantsB);

    additiveMatrix = zeros(length(doseColumnA), length(doseColumnB));
    nearestKnownMatrix = ones(length(doseColumnA), length(doseColumnB)) * Inf;

    for effect = max([precision, doseEffectConstantsA.minVal, doseEffectConstantsB.minVal]):precision:(100 - precision)
        
        aAlone = effectDoseFunctionA(effect);
        bAlone = effectDoseFunctionB(effect);
        
        directionCoefficient = -bAlone/aAlone;
        intercept = bAlone;
        
        normalVector = [directionCoefficient, -1];
        lengthUnnormalizedNormal = norm(normalVector);
        normalizedNormal = normalVector ./ lengthUnnormalizedNormal;
        
        distanceToOrigin = intercept / lengthUnnormalizedNormal;
        
        for aIndex = 1:length(doseColumnA)
            for bIndex = 1:length(doseColumnB)
                aMix = doseColumnA(aIndex);
                bMix = doseColumnB(bIndex);
                
                distanceToLoeweAdditivityLine = abs(normalizedNormal * [aMix, bMix]' - distanceToOrigin);
                
                if nearestKnownMatrix(aIndex, bIndex) <= distanceToLoeweAdditivityLine
                    continue;
                end
                
                nearestKnownMatrix(aIndex, bIndex) = distanceToLoeweAdditivityLine;
                additiveMatrix(aIndex, bIndex) = effect;
            end
        end
    end
end

