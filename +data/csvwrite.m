function csvwrite( cellMatrix, csvFilePath )
%CSVWRITE Summary of this function goes here
%   Detailed explanation goes here
    text = data.csvstring(cellMatrix);
    utils.filewrite(text, csvFilePath);
end

