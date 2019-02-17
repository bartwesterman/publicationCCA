function convertedResult = convertToResultAfterRegression( unconvertedResultFilePath, trainingSetFilePath, testSetFilePath, convertedResultFilePath)
%CONVERTTORESULTAFTERREGRESSION Summary of this function goes here
%   Detailed explanation goes here

    load(unconvertedResultFilePath, 'result');
    unconvertedResult = result;
    
    load(trainingSetFilePath, 'exampleSet');
    trainingSet = exampleSet;
    
    load(testSetFilePath, 'exampleSet');
    testSet = exampleSet;
    
    learner = planB.AfterLearningRegression().init(result.learner);
    
    result = learner.analyze(trainingSet, testSet);
    utils.assurePathFor(convertedResultFilePath);
    save(convertedResultFilePath, 'result', '-v7.3');
end

