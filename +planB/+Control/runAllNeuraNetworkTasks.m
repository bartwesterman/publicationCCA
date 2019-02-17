function runAllNeuraNetworkTasks( taskPath, exampleSetFilePath, resultPath )
%RUNALLNEURANETWORKTASKS Summary of this function goes here
%   Detailed explanation goes here

    taskFiles = dir([taskPath '*.mat']);

    for i = 1:length(taskFiles)
        nextTaskFileName = taskFiles(i).name;
        taskFilePath   = [taskPath   nextTaskFileName];
        resultFilePath = [resultPath nextTaskFileName];
        if exist(resultFilePath, 'file') == 2
            continue;
        end
        disp(['executing task: ' taskFilePath]);
        planB.Control.runNeuralNetworkTask(taskFilePath, exampleSetFilePath, resultFilePath);
    end
    
    
end

