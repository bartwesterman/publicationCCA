function rgb = createGraphTreeCountChangeAndRankCorrelation( resultFilePath, randomForestResultsPath )
%CREATEGRAPHTREECOUNTCHANGEANDRANKCORRELATION Summary of this function goes here
%   Detailed explanation goes here

    files = dir([randomForestResultsPath '*.mat']);
    
    fileCount = length(files);
    treeCountVector = zeros(fileCount, 1);

    results = cell(fileCount, 1);
    
    for i = 1:length(files)
        filePath = [randomForestResultsPath files(i).name];
        load(filePath, 'result');
        treeCountVector(i) = result.learner.treeCount;
        results{i} = result.importance.entityId';
    end
    
    importanceMatrix = vertcat(results{:});

    [treeCountVector, sortedIndices] = sort(treeCountVector, 'descend');
    importanceMatrix = importanceMatrix(sortedIndices, :);

    kendall  = zeros(fileCount - 1, 1);
    spearman = zeros(fileCount - 1, 1);
    pearson  = zeros(fileCount - 1, 1);
    rowNames = cell(fileCount - 1, 1);
    
    importanceCutoff = 50;
    
    for i = 1:(fileCount - 1)
        kendall(i)  = corr(importanceMatrix(i, 1:importanceCutoff)', importanceMatrix(i + 1, 1:importanceCutoff)', 'type', 'kendall');
        spearman(i) = corr(importanceMatrix(i, 1:importanceCutoff)', importanceMatrix(i + 1, 1:importanceCutoff)', 'type', 'spearman');
        pearson(i)  = corr(importanceMatrix(i, 1:importanceCutoff)', importanceMatrix(i + 1, 1:importanceCutoff)');

        rowNames{i} = ['to ' num2str(treeCountVector(i))];
        
        if i == (fileCount - 1)
            rowNames{i} = ['from ' num2str(treeCountVector(i + 1)) ' ' rowNames{i}];
        end
    end
    
    relativeRankCorrelation = table(pearson, kendall, spearman);
    relativeRankCorrelation.Properties.RowNames = rowNames;
    
    rgb = planB.view.RibbonGraphBuilder().init('Random Forests: tree count increase vs rank correlation', 'rank correlation metric', 'tree count increase', relativeRankCorrelation);

    utils.assurePathFor(resultFilePath);
    rgb.save(resultFilePath);


end

