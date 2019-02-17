function  repairResultPath( resultPath, correctTestSet )
%REPAIRRESULTPATH Summary of this function goes here
%   Detailed explanation goes here

    files = dir([resultPath '*.mat']);
       
    for i = 1:length(files)
        filePath = [resultPath files(i).name];
        
        planB.Control.repairResult(filePath, correctTestSet);
    end



end

