function asCellMatrix = thsread(filePath)
%CSVREAD Summary of this function goes here
%   Detailed explanation goes here

    asString = fileread(filePath);
    asString = regexprep(regexprep(regexprep(asString, '\r\n', '\n'), '\n\r', '\n'), '\r', '\n');
    
    asLines = regexp(asString, '\n', 'split');
    
    rowCount = length(asLines);
    
    asCellMatrix = cell(rowCount, 1);
    
    for rowIndex = 1:rowCount
        row = regexp(asLines(rowIndex), ',', 'split');
        row = row{1};
        row = data.private.remergeShatteredCells(row);
        asCellMatrix{rowIndex} = row;
    end
    
    asCellMatrix = cellfun(@(v) strtrim(v),                    asCellMatrix, 'UniformOutput', false);    
    asCellMatrix = cellfun(@(v) regexprep(v, '^"(.*)"', '$1'), asCellMatrix, 'UniformOutput', false);
end
