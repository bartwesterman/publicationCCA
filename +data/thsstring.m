function asString = thsstring( cellArrayArray )
%THSSTRING Summary of this function goes here
%   Detailed explanation goes here
    function v = escape(v)
        v = ['"' v '"'];
    end

    function asString = thsRowToString(row) 
        rowEscaped = cellfun(@escape, row, 'UniformOutput', false);
        
        asString = strjoin(rowEscaped, ', ');
    end

    cellStringArray = cellfun(@thsRowToString, cellArrayArray,  'UniformOutput', false);
    
    asString = strjoin(cellStringArray, sprintf('\n'));

end

