function exampleSet = removeCellLineIdsFromExampleSet( fullExampleSetPath, reducedExampleSetPath )
%REMOVECELLLINEIDSFROMEXAMPLESET Summary of this function goes here
%   Detailed explanation goes here
    es = planB.ExampleSet(); % load example set to make sure it gets compiled into the code
    em = data.EntityManager(); % load example set to make sure it gets compiled into the code

    load(fullExampleSetPath, 'exampleSet');
    exampleSet  = exampleSet.filterEntityIds(exampleSet.attributesExcludingType('cellLine'));
    
    save(reducedExampleSetPath, 'exampleSet', '-v7.3');
end

