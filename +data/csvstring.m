function asString = csvstring( cellMatrix )
%THSSTRING Summary of this function goes here
%   Detailed explanation goes here
    function v = escape(v)
        v = ['"' utils.toString(v) '"'];
    end

    function asString = thsRowToString(row)
        if(~iscell(row))
            row = num2cell(row);
        end
        rowEscaped = cellfun(@escape, row, 'UniformOutput', false);
        
        asString = strjoin(rowEscaped, ', ');
    end

    cellStringArray = utils.rowfun(@thsRowToString, cellMatrix);
    
    asString = strjoin(cellStringArray, sprintf('\n'));

end

