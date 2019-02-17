function extractFinalResultData2()
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
    
    
    
%     logsigLethalityResultTable                = planB.Control.aggregateResults([logsigLethalityPath convertedResultsPath]);
%     [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( logsigLethalityResultTable, 'weightedPearson' );
%     planB.view.HeatSurface(resultMatrix);    
%     planB.view.HeatBarChart(resultMatrix);    
%     
%     logsigLethalityAfterRegressionResultTable = planB.Control.aggregateResults([logsigLethalityPath convertedResultsAfterRegressionPath]);
%     [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( logsigLethalityAfterRegressionResultTable, 'weightedPearson' );
%     planB.view.HeatSurface(resultMatrix);    
%     planB.view.HeatBarChart(resultMatrix);    
    
    yAxisLabelPosition = [8.8 0 0];
    yAxisLabelRotation = 77.5;
    xAxisLabelPosition = [6.1302 -0.4778 -.1538];
    xAxisLabelRotation = -6.1;
    zAxisLabelPosition = [-0.2 -2.5125 .6500];
    
    

    tansigLethalityResultTable                = planB.Control.aggregateResults([tansigLethalityPath convertedResultsPath]);    
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigLethalityResultTable, 'weightedPearson' );
    planB.view.HeatBarChart(resultMatrix);    
    axes = gca;
    axes.YAxis.Label.Position = yAxisLabelPosition;
    axes.YAxis.Label.Rotation = yAxisLabelRotation;
    axes.XAxis.Label.Position = xAxisLabelPosition;
    axes.XAxis.Label.Rotation = xAxisLabelRotation;
    axes.ZAxis.Label.Position = zAxisLabelPosition;

    
    
    planB.view.HeatBarChart(resultMatrix);    
    view([0 90]);

    
    
    tansigDExpectedResultTable                = planB.Control.aggregateResults([tansigDExpectedPath convertedResultsPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigDExpectedResultTable, 'weightedPearson' );
    planB.view.HeatBarChart(resultMatrix);    
    
    axes = gca;
    axes.YAxis.Label.Position = yAxisLabelPosition;
    axes.YAxis.Label.Rotation = yAxisLabelRotation;
    axes.XAxis.Label.Position = xAxisLabelPosition;
    axes.XAxis.Label.Rotation = xAxisLabelRotation;
    axes.ZAxis.Label.Position = zAxisLabelPosition;
       
    planB.view.HeatBarChart(resultMatrix);    
    view([0 90]);

    tansigSynergyResultTable                 = planB.Control.aggregateResults([tansigSynergyPath 'neuralNetworkResults/']);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigSynergyResultTable, 'weightedPearson' );
    planB.view.HeatBarChart(resultMatrix);
    axes = gca;
    axes.YAxis.Label.Position = yAxisLabelPosition;
    axes.YAxis.Label.Rotation = yAxisLabelRotation;
    axes.XAxis.Label.Position = xAxisLabelPosition;
    axes.XAxis.Label.Rotation = xAxisLabelRotation;
    axes.ZAxis.Label.Position = zAxisLabelPosition;
    planB.view.HeatBarChart(resultMatrix);    
    view([0 90]);
    
    tansigLethalityUnconvertedResultTable                = planB.Control.aggregateResults([tansigLethalityPath 'neuralNetworkResults/']);    
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigLethalityUnconvertedResultTable, 'weightedPearson' );
    planB.view.HeatBarChart(resultMatrix);    
   
    caxis([.55 .8]);
    zlim([0, .8]);
    axes = gca;
    axes.YAxis.Label.Position = yAxisLabelPosition;
    axes.YAxis.Label.Rotation = yAxisLabelRotation;
    axes.XAxis.Label.Position = xAxisLabelPosition;
    axes.XAxis.Label.Rotation = xAxisLabelRotation;
    axes.ZAxis.Label.Position = [-0.2000   -2.5125    1.3];       
    planB.view.HeatBarChart(resultMatrix);    
    view([0 90]);
    
    caxis([.55 .8]);
    zlim([0, .8]);
end


