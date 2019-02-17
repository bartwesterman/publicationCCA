classdef BlockAnalysis
    %BLOCKANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        matrix;
        shuffledMatrix;
        rowOrder;
        columnOrder;
        
    end
    
    methods
        
        function indexOrder = treeMatrixToIndexOrder(obj, treeMatrix, highestLeafIndex)

            indexOrder = zeros(highestLeafIndex, 1);
            indexOrderCursor = 1;

            currentNode = treeMatrix(end, :);

            nodeStack = zeros(size(treeMatrix, 1), 1);
            stackCursor = 1;

            while nodeCursor > 0
                if (currentNode <= highestLeafIndex)
                    indexOrder(indexOrderCursor) = currentNode;
                    stackCursor = stackCursor - 1;
                    currentNode = nodeStack(stackCursor);
                    continue; 
                end

                for childIndex = 1:2
                    nextChild = treeMatrix(currentNode - highestLeafIndex,childIndex);
                    if (nextChild ~= 0)
                        stackCursor = stackCursor + 1;
                        nodeStack(stackCursor) = nextChild;
                    end
                end
            end
        end

        function inContrast = sequencesInContrast(obj, sequenceA, sequenceB)
            inContrast = sum(sequenceA > 0 & sequenceB == 0) > 0;
        end

        function contrastingRowIndexes = getContrastingRowIndexes(obj, matrix)
            contrastingRowIndexes = zeros(size(matrix, 1), 1);
            for i = 1:(size(matrix, 1) - 1)
                rowA = matrix(i, :);
                rowB = matrix(i+1, :);

                contrastingRowIndexes(i)     = obj.sequencesInContrast(rowA, rowB) || contrastingRowIndexes(i);
                contrastingRowIndexes(i + 1) = obj.sequencesInContrast(rowB, rowA);
            end
        end

        function [contrastingRowIndexes, contrastingColumnIndexes] = getContrastingRowColumnIndexes(obj, matrix)
            contrastingRowIndexes    = obj.getContrastingRowIndexes(matrix);
            contrastingColumnIndexes = obj.getContrastingRowColumnIndexes(matrix');
        end

        function obj = init(obj, matrix)
            obj.matrix = matrix;
            
            rowTree    = linkage(matrix);
            columnTree = linkage(matrix');

            obj.rowOrder     = obj.treeMatrixToIndexOrder(rowTree);
            obj.columnOrder  = obj.treeMatrixToIndexOrder(columnTree);

            obj.shuffledMatrix = matrix(obj.rowOrder, obj.columnOrder);

            [contrastingRowIndexes, contrastingColumnIndexes] = obj.getContrastingRowColumnIndexes(obj.shuffledMatrix);

            obj.renderGrid(obj.shuffledMatrix, contrastingRowIndexes, contrastingColumnIndexes);
        end

        function unshuffledIndexRange = getRange(obj, order, start, finish)
            unshuffledIndexRange = sort(order(start:finish));
        end
                
        function unshuffledIndexRange = getRowRange(obj, start, finish)
            unshuffledIndexRange = obj.getRange(obj.rowOrder, start, finish);
        end
        
        function unshuffledIndexRange = getColumnRange(obj, start, finish)
            unshuffledIndexRange = obj.getRange(obj.columnOrder, start, finish);
        end
        

        function renderGrid(obj, matrix, contrastingRowIndexes, contrastingColumnIndexes)
            matrix = obj.shuffledMatrix;
            
            function [transposedX, transposedY] = transpose(x, y)
                transposedX = x + 40;
                transposedY = y + 40;
            end

            function [scaledX, scaledY] = scale(x, y)
                scaledX = 20 * x;
                scaledY = 20 * y;
            end

            function [screenX, screenY] = transformation(x, y)
                [transposedX, transposedY] = transpose(x, y);
                [screenX, screenY] = scale(transposedX, transposedY);
            end

            highestValue = max(max(matrix));

            figure
            hold on
            for x = 1:size(matrix,1)
            for y = 1:size(matrix,2)
                [screenX, screenY] = transformation(x + 1, y + 1);
                [scaleX, scaleY] = scale(1, 1);

                color = [1 1 1 - matrix(x, y)/highestValue];

                rectangle('Position',[screenX screenY, scaleX, scaleY], 'FaceColor', color);
            end
            end

            for x = 1:size(matrix,1)
                if (~contrastingColumnIndexes(x))
                    continue;
                end

                [screenX, screenY] = transformation(x, 1);
                text(screenX, screenY, num2str(x));
            end

            for y = 1:size(matrix,2)
                if (~contrastingRowIndexes(y))
                    continue;
                end

                [screenX, screenY] = transformation(1, y);		
                text(screenX, screenY, num2str(y));
            end

        end


    end
    
end

