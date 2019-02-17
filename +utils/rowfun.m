function columnVector = rowfun( f, matrix )
%ROWFUN Summary of this function goes here
%   Detailed explanation goes here
    
    if (iscell(matrix))
        columnVector = cellRowfun( f, matrix);
    else
        columnVector = numRowFun( f, matrix);
    end


end

function columnVector = cellRowfun( f, cellMatrix)
    rowCount = size(cellMatrix, 1);

    columnVector = cell(rowCount, 1);
    for i = 1:rowCount
        columnVector{i} = f(cellMatrix(i, :));
    end
end

function columnVector = numRowFun( f, matrix)
    rowCount = size(matrix, 1);

    columnVector = cell(rowCount, 1);
    for i = 1:rowCount
        columnVector{i} = f(matrix(i, :));
    end
end