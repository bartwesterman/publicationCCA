function [nodeCountGraph, weightCountGraph ] = resultTableToTopologyStatistics( resultTable, featureCount, nodeCountVsWeightedPearsonGraphFilePath, weightCountVsWeightedPearsonGraphFilePath )
%RESULTTABLETOTOPOLOGYSTATISTICS Summary of this function goes here
%   Detailed explanation goes here

    if isprop(resultTable.learner, 'hiddenLayers')
        nc = arrayfun(@(v) v.nodeCount() , resultTable.learner);
        wc = arrayfun(@(v) v.weightCount(featureCount) , resultTable.learner);
    else
        nc = arrayfun(@(v) v.learner.nodeCount() , resultTable.learner);
        wc = arrayfun(@(v) v.learner.weightCount(featureCount) , resultTable.learner);
    end
    wp = resultTable.weightedPearson;
    [ncSorted, ncSortedIndices] = sort(nc);
    nodeCountGraph = planB.view.PlotForPaper(ncSorted, wp(ncSortedIndices), '#nodes versus weighted pearson','#nodes','weighted pearson');
    saveas(nodeCountGraph, nodeCountVsWeightedPearsonGraphFilePath);
    
    
    [wcSorted, wcSortedIndices] = sort(wc);
    weightCountGraph = planB.view.PlotForPaper(wcSorted, wp(wcSortedIndices), '#weights versus weighted pearson','#weights','weighted pearson');
    
    saveas(weightCountGraph, weightCountVsWeightedPearsonGraphFilePath);
end

