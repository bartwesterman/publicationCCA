function [ f, b ] = HeatBarChart( resultMatrix )
    resultMatrix = resultMatrix';
    f = figure;

    b = bar3(resultMatrix);
    
    sortedValues = sort(resultMatrix(~isnan(resultMatrix(:))), 'descend');
    cutoffValue = sortedValues(9);
    
    cb = colorbar;
    cb.Position(2) = .1;
    cb.Position(1) = .88;
    for k = 1:length(b)
        % define colors
        zdata = b(k).ZData;
        b(k).CData = zdata;
        b(k).FaceColor = 'interp'; 
        b(k).EdgeColor = 'none';
        
        % create  text labels
        xdata = get(b(k), 'XData');
        xcoor  = unique(xdata(:));
        xleft  = xcoor(1);
        xright = xcoor(2);
        ydata = get(b(k), 'YData');
        ycoor   = unique(ydata(:));
        for j = 1:(size(resultMatrix, 1))
            if resultMatrix(j, k) <= cutoffValue
                continue;
            end
            ytop    = ycoor(2 + 2 * (j - 1));
            ybottom = ycoor(1 + 2 * (j - 1));
            
            textX = (xleft + xright) / 2;
            textY = (ybottom + ytop) / 2;
            textZ = resultMatrix(j, k) + .02;
            texth = text(textX, textY, textZ, num2str(resultMatrix(j, k), 2), ...
                                  'HorizontalAlignment', 'center', ...
                                  'VerticalAlignment', 'middle',...
                                    'FontSize'       , 17);
        end
        % remove NaN values
        index = repelem(isnan(resultMatrix(:, k)), 6);
        b(k).ZData(index,:) = NaN;

    end
    
    
    
    hXLabel = xlabel('#nodes layer 1');
    set(hXLabel, 'FontSize'       , 27           );

    hYLabel = ylabel('#nodes layer 2');
    set(hYLabel, 'FontSize'       , 27           );
    
    hZLabel = zlabel('weighted pearson correlation');
    set(hZLabel, 'FontSize'       , 27           );
    
    xticklabels({'0', '1', '2','4','8','16','32'});
    yticklabels({'0', '1', '2','4','8','16','32'});
    
    hXTickLabel = get(gca,'XTickLabel');
    set(gca,'XTickLabel',hXTickLabel, 'fontsize',22);
    
    hYTickLabel = get(gca,'YTickLabel');
    set(gca,'YTickLabel',hYTickLabel, 'fontsize',22);
    
    caxis([0 .32]);
    zlim([-.09, .32]);
    axes = gca;
    axes.YDir = 'normal';
    axes.XDir = 'normal';
    view([11.5 50]);
end

