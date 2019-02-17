function cellMatrix = struct2cellMatrix( structInput, columnOrder )
%STRUCT2CELLMATRIX Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 2
        columnOrder = fieldnames(structInput);
    end

    rowCount = length(structInput);
    columnCount = length(columnOrder);
    
    cellMatrix = cell(rowCount + 1, columnCount);
    
    cellMatrix(1, :) = columnOrder;
    
    for i = 1:columnCount
        column = utils.multiAnsToArray(structInput.(columnOrder{i}))';
        cellMatrix(2:end, i) = column;
    end
end

