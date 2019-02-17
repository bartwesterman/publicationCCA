function exampleSet = reduceExampleSet( fullExampleSetFilePath, importanceFilePath, reducedExampleSetFilePath )
%REDUCEEXAMPLESETTOIMPORTANTATTRIBUTES Summary of this function goes here
%   Detailed explanation goes here
    es = planB.ExampleSet(); % load example set to make sure it gets compiled into the code
    em = data.EntityManager(); % load example set to make sure it gets compiled into the code

    load(importanceFilePath, 'importantEntityIds');
    load(fullExampleSetFilePath, 'exampleSet');
    es = planB.ExampleSet(); % to let the compiler know to include ExampleSet.
    exampleSet = exampleSet.filterEntityIds([exampleSet.getOutputEntityId() ; union(importantEntityIds, exampleSet.attributesOfType('drug'))]);
    
    save(reducedExampleSetFilePath, 'exampleSet', '-v7.3');
end

