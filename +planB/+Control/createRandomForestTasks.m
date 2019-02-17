function tasks = createRandomForestTasks(targetPath)
%CREATERANDOMFORESTTASKS Summary of this function goes here
%   Detailed explanation goes here
    
    if ~(targetPath(end) == '/')
        targetPath = [targetPath '/'];
    end
    system(['mkdir -p ' targetPath]);
    
    tasks = planB.RandomForest.createTasks();
    
    for i = 1:length(tasks)
        task = tasks{i};
                
        filePath = [targetPath task.getHash() '.mat'];
        
        if ~(exist(filePath, 'file') == 2)
            save(filePath, 'task');
        end
    end
    
end

