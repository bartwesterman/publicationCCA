function tasks = createSupportVectorMachineTasks(targetPath)
%CREATERANDOMFORESTTASKS Summary of this function goes here
%   Detailed explanation goes here
    disp(['createSupportVectorMachineTasks(' targetPath ')']);

    if ~(targetPath(end) == '/')
        targetPath = [targetPath '/'];
    end
    
    system(['mkdir -p ' targetPath]);
    
    tasks = planB.SupportVectorMachine.createTasks();
    disp('SupportVectorMachine tasks created');
    for i = 1:length(tasks)
        task = tasks{i};
                
        filePath = [targetPath task.getHash() '.mat'];
        disp(['SupportVectorMachine filename created: ' filePath]);
        save(filePath, 'task');
        disp('SupportVectorMachine task saved');
    end
end