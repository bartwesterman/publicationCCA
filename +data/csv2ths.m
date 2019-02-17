function csv2ths( csvFilePath, thsFilePath )
%CSVTOTHS Summary of this function goes here
%   Detailed explanation goes here

    csvCellMatrix = data.csvread(csvFilePath);
    
    rowCount = size(csvCellMatrix, 1);
    
    thsArrayArrayWithEmptyRows = cell(rowCount, 1);
    
    for rowIndex = 1:rowCount
        row = csvCellMatrix(rowIndex, :);
        rowWithoutEmpty = row(~cellfun(@isempty, row));
        thsArrayArrayWithEmptyRows{rowIndex} = rowWithoutEmpty;
    end
    
    thsArrayArray = thsArrayArrayWithEmptyRows(~cellfun(@isempty, thsArrayArrayWithEmptyRows));
    
    data.thswrite(thsArrayArray, thsFilePath);
end

