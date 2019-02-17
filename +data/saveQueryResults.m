function asCellMatrix = saveQueryResults( results, filePath )
%SAVEQUERYRESULTS Summary of this function goes here
%   Detailed explanation goes here

    headers = fieldnames(results);
    columnCount = size(headers,1);
    rowCount = size(utils.multiAnsToArray(results.(headers{1})), 2);
    dataAsCellMatrix = cell(rowCount + 1, columnCount);
    dataAsCellMatrix(1,:) = headers';
    for i = 1:columnCount
        dataAsCellMatrix(2:end, i) = utils.multiAnsToArray(results.(headers{i}))';
    end
    
    asCsvString = cellMatrixToCsvString(dataAsCellMatrix);
    
    utils.filewrite(asCsvString, filePath);
end

function csvString = cellMatrixToCsvString(cellMatrix)
    [rowCount, columnCount] = size(cellMatrix);
    csvString = '';
    for rowIndex = 1:rowCount
        row = cellMatrix(rowIndex,:);
        cellsInQuotes = cellfun(@(v) ['"' v '"'], row, 'UniformOutput', false);
        commaSeparated = strjoin(cellsInQuotes, ',');
        csvString = [csvString commaSeparated sprintf('\n')];
    end
end