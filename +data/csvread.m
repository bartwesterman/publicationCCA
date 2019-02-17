function asCellMatrix = csvread(filePath)
%CSVREAD Summary of this function goes here
%   Detailed explanation goes here
    asString = fileread(filePath);
    
    % replace line endings of different os'es to canonical \n of unix/linux
    asString = regexprep(regexprep(regexprep(asString, '\r\n', '\n'), '\n\r', '\n'), '\r', '\n');
    
    asCellMatrix = data.csvstringread(asString);
end