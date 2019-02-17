function queryResult2csv( result, filePath )
%RESULTTOCSV Summary of this function goes here
%   Detailed explanation goes here

    cellMatrix = utils.struct2cellMatrix(result);
    data.csvwrite(cellMatrix, filePath);
end

