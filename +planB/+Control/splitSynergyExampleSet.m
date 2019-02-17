function [ trainingSet, testSet ] = splitSynergyExampleSet( exampleSetFilePath, trainingSetFilePath, testSetFilePath, testProportion, holdoutSeed )
%SPLITSYNERGYTRAININGSET Summary of this function goes here
%   Detailed explanation goes here

    if ~exist('testProportion','var')
        testProportion = Config.TEST_PROPORTION;
    end
    if ~exist('holdoutSeed','var')
        holdoutSeed = Config.HOLD_OUT_SEED;
    end


    load(exampleSetFilePath, 'exampleSet');
    
    holdOutSplit = exampleSet.getHoldOutSplit(testProportion, holdoutSeed);
    
    function saveExampleSet(filePath, exampleSet)
        save(filePath, 'exampleSet', '-v7.3');
    end

    saveExampleSet(trainingSetFilePath, holdOutSplit.trainingSet);
    saveExampleSet(testSetFilePath,     holdOutSplit.testSet);
end

