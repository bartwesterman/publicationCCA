function resultTable = aggregateResults( resultPath, aggregateFilePath )
%AGGREGATERESULTS Summary of this function goes here
%   Detailed explanation goes here

    resultList = planB.Control.loadMatlabObjectPath(resultPath, 'result');

    resultTable = vertcat(resultList{:});
    
    [~, bestToWorstIndices] = sort(resultTable.weightedPearson, 'descend');
    
    resultTable = resultTable(bestToWorstIndices, :);
    
    if exist('aggregateFilePath', 'var')
        save(aggregateFilePath, 'resultTable', '-v7.3');
    end
end

