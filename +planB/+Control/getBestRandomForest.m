function bestResult = getBestRandomForest( randomForestResultsPath)
%COMBINEDIMENSIONREDUCTIONS Summary of this function goes here
%   Detailed explanation goes here


    % select the best dimension reduction
    % select the best cutoff
    % select the best entityIds

    files = dir([randomForestResultsPath '*.mat']);
    
    fileCount = length(files);
    % treeCountVector = zeros(fileCount, 1);
    
    bestOopLoss = Inf;
    bestResult  = [];
    
    for i = 1:length(files)
        filePath = [randomForestResultsPath files(i).name];
        load(filePath, 'result');
        % treeCountVector(i) = result.learner.treeCount;
        currentOobLoss = result.performance.pearsonCorrelation;
        if isnan(currentOobLoss)
            currentOobLoss = Inf;
        end
        if currentOobLoss <= bestOopLoss
            bestOopLoss = currentOobLoss;
            bestResult = result;
        end
    end


end

