classdef CellMatrixToolkit
    %CELLMATRIXTOOLKIT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function subCellMatrix = subCellMatrix(cellMatrix, xOffset, yOffset, width, height)
            subCellMatrix = cell(0, 0);
            for x = 1:width
                for y = 1:height
                    subCellMatrix{x, y} = cellMatrix{x + xOffset - 1, y + yOffset - 1};
                end
            end
        end
                
        function num = toNumberMatrix(cellMatrix, valueToNumberFunction)
            
            rows = length(cellMatrix);
            
            if isequal(rows, 0)             
                num = [];
                return ;
            end
            
            columns = length(cellMatrix{1});

            num = zeros(rows, columns);
           
            for x = 1:rows
                for y = 1:columns
                    num(x,y) = valueToNumberFunction(cellMatrix{x,y}, x, y);
                end
            end    
        end
       
    end
    
end

