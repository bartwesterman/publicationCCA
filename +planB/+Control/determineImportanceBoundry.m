function importantEntityIdCount = determineImportanceBoundry( importances, maxVariance, maxMean )
%DETERMINEIMPORTANCEBOUNDRY Summary of this function goes here
%   Detailed explanation goes here
    stabilityRange = 1:round(.005 * length(importances));
    
    for i = 1:(length(importances) - length(stabilityRange))
        evaluatedImportances = importances(i + stabilityRange - 1);
        if var(evaluatedImportances) < maxVariance && mean(evaluatedImportances) < maxMean
            importantEntityIdCount = i;
            return;
        end
    end

    importantEntityIdCount = 1;
end

