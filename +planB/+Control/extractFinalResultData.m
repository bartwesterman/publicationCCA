function extractFinalResultData()
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
    csvFilePath = [logsigLethalityPath convertedGraphPath 'logsigLethalityRawWeightedPearsonData.csv'];
    csvwrite(csvFilePath, resultMatrix);
    
    logsigLethalityAfterRegressionResultTable = planB.Control.aggregateResults([logsigLethalityPath convertedResultsAfterRegressionPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( logsigLethalityAfterRegressionResultTable, 'weightedPearson' );
    
    csvFilePath = [logsigLethalityPath convertedGraphsAfterRegressionPath 'logsigLethalityAfterRegressionRawWeightedPearsonData.csv'];
    csvwrite(csvFilePath, resultMatrix);
   
    tansigLethalityResultTable                = planB.Control.aggregateResults([tansigLethalityPath convertedResultsPath]);    
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigLethalityResultTable, 'weightedPearson' );
    
    csvFilePath = [tansigLethalityPath convertedGraphPath 'tansigLethalityRawWeightedPearson.csv'];
    csvwrite(csvFilePath, resultMatrix);

    tansigDExpectedResultTable                = planB.Control.aggregateResults([tansigDExpectedPath convertedResultsPath]);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigDExpectedResultTable, 'weightedPearson' );
    
    csvFilePath = [tansigDExpectedPath convertedGraphPath 'tansigDExpectedRawWeightedPearson.csv'];
    csvwrite(csvFilePath, resultMatrix);

    tansigSynergyResultTable                 = planB.Control.aggregateResults([tansigSynergyPath 'neuralNetworkResults/']);
    [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = planB.Control.resultTableToNodeCountMatrix( tansigSynergyResultTable, 'weightedPearson' );
    
    csvFilePath = [tansigSynergyPath 'neuralNetworkGraphs/' 'tansigSynergyRawWeightedPearson.csv'];
    csvwrite(csvFilePath, resultMatrix);

    
end


