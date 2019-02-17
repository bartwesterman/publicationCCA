function importantEntityIds = combineDimensionReductions( resultFilePath, randomForestResultsPath, bestZoneImportantEntityIdCount, bestReductionFilePath)
%COMBINEDIMENSIONREDUCTIONS Summary of this function goes here
%   Detailed explanation goes here


    % select the best dimension reduction
    % select the best cutoff
    % select the best entityIds
    
    result = planB.Control.getBestRandomForest(randomForestResultsPath);
    
    entityIds   = result.importance.entityId;

    importantEntityIds = entityIds(1:min(bestZoneImportantEntityIdCount, size(entityIds,1)));
    
    save(resultFilePath, 'importantEntityIds', '-v7.3');    
    
    save(bestReductionFilePath, 'result', '-v7.3');    
end

