classdef MultiLinePlot < planB.view.Base
    %MULTILINEPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = init(obj, dataTable, titleString, xLabel, yLabel)
            init@planB.view.Base(obj);
            
            lineCount = width(dataTable);
            cm = parula;
            colorCount = size(cm, 1);
            determineColor = @(index) cm(1 + round((colorCount - 1) * ((index - 1) / (lineCount - 1))), :);
            
            for i = 1:lineCount
                color = determineColor(i);
                plot((1:height(dataTable))', table2array(dataTable(:, i)), 'Color', color);
            end
            
            title(titleString);
            
            xlabel(xLabel);
            ylabel(yLabel);
            
            if ~isempty(dataTable.Properties.RowNames)
                xticklabels(obj.tableVarNamesToString(dataTable.Properties.RowNames));
                
            end
            legend(obj.tableVarNamesToString(dataTable.Properties.VariableNames), 'location','northeastoutside');
        end
    end
    
end

