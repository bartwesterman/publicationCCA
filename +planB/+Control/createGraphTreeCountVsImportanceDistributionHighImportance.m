function dataTable = createGraphTreeCountVsImportanceDistributionHighImportance( resultFilePath, randomForestResultsPath)
%CREATEGRAPHTREECOUNTTOIMPORTANCEDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

    files = dir([randomForestResultsPath '*.mat']);
    
    dataTable = table();
    fileCount = length(files);
    treeCountVector = zeros(fileCount, 1);
    for i = 1:length(files)
        filePath = [randomForestResultsPath files(i).name];
        load(filePath, 'result');
        treeCountVector(i) = result.learner.treeCount;
        dataTable.(['tc___' num2str(result.learner.treeCount)]) = sort(result.importance.importance, 'descend');
    end
    
    [~, sortedIndices] = sort(treeCountVector);
    dataTable = dataTable(:, sortedIndices);
    dataTable = varfun(@cumsum, dataTable);
    mlp = planB.view.MultiLinePlot().init(dataTable, 'Cumulative sum of importance for each tree count', 'importance rank', 'cummulated importance');
    
    utils.assurePathFor(resultFilePath);
    
    mlp.save(resultFilePath);
end

