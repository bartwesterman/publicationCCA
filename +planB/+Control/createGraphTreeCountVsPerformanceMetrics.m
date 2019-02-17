function rgb = createGraphTreeCountVsPerformanceMetrics( resultFilePath, resultFilePathScaled, randomForestResultsPath )
%CREATEGRAPHTREECOUNTTOIMPORTANCEDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here

    files = dir([randomForestResultsPath '*.mat']);
    
    fileCount = length(files);
    treeCountVector = zeros(fileCount, 1);

    results = cell(fileCount, 1);
    oobLoss = zeros(fileCount,1);
    for i = 1:length(files)
        filePath = [randomForestResultsPath files(i).name];
        load(filePath, 'result');
        treeCountVector(i) = result.learner.treeCount;
        results{i} = result.performance;
        oobLoss(i) = result.learner.randomForest.oobLoss;
    end
    
    performanceTable = vertcat(results{:});
    performanceTable.oobLoss = oobLoss;

    [~, sortedIndices] = sort(treeCountVector, 'descend');
    performanceTable = performanceTable(sortedIndices, {'oobLoss', 'rootMeanSquaredError', 'meanAbsoluteError', 'relativeAbsoluteError', 'relativeSquaredError', 'pearsonCorrelation', 'r2', 'adjustedR2', 'weightedPearson'});
    performanceTable.Properties.RowNames = strcat({'tc___'}, num2str(treeCountVector(sortedIndices), '%-i'));

    upsideDownPerformanceTable = flipud(performanceTable);
    upsideDownPerformanceTable.Properties.RowNames = flip(performanceTable.Properties.RowNames);
    performanceTable.weightedPearson(isnan(performanceTable.weightedPearson)) = 0;
    mlp = planB.view.MultiLinePlot().init(performanceTable, 'Random Forests: tree count vs performance metric', 'tree count', 'performance');
    utils.assurePathFor(resultFilePath);
    mlp.save(resultFilePath);
    
    scaleToUnit = @(v)(v - min(v)) ./ (max(v) - min(v));
    variableNames = performanceTable.Properties.VariableNames;
    scaledPerformanceTable = varfun(scaleToUnit, performanceTable);
    scaledPerformanceTable.Properties.VariableNames = variableNames;
    scaledPerformanceTable.Properties.RowNames = strcat({'tc___'}, num2str(treeCountVector(sortedIndices), '%-i'));

    rgb = planB.view.RibbonGraphBuilder().init('Random Forests: tree count vs scaled performance metric', 'performance metric', 'tree count', scaledPerformanceTable);

    utils.assurePathFor(resultFilePathScaled);
    rgb.save(resultFilePathScaled);

    

end

