function [ f, s ] = HeatSurface( resultMatrix )
%HEATSURFACE Summary of this function goes here
%   Detailed explanation goes here
    sortedValues = sort(resultMatrix(~isnan(resultMatrix(:))), 'descend');
    cutoffValue = sortedValues(11);

    f = figure;
    caxis([0 .32]);
    zlim([-.09, .32]);
    interpolationCubic = interp2(resultMatrix, 6, 'cubic');        
    interpolationLinear = interp2(resultMatrix, 6, 'linear');    
    interpolationNearest = interp2(resultMatrix, 6, 'nearest');
    
    
    
    interpolation = interpolationNearest;
    
    interpolation(~isnan(interpolationLinear)) = interpolationLinear(~isnan(interpolationLinear));
    
    interpolation(~isnan(interpolationCubic)) = interpolationCubic(~isnan(interpolationCubic));
    % combine
    % interpolation(:) = nanmean([interpolationLinear(:), interpolationNearest(:)],2);
    
    % interpolation(~isnan(interpolationLinear)) = interpolationLinear(~isnan(interpolationLinear));
    s = surfc(interpolation);
    s(1).EdgeColor = 'none';
    s(2).Fill = 'on';
    s(2).LevelStep = .005;
    colorbar;

    hXLabel = xlabel('#nodes layer 2');
    set(hXLabel, 'FontSize'       , 30           );

    hYLabel = ylabel('#nodes layer 1');
    set(hYLabel, 'FontSize'       , 30           );
    
    hZLabel = zlabel('weighted pearson corr.');
    set(hZLabel, 'FontSize'       , 30           );
    
    xRange = size(interpolation,1);
    xStep  = xRange / 6;
    xticks(1:xStep:xRange);
    
    yRange = size(interpolation,2);
    yStep  = yRange / 6;
    xticklabels({'0', '1', '2','4','8','16','32'});
    
    yticks(1:yStep:yRange);
    yticklabels({'0', '1', '2','4','8','16','32'});
    
    hXTickLabel = get(gca,'XTickLabel');
    set(gca,'XTickLabel',hXTickLabel, 'fontsize',22);
    
    hYTickLabel = get(gca,'YTickLabel');
    set(gca,'YTickLabel',hYTickLabel, 'fontsize',22);
    
    xStep = size(interpolation, 1) / size(resultMatrix, 1);
    yStep = size(interpolation, 2) / size(resultMatrix, 2);
    
    for x = 1:(size(resultMatrix, 1))
    for y = 1:(size(resultMatrix, 2))
            if resultMatrix(x, y) <= cutoffValue || isnan(resultMatrix(x, y))
                continue;
            end
            
            
            textX = (x ) * xStep;
            textY = (y )* yStep;
            textZ = resultMatrix(x, y) + .02;
            texth = text(textY, textX, textZ, num2str(resultMatrix(x, y), 2), ...
                                  'HorizontalAlignment', 'center', ...
                                  'VerticalAlignment', 'middle',...
                                    'FontSize'       , 18);
                                
            texth = text(textY, textX, .02, num2str(resultMatrix(x, y), 2), ...
                                  'HorizontalAlignment', 'center', ...
                                  'VerticalAlignment', 'middle',...
                                    'FontSize'       , 18);                                
    end
    end
    caxis([0 .32]);
    zlim([-.09, .32]);
end

