function survivalRate = combinationToAdditiveEffect( doseEffectConstantsA, doseEffectConstantsB, doseA, doseB, precision )
%COMBINATIONTOEFFECT Summary of this function goes here
%   Detailed explanation goes here

    combinationToAdditiveEffectErrorFunction = createCombinationToAdditiveEffectErrorFunction(doseEffectConstantsA, doseEffectConstantsB, doseA, doseB);

    survivalRate = double(0);
    increase = 40;
    
    error = combinationToAdditiveEffectErrorFunction(survivalRate);

    sign = -error / abs(error);
    
    initialSign = sign;
    
    while true
        
        
        error = combinationToAdditiveEffectErrorFunction(survivalRate);
    
        sign = -error / abs(error);
        
        if sign ~= initialSign
            break;
        end
        
        increase = increase * 2;
        
        survivalRate = survivalRate + sign * increase;
        
        if survivalRate > 150
            survivalRate = 150;
        end
    end
    
    while abs(error) > precision
        
        sign = -error / abs(error);
        increase = increase / 2;
        
        survivalRate = double(survivalRate) + double(sign) * double(increase);
        
        if survivalRate > 150
            survivalRate = 150;
        end
        
        error = combinationToAdditiveEffectErrorFunction(survivalRate);
    end
    
    
end

function combinationToAdditiveEffectErrorFunction = createCombinationToAdditiveEffectErrorFunction(doseEffectConstantsA, doseEffectConstantsB, doseA, doseB)

    aInv = createEffectToDoseFunction(doseEffectConstantsA);
    bInv = createEffectToDoseFunction(doseEffectConstantsB);

    combinationToAdditiveEffectErrorFunctionWithImaginary = ...
        @(survivalRate) aInv(survivalRate) * bInv(survivalRate) - bInv(survivalRate) * doseA - doseB * aInv(survivalRate);
    
    function error = combinationToAdditiveEffectErrorFunctionWithoutImaginary(survivalRate)
        error = combinationToAdditiveEffectErrorFunctionWithImaginary(survivalRate);
        if (~isreal(error))
            error = intmin;
        end
    end

    combinationToAdditiveEffectErrorFunction = @combinationToAdditiveEffectErrorFunctionWithoutImaginary;
end

function effectToDoseFunction = createEffectToDoseFunction(doseEffectConstants)
    maxVal = 100;
    minVal = doseEffectConstants.minVal;
    hillSlope     = doseEffectConstants.hillSlope;
    ic50    = doseEffectConstants.ic50;
    
    effectToDoseFunction = @(survivalRate) ic50 * double(double(maxVal - minVal)/double(survivalRate - minVal))^(-1/hillSlope);
end
