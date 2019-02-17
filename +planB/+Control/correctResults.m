function correctResults( resultPath, testSetFilePath )
%CORRECTR2 Summary of this function goes here
%   Detailed explanation goes here

    files = dir([resultPath '*.mat']);
    
    fileNames = {files.name}';
    paths     = {files.folder}';
    filePaths = strcat(paths, '/', fileNames);
    
    load(testSetFilePath, 'exampleSet');
    validOutput = ~isnan(exampleSet.getOutput());
    exampleSet = exampleSet.selectRows(validOutput);
    for i = 1:size(filePaths, 1)
        filePath = filePaths{i};
        
        load(filePath, 'result');
        prediction = result.performance.prediction{1};
        prediction = prediction(validOutput);
        correctPerformance = exampleSet.analyzePerformance(prediction);
        
        result.performance = correctPerformance;
        
        save(filePath, 'result', '-v7.3');
    end

end

