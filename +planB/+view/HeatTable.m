function f = HeatTable( matrixData, xLevels, yLevels, t, xLabel, yLabel, scale, translation, topValueCount, bottomValueCount, valueColors)
%HEATTABLE Summary of this function goes here
%   Detailed explanation goes here

    xTickLabels = arrayfun(@(v){num2str(v)}, xLevels);
    yTickLabels = arrayfun(@(v){num2str(v)}, yLevels);
    
    f = figure;
    
    hTitle = title(t);
    set(hTitle, 'FontSize'       , 30           );
    
    hXLabel = xlabel(xLabel);
    set(hXLabel, 'FontSize'       , 30           );
    hYLabel = ylabel(yLabel);
    set(hYLabel, 'FontSize'       , 30           );
    if ~exist('valueColors','var')
        valueColors = cool;
    end
    toColorIndex = @(v) 1 + floor((size(valueColors, 1) - 1) * ((scale * v) - translation));
    colorIndexMatrix = zeros(size(matrixData));
    colorIndexMatrix = toColorIndex(matrixData);
    toColor = @(v) valueColors(1 + floor((size(valueColors, 1) - 1) * ((scale * v) - translation)), :);
    
    xticks((1:size(matrixData, 1)) + .5);
    xticklabels(xTickLabels);
    yticks((1:size(matrixData, 2)) + .5);
    yticklabels(yTickLabels);
    
    hXTickLabel = get(gca,'XTickLabel');
    set(gca,'XTickLabel',hXTickLabel, 'fontsize',22);
    
    hYTickLabel = get(gca,'YTickLabel');
    set(gca,'YTickLabel',hYTickLabel, 'fontsize',22);
    
    allValues = matrixData(:);
    allValuesWithoutNaN = allValues(~isnan(allValues));
    sortedValues = sort(allValuesWithoutNaN, 'descend');
    topValues    = sortedValues(1:topValueCount);
    bottomValues = sortedValues((end - bottomValueCount + 1):end);
    unknownColor = [0,0,0];
    for x = 1:size(matrixData, 1)
    for y = 1:size(matrixData, 2)
        
        if isnan(matrixData(x,y))
            faceColor = unknownColor;
            cellText  = '?';
            textColor = [1 1 1];
        else
            faceColor = toColor(matrixData(x, y));
            cellText  =  num2str(round(matrixData(x, y) * 100)/100);
            textColor = [0 0 0];            
        end
        
        
        
        rectangle('Position',[x y 1 1], 'FaceColor', faceColor, 'LineStyle', 'none');
        
        if any(ismember(matrixData(x,y), topValues)) || any(ismember(matrixData(x,y), bottomValues)) 
            text(x + .2, y + .5,cellText,'Color',textColor,'FontSize',20);
        end
        
        if isnan(matrixData(x,y))
            text(x + .4, y + .5,cellText,'Color',textColor,'FontSize',20);
        end
    end
    end
    set(gca, 'XLim', [1 (size(matrixData, 1) + 1)]);
    set(gca, 'YLim', [1 (size(matrixData, 2) + 1)]);

end

