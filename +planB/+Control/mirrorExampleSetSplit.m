function [trainingSet, testSet ] = mirrorExampleSetSplit( fullExampleSetFilePath, modelTrainingSetFilePath, modelTestSetFilePath, resultTrainingSetFilePath, resultTestSetFilePath)
%MIRROREXAMPLESETSPLIT Summary of this function goes here
%   Detailed explanation goes here

    function exampleSet = loadExampleSet(filePath)
        load(filePath, 'exampleSet');
    end

    function saveExampleSet(filePath, exampleSet)
        save(filePath, 'exampleSet', '-v7.3');
    end

    fullExampleSet   = loadExampleSet(fullExampleSetFilePath);

    modelTrainingSet = loadExampleSet(modelTrainingSetFilePath);
    modelTestSet     = loadExampleSet(modelTestSetFilePath);
    
    resultTrainingSet = fullExampleSet.getSubExampleSetByExampleIds(modelTrainingSet.exampleIds);
    resultTestSet = fullExampleSet.getSubExampleSetByExampleIds(modelTestSet.exampleIds);
    
    saveExampleSet(resultTrainingSetFilePath, resultTrainingSet);
    saveExampleSet(resultTestSetFilePath, resultTestSet);
end

