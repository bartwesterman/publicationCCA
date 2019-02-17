function ci = combinationIndex( effect, mixDoseA, mixDoseB, responseToDoseFunctionA, responseToDoseFunctionB)
%COMBINATIONINDEX Summary of this function goes here
%   Detailed explanation goes here
   
    soloDoseA = responseToDoseFunctionA(effect);
    soloDoseB = responseToDoseFunctionB(effect);
    
    ci = chemistry.doseBasedCombinationIndex(mixDoseA, mixDoseB, soloDoseA, soloDoseB);
    
end

