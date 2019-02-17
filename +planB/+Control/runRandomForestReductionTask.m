function result = runRandomForestReductionTask( taskFilePath, trainingSetFilePath, testSetFilePath, resultFilePath )
%RUNDIMENSIONREDUCTIONTASKS Summary of this function goes here
%   Detailed explanation goes here

%     if exist(resultFilePath, 'file') == 2
%         disp(['skipping ' resultFilePath]);
%         return;
%     end
    disp(['generating random forest for ' resultFilePath]);
    
    function exampleSet = loadExampleSet(filePath)
        load(filePath, 'exampleSet');
    end
    
    load(taskFilePath, 'task');
    trainingSet = loadExampleSet(trainingSetFilePath);
    testSet = loadExampleSet(testSetFilePath);
    
    rf = planB.RandomForest(); % added to make sure that the compiler knows to include the definition of RandomForest into this matlab executable, necessary to execute that task
    
    result = task.prioritize(trainingSet, testSet);
    
    
    resultFilePathNodes = strsplit(resultFilePath, '/');
    resultPath = strjoin(resultFilePathNodes(1:(end - 1)), '/');
    system(['mkdir -p ' resultPath]);
    
    save(resultFilePath, 'result', '-v7.3');
end

