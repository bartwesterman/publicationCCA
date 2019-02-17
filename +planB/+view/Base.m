classdef Base < handle
    %BASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        figure;
        colorMap;
    end
    
    methods
        function obj = init(obj)
            obj.figure = figure;
            obj.colorMap = parula;
            hold on;
        end
        
        function names = tableVarNamesToString(obj, tableVarNames)
            names = regexprep(tableVarNames, '.*___', '')
        end
        
        function color = matchToColor(obj, vec)
            cm = obj.colorMap;
            
            function index = scaleToIndex(vec, val, indexCount)
                maxVal = max(vec);
                minVal = min(vec);
                range  = maxVal - minVal;
                
                valToUnit = (val - minVal) / range;
                index = 1 + round(valToUnit * (indexCount - 1));
            end
           
            
            color = [ones(length(vec), 2) zeros(length(vec), 1)];
            for i = 1:length(vec)
                if ~isnan(vec(i))
                    color(i, :) = cm(scaleToIndex(vec, vec(i), size(cm, 1)), :);
                end
            end
        end
        
        function save(obj, filePath)
            saveas(obj.figure, filePath);
        end
    end
    
end

