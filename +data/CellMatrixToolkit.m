classdef CellMatrixToolkit
    %CELLMATRIXTOOLKIT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function subCellMatrix = subCellMatrix(obj, cellMatrix, xOffset, yOffset, width, height)
            subCellMatrix = cell(0, 0);
            for x = 1:width
                for y = 1:height
                    subCellMatrix{x, y} = cellMatrix{x + xOffset - 1, y + yOffset - 1};
                end
            end
        end
                
        function num = toNumberMatrix(obj, cellMatrix, valueToNumberFunction)
            
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
       
        
%         function rows = matrixToRows(obj, matrix, s, e)
%             columnLabels = matrix(s(2),(s(1)+1):e(1));
%             rowLabels    = matrix((s(2)+1):e(2), s(1));
%             
%             subMatrix = matrix((s(2)+1):e(2), (s(1)+1));
%             
%             rows = obj.privateMatrixToRows(subMatrix, columnLabels, rowLabels);
%         end
        
        function rows = flattenMatrixToRows(obj, matrix, rowLabels, columnLabels)
            
            [rowCount, columnCount] = size(matrix);
            rows = cell(rowCount * columnCount, size(rowLabels, 2) + size(columnLabels, 1) + 1);

            for matrixRow = 1:rowCount
                for matrixColumn = 1:columnCount
                    rowIndex = (matrixRow - 1) * columnCount + matrixColumn;
                    rows( rowIndex, :) = [rowLabels(matrixRow,:)  columnLabels(matrixColumn) matrix(matrixRow, matrixColumn)];
                end
            end
        end
        
    end
    
end

