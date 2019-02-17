function tasks = createNeuralNetworkTasks(targetPath, kernelName)
%CREATERANDOMFORESTTASKS Summary of this function goes here
%   Detailed explanation goes here
    disp(['createNeuralNetworkTasks(' targetPath ')']);

    if ~(targetPath(end) == '/')
        targetPath = [targetPath '/'];
    end
    
    system(['mkdir -p ' targetPath]);
    
    if nargin < 2
        tasks = planB.NeuralNetwork.createTasks();
    else
        tasks = planB.NeuralNetwork.createTasks(kernelName);
    end
    
    disp('Neural network tasks created');
    for i = 1:length(tasks)
        task = tasks{i};
                
        filePath = [targetPath task.getHash() '.mat'];
        disp(['Neural network task filename created: ' filePath]);
        save(filePath, 'task');
        disp('Neural network task saved');
    end
end