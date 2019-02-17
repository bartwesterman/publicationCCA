function f = PlotForPaper( X, Y, t, xLabel, yLabel)
%PLOTFORPAPER Summary of this function goes here
%   Detailed explanation goes here

    f = figure;
    
    hPlot = plot(X, Y);
    set(hPlot, 'LineWidth'       , 7           );
    hTitle = title(t);
    set(hTitle, 'FontSize'       , 30           );
    
    hXLabel = xlabel(xLabel);
    set(hXLabel, 'FontSize'       , 30           );
    hYLabel = ylabel(yLabel);
    set(hYLabel, 'FontSize'       , 30           );
    
    
    hXTickLabel = get(gca,'XTickLabel');
    set(gca,'XTickLabel',hXTickLabel, 'fontsize',22);
    
    hYTickLabel = get(gca,'YTickLabel');
    set(gca,'YTickLabel',hYTickLabel, 'fontsize',22);
    
    xRange = max(X) - min(X);
    xTickLevels = utils.roundToMostSignificantNumbers([min(X), min(X) + xRange / 3, min(X) + xRange * 2 / 3 ,max(X)], 2);
    yTickLevels = utils.roundToMostSignificantNumbers([min(Y), (min(Y) + max(Y)) / 2, max(Y)], 2);
    
    set(gca,'Xtick', xTickLevels, 'XTickLabel', xTickLevels);
    set(gca,'Ytick',yTickLevels,'YTickLabel', yTickLevels);

%     
%     XLim = get(gca,'XLim');
%     set(gca,'XTick',linspace(XLim(1),XLim(2),4))
%     
%     YLim = get(gca,'YLim');
%     set(gca,'YTick',linspace(YLim(1),YLim(2),3))
end

