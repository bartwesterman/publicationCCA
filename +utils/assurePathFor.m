function assurePathFor( filePath )
%ASSUREPATHFOR Summary of this function goes here
%   Detailed explanation goes here

    path = filePath;
    if (filePath(end) ~= '/')
        pathNodes = strsplit(filePath, '/');
        path = strjoin(pathNodes(1:(end -1)), '/');        
    end
    
    system(['mkdir -p ' path]);
    system(['chmod 777 ' path]);

end

