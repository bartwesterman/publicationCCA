function rgb = createGraphTreeCountVsImportanceDistribution( resultFilePath, randomForestResultsPath, importanceCutoffCount)
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
        dataTable.(['tc___' num2str(result.learner.treeCount)]) = flip(sort(result.importance.importance, 'descend'));
    end
    
    [~, sortedIndices] = sort(treeCountVector);
    dataTable = dataTable(:, sortedIndices);
    
    if exist('importanceCutoffCount','var') && ~isempty(importanceCutoffCount)
        dataTable = dataTable(1:importanceCutoffCount, :);
    end
    
    rgb = planB.view.RibbonGraphBuilder().init('Random Forests: importance distribution vs tree count', 'tree count', 'importance distribution', dataTable);

    utils.assurePathFor(resultFilePath);
    rgb.save(resultFilePath);
end

