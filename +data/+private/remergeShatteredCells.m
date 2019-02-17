
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
