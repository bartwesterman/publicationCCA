classdef RibbonGraphBuilder < planB.view.Base
    %GRAPHBUILDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = init(obj, titleString, xLabelString, yLabelString, dataTable)
            init@planB.view.Base(obj);

            z = table2array(dataTable);
            infiniteValues = NaN * ones(size(z));
            infiniteValues(z == Inf)  = 0;
            z(z == Inf) = NaN;
            
            maxVal = max(max(z));
            minVal = min(min(z));
            scaleToUnit = @(v)(v - minVal) ./ (maxVal - minVal);

            
            ribbonMeshes = ribbon(z);
            for i = 1:length(ribbonMeshes)
                ribbonMeshes(i).EdgeColor = 'none';
                ribbonMeshes(i).FaceLighting = 'gouraud';
                ribbonMeshes(i).FaceColor = 'texturemap';
                
                ribbonMeshes(i).CData(:,:) = ceil(64 * scaleToUnit(ribbonMeshes(i).ZData));
            end
            title(titleString);
            xlabel(xLabelString);
            ylabel(yLabelString);
            xticks(1:(width(dataTable)));
            xTickLabelsWithoutVarPrefix = obj.tableVarNamesToString(dataTable.Properties.VariableNames);
            xticklabels(xTickLabelsWithoutVarPrefix);
            view([ -37.5 30]);

            if ~isempty(dataTable.Properties.RowNames)
                yTickLabelsWithoutVarPrefix = obj.tableVarNamesToString(dataTable.Properties.RowNames);
                yticklabels(yTickLabelsWithoutVarPrefix);
                yticks(1:(height(dataTable)));   
            end
            
            % yticks(1:max(1, (height(dataTable) / 7)):height(dataTable));
            if all(all(isnan(infiniteValues)))
                return;
            end
            infiniteMeshes = ribbon(infiniteValues);
            for i = 1:length(infiniteMeshes)
                infiniteMeshes(i).EdgeColor = 'red';
                infiniteMeshes(i).FaceColor = 'red';
            end
            legend(infiniteMeshes(1), 'Infinite values');
        end
    end
    
end

