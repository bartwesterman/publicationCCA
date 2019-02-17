function result = runNeuralNetworkTask( taskFilePath, trainingSetFilePath, testSetFilePath, resultFilePath )
%RUNANALYSISTASK Summary of this function goes here
%   Detailed explanation goes here
    load(taskFilePath, 'task');
    function exampleSet = loadExampleSet(filePath)
        load(filePath, 'exampleSet');
    end

    trainingSet = loadExampleSet(trainingSetFilePath);
    testSet     = loadExampleSet(testSetFilePath);

    nn = planB.NeuralNetwork(); % added to make sure that the compiler knows to include the definition of RandomForest into this matlab executable, necessary to execute that task
    
    result = task.analyze(trainingSet, testSet);
    
    % assure that the directory exists
    resultFilePathNodes = strsplit(resultFilePath, '/');
    resultPath = strjoin(resultFilePathNodes(1:(end - 1)), '/');
    system(['mkdir -p ' resultPath]);
    pause(.333);
    % save the result
    save(resultFilePath, 'result', '-v7.3');

end

