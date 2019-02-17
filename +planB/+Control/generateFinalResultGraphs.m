function generateFinalResultGraphs()
%GENERATEFINALRESULTGRAPHS Summary of this function goes here
%   Detailed explanation goes here
    resultPath     = './output/results/';
    
    lethalityPath  = [resultPath 'lethality/'];
    synergyPath    = [resultPath 'synergy/'];
    dexpectedPath  = [resultPath 'dexpected/'];
    
    
    logsigLethalityPath = [lethalityPath 'allTrainingExamplesLogsig115features/'];
    tansigLethalityPath = [lethalityPath 'allTrainingExamplesTansig115features/'];
    
    tansigDExpectedPath = [dexpectedPath ''];

    tansigSynergyPath = [synergyPath ''];
    
    convertedResultsPath = 'convertedNeuralNetworkResults/';
    convertedGraphPath   = 'convertedNeuralNetworkGraphs/';
    
    convertedResultsAfterRegressionPath = 'convertedNeuralNetworkResultsAfterRegression/';
    convertedGraphsAfterRegressionPath = 'convertedNeuralNetworkGraphsAfterRegression/';
    
    
    
    logsigLethalityResultTable                = planB.Control.aggregateResults([logsigLethalityPath convertedResultsPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( logsigLethalityResultTable, 'weightedPearson' );
    f = planB.view.HeatTable(resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2, 'Performance weighted pearson', '#Nodes layer 1', '#Nodes layer 2', 2, -.25, 10, 0);
    
    saveas(f, [logsigLethalityPath convertedGraphPath 'weightedPearsonPerformanceV2.png']);
    saveas(f, [logsigLethalityPath convertedGraphPath 'weightedPearsonPerformanceV2.fig']);
    
    planB.Control.resultTableToTopologyStatistics( logsigLethalityResultTable, 115, [logsigLethalityPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.png'], [logsigLethalityPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.png'] );
    planB.Control.resultTableToTopologyStatistics( logsigLethalityResultTable, 115, [logsigLethalityPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.fig'], [logsigLethalityPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.fig'] );
    
    logsigLethalityAfterRegressionResultTable = planB.Control.aggregateResults([logsigLethalityPath convertedResultsAfterRegressionPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( logsigLethalityAfterRegressionResultTable, 'weightedPearson' );

    f = planB.view.HeatTable(resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2, 'Performance weighted pearson', '#Nodes layer 1', '#Nodes layer 2', 2, -.25, 10, 0);
    
    saveas(f, [logsigLethalityPath convertedGraphsAfterRegressionPath 'weightedPearsonPerformanceV2.png']);
    saveas(f, [logsigLethalityPath convertedGraphsAfterRegressionPath 'weightedPearsonPerformanceV2.fig']);
    
    planB.Control.resultTableToTopologyStatistics( logsigLethalityAfterRegressionResultTable, 115, [logsigLethalityPath convertedGraphsAfterRegressionPath 'nodeCountVsWeightedPearsonPerformance.png'], [logsigLethalityPath convertedGraphsAfterRegressionPath 'weightCountVsWeightedPearsonPerformance.png'] );
    planB.Control.resultTableToTopologyStatistics( logsigLethalityAfterRegressionResultTable, 115, [logsigLethalityPath convertedGraphsAfterRegressionPath 'nodeCountVsWeightedPearsonPerformance.fig'], [logsigLethalityPath convertedGraphsAfterRegressionPath 'weightCountVsWeightedPearsonPerformance.fig'] );
    
    
    tansigLethalityResultTable                = planB.Control.aggregateResults([tansigLethalityPath convertedResultsPath]);    
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigLethalityResultTable, 'weightedPearson' );

    f = planB.view.HeatTable(resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2, 'Performance weighted pearson', '#Nodes layer 1', '#Nodes layer 2', 2, -.25, 10, 0);
    
    saveas(f, [tansigLethalityPath convertedGraphPath 'weightedPearsonPerformanceV2.png']);
    saveas(f, [tansigLethalityPath convertedGraphPath 'weightedPearsonPerformanceV2.fig']);
    
    planB.Control.resultTableToTopologyStatistics( tansigLethalityResultTable, 115, [tansigLethalityPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.png'], [tansigLethalityPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.png'] );
    planB.Control.resultTableToTopologyStatistics( tansigLethalityResultTable, 115, [tansigLethalityPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.fig'], [tansigLethalityPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.fig'] );
    
    
    tansigDExpectedResultTable                = planB.Control.aggregateResults([tansigDExpectedPath convertedResultsPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigDExpectedResultTable, 'weightedPearson' );
    
    f = planB.view.HeatTable(resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2, 'Performance weighted pearson', '#Nodes layer 1', '#Nodes layer 2', 2, -.25, 10, 0);
    
    saveas(f, [tansigDExpectedPath convertedGraphPath 'weightedPearsonPerformanceV2.png']);
    saveas(f, [tansigDExpectedPath convertedGraphPath 'weightedPearsonPerformanceV2.fig']);
    
    planB.Control.resultTableToTopologyStatistics( tansigDExpectedResultTable, 115, [tansigDExpectedPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.png'], [tansigDExpectedPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.png'] );
    planB.Control.resultTableToTopologyStatistics( tansigDExpectedResultTable, 115, [tansigDExpectedPath convertedGraphPath 'nodeCountVsWeightedPearsonPerformance.fig'], [tansigDExpectedPath convertedGraphPath 'weightCountVsWeightedPearsonPerformance.fig'] );
    

    tansigSynergyResultTable                 = planB.Control.aggregateResults([tansigSynergyPath 'neuralNetworkResults/']);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigSynergyResultTable, 'weightedPearson' );

    f = planB.view.HeatTable(resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2, 'Performance weighted pearson', '#Nodes layer 1', '#Nodes layer 2', 2, -.25, 10, 0);
    
    saveas(f, [tansigSynergyPath 'neuralNetworkGraphs/' 'weightedPearsonPerformanceV2.png']);
    saveas(f, [tansigSynergyPath 'neuralNetworkGraphs/' 'weightedPearsonPerformanceV2.fig']);
    
    planB.Control.resultTableToTopologyStatistics( tansigSynergyResultTable, 115, [tansigSynergyPath 'neuralNetworkGraphs/' 'nodeCountVsWeightedPearsonPerformance.png'], [tansigSynergyPath 'neuralNetworkGraphs/' 'weightCountVsWeightedPearsonPerformance.png'] );
    planB.Control.resultTableToTopologyStatistics( tansigSynergyResultTable, 115, [tansigSynergyPath 'neuralNetworkGraphs/' 'nodeCountVsWeightedPearsonPerformance.fig'], [tansigSynergyPath 'neuralNetworkGraphs/' 'weightCountVsWeightedPearsonPerformance.fig'] );
    

end

