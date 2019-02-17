function repairResult( brokenResultFilePath, correctTestSetFilePath )
%REPAIRPERFORMANCE Summary of this function goes here
%   Detailed explanation goes here

    load(brokenResultFilePath, 'result');

    learner = result.learner;
    
    load(correctTestSetFilePath, 'exampleSet');
    
    outputs = learner.predict(exampleSet.getInput());
            
    result = exampleSet.analyzePerformance(outputs);
    result.learner = learner;

    save(brokenResultFilePath, 'result', '-v7.3');

end

