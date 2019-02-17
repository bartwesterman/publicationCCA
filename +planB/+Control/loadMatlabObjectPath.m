function matlabObjectList = loadMatlabObjectPath( path, varName )
%LOADMATLABOBJECTPATH Summary of this function goes here
%   Detailed explanation goes here
    files = dir([path '*.mat']);
    matlabObjectList = cell(length(files), 1);
    
    for i = 1:size(matlabObjectList, 1)
        load([path files(i).name], varName);
        matlabObjectList{i, 1} = eval(varName);
    end

end

