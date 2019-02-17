function asCellMatrix = csvstringread( asString )
%CSVSTRINGREAD Summary of this function goes here
%   Detailed explanation goes here
    
    asLines = regexp(asString, '\n', 'split');
    
    if (strcmp(asLines(end), ''))
        asLines = asLines(1:end-1);
    end
    
    rowCount = length(asLines);
    firstLine = regexp(asLines(1), ',', 'split');
    firstLine = firstLine{1};
    
    columnCount = size(regexp(firstLine, ',', 'split'), 2);
    asCellMatrix = cell(rowCount, columnCount);
    
    for rowIndex = 1:rowCount
        row = regexp(asLines(rowIndex), ',', 'split');
        row = row{1};
        row = remergeShatteredCells(row);
        asCellMatrix(rowIndex, :) = row;
    end
    
    asCellMatrix = cellfun(@(v) strtrim(v),                    asCellMatrix, 'UniformOutput', false);    
    asCellMatrix = cellfun(@(v) regexprep(v, '^"(.*)"', '$1'), asCellMatrix, 'UniformOutput', false);
end

function remergedRow = remergeShatteredCells(row)
    cellCount = size(row, 2);
    remergedRow = cell(1, cellCount);
    remergedCellCount = 0;
    isMerging = false;
    value = '';
    for i = 1:cellCount
        nextCell = row{1, i};
        
        if (~isempty(regexp( nextCell, '^\s*"')))
            isMerging = true;
        end
        
        if (~isempty(regexp(nextCell,  '"\s*$')))
            isMerging = false;
        end
        value = [value nextCell];
        
        if (isMerging)
            continue;
        end
        remergedRow{1, remergedCellCount + 1} = value;
        remergedCellCount = remergedCellCount + 1;
        value = '';
    end
    remergedRow = remergedRow(1:remergedCellCount);
end
