function bestResult = getBestPerformer( randomForestResultsPath)
%COMBINEDIMENSIONREDUCTIONS Summary of this function goes here
%   Detailed explanation goes here


    % select the best dimension reduction
    % select the best cutoff
    % select the best entityIds

    files = dir([randomForestResultsPath '*.mat']);
    
    fileCount = length(files);
    % treeCountVector = zeros(fileCount, 1);
    
    bestPearson = -Inf;
    bestResult  = [];
    
    for i = 1:length(files)
        filePath = [randomForestResultsPath files(i).name];
        load(filePath, 'result');
        % treeCountVector(i) = result.learner.treeCount;
        currentPearson = result.performance.pearsonCorrelation;
        if isnan(currentPearson)
            currentPearson = -Inf;
        end
        if currentPearson >= bestPearson
            bestPearson = result.performance.pearsonCorrelation;
            bestResult = result;
        end
    end


end

