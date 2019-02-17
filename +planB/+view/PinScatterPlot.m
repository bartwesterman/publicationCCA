classdef PinScatterPlot < planB.view.Base
    %PINSCATTERPLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = init(obj, coordinates, titleString, xLabel, yLabel, zLabel)
            init@planB.view.Base(obj);
            obj.colorMap = [(0:(1/63):1)', zeros(64,1) * .5, (1:-(1/63):0)'];
            heightColor = obj.matchToColor(coordinates(:, 3));
            zCoordinates = coordinates(:,3);
            zCoordinates(isnan(zCoordinates)) = 0;
            scatter3(coordinates(:,1), coordinates(:,2), zCoordinates, 20, heightColor, 'filled');
            heightLabels = strrep(cellstr(num2str(coordinates(:,3),2)), '0.', '.');
            [~, highestNumiricalIndices] = sort(coordinates(:,3), 'descend');
            highestNumiricalIndices = highestNumiricalIndices(1:10);
            highestLogicalIndices = zeros(size(coordinates,1), 1);
            highestLogicalIndices(highestNumiricalIndices) = 1;
            heightLabels(~highestLogicalIndices) = {''};
            text(coordinates(:,1), coordinates(:,2), coordinates(:,3) + .03, heightLabels);
            bottomPin = coordinates;
            bottomPin(:,3) = 0;
            
            pinColor = [0 0 0];
            shadowColor = [.9, .9, .9];
            for i = 1:size(bottomPin, 1)
                pinLine     = [bottomPin(i, :) ; coordinates(i, :)];
                
                shadowXComponent = [bottomPin(i, :) ; [max(coordinates(:,1)), coordinates(i, 2), 0]];
                shadowYComponent = [bottomPin(i, :) ; [coordinates(i, 1), max(coordinates(:,2)), 0]];
                
                l = plot3(pinLine(:,1), pinLine(:,2), pinLine(:,3), 'Color', [heightColor(i, :) .1] ,  'LineWidth', 4); 
                line(shadowXComponent(:,1), shadowXComponent(:,2), shadowXComponent(:,3), 'Color', shadowColor); 
                line(shadowYComponent(:,1), shadowYComponent(:,2), shadowYComponent(:,3), 'Color', shadowColor); 
                
            end
            title(titleString);
            xlabel(xLabel);
            ylabel(yLabel);
            zlabel(zLabel);
            
            xticks(unique(coordinates(:,1)));
            yticks(unique(coordinates(:,2)));
            
            view([ 37.5 30]);
            axis([min(coordinates(:,1)) max(coordinates(:,1)) min(coordinates(:,2)) max(coordinates(:,2)) 0 max(coordinates(:,3))]);
        end
    end
    
end

