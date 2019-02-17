function createGraphSVMResults( resultPath, pearsonGraphFilePath, weightedPearsonGraphFilePath)
%CREATEGRAPHSVMRESULTS Summary of this function goes here
%   Detailed explanation goes here
    resultList = planB.Control.loadMatlabObjectPath(resultPath, 'result');

    pearsonBars = zeros(length(resultList), 1);
    weightedPearsonBars = zeros(length(resultList), 1);

    barLabels = cell(length(resultList), 1);
    
    for i = 1:length(resultList)
        result = resultList{i};
        
        pearsonBars(i) = result.pearsonCorrelation;
        weightedPearsonBars(i) = result.weightedPearson;
        
        barLabels{i} = result.learner.kernel;
    end
    
    f = figure;
    bar(pearsonBars);
    xticklabels(barLabels);
    ylabel('Pearson correlation');
    xlabel('kernel');
    
    utils.assurePathFor(pearsonGraphFilePath);    
    saveas(f, pearsonGraphFilePath);
    
    f = figure;
    bar(weightedPearsonBars);
    xticklabels(barLabels);
    ylabel('Weighted pearson correlation');
    xlabel('kernel');
    
    utils.assurePathFor(weightedPearsonGraphFilePath);
    saveas(f, weightedPearsonGraphFilePath);
end

