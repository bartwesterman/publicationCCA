function exampleSet = randomSubSet(fullExampleSetFilePath, reducedExampleSetFilePath, maxExampleCount)
%RANDOMSUBSET Summary of this function goes here
%   Detailed explanation goes here
    maxExampleCount = str2num(maxExampleCount);
    load(fullExampleSetFilePath, 'exampleSet');
    
    exampleSet = exampleSet.getRandomSubSet(maxExampleCount);

    save(reducedExampleSetFilePath, 'exampleSet', '-v7.3');
end


