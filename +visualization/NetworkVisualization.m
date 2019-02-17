classdef NetworkVisualization < handle
    %NETWORKVISUALIZATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        networkFigure;
        baseGraph;
        networkPlot;
        background;
        
        layerNameArray;
        layerArray;
        layerIsActive; 
        
        timeSlider;
        timeEdit;
        layerManagementGroup;
        layerGui;
        
        currentTime;
    end
    
    methods
        function obj = init(obj, connectionMatrix, nodePositions, nodeLabels)
            obj.networkFigure = figure('Position', [0, 0, 1400, 900]);
            
            obj.initNetworkPlot(connectionMatrix, nodePositions, nodeLabels);
            
            obj.background = gca;
            obj.background.Color = [1 1 1];

            obj.layerNameArray     = cell(0, 1);            
            obj.layerArray     = cell(0,2);
            obj.layerIsActive  = zeros(0,1);

            obj.currentTime = 0;

            obj.timeSlider     = uicontrol(obj.networkFigure,...
                'Style', 'slider',...
                'Min',0,'Max',1,'Value',0,...
                'Position', [320 0 990 20],...
                'Callback', @(hObj, callbackData) obj.updateTime(hObj.Value)...
            );
        
            obj.timeEdit = uicontrol(obj.networkFigure,...
                'style', 'edit',...
                'String', num2str(obj.currentTime),...
                'Position', [270 0 50 20],...
                'Callback', @(hObj, callbackData, handles)...
                    obj.updateTime(...
                        obj.indexToTime(...
                            str2num(hObj.get('String'))...
                ))...
            );
            
            obj.layerManagementGroup = uipanel('Parent', obj.networkFigure, 'Title', 'layers', 'Visible','on',...
                  'Position',[0 0 .2 1]);
            
            obj.layerGui = {};
            
        end
        
        
        function index = timeToIndex(obj, time)
            longestLayer = max(cellfun(@length, obj.layerArray));

            index = num2str(round(time * longestLayer));
        end
        
        function time = indexToTime(obj, index)
            longestLayer = max(cellfun(@length, obj.layerArray));

            time = index / longestLayer;
        end
        
        function updateTime(obj, time)
            obj.currentTime = time;
            obj.timeEdit.set('String', obj.timeToIndex(time));
            obj.timeSlider.set('Value', time);
            visualizationLayers = obj.getActiveLayersAt(time);
            
            if isempty(visualizationLayers)
                return;
            end
            currentLayer = visualizationLayers{1};
            
            nodeStyleCollectorTable = currentLayer{1};
            edgeStyleCollectorTable = currentLayer{2};
            
            % nodeCountTable = varfun(@(v) v ~= -1, nodeStyleCollectorTable);
            nodeCountTable = nodeStyleCollectorTable;
            nodeCountTable.red       = nodeCountTable.red       ~= 1;
            nodeCountTable.green     = nodeCountTable.green     ~= 1;
            nodeCountTable.blue      = nodeCountTable.blue      ~= 1;
            nodeCountTable.alpha     = nodeCountTable.alpha     ~= 1;
            nodeCountTable.thickness = nodeCountTable.thickness ~= 1;
            
            % edgeCountTable = varfun(@(v) v ~= -1, edgeStyleCollectorTable);
            edgeCountTable = edgeStyleCollectorTable;
            edgeCountTable.red       = edgeCountTable.red       ~= 1;
            edgeCountTable.green     = edgeCountTable.green     ~= 1;
            edgeCountTable.blue      = edgeCountTable.blue      ~= 1;
            edgeCountTable.alpha     = edgeCountTable.alpha     ~= 1;
            edgeCountTable.thickness = edgeCountTable.thickness ~= 1;
            
            for i = 2:length(visualizationLayers)
                currentLayer = visualizationLayers{i};
                nodeStyleAddedTable = currentLayer{1};
                edgeStyleAddedTable = currentLayer{2};
                [nodeStyleCollectorTable, nodeCountTable] = obj.mergeStyleTable(nodeStyleCollectorTable, nodeStyleAddedTable, nodeCountTable);
                [edgeStyleCollectorTable, edgeCountTable] = obj.mergeStyleTable(edgeStyleCollectorTable, edgeStyleAddedTable, edgeCountTable);
                
            end
            
            function replacement = replaceMinusOneWithZero(value)
                if value == -1
                    replacement = 0;
                    return;
                end
                
                replacement = value;                
            end
            
            nodeStyleCollectorTable.red       = arrayfun(@replaceMinusOneWithZero, nodeStyleCollectorTable.red);
            nodeStyleCollectorTable.green     = arrayfun(@replaceMinusOneWithZero, nodeStyleCollectorTable.green);
            nodeStyleCollectorTable.blue      = arrayfun(@replaceMinusOneWithZero, nodeStyleCollectorTable.blue);
            nodeStyleCollectorTable.alpha     = arrayfun(@replaceMinusOneWithZero, nodeStyleCollectorTable.alpha);
            nodeStyleCollectorTable.thickness = arrayfun(@replaceMinusOneWithZero, nodeStyleCollectorTable.thickness);

            edgeStyleCollectorTable.red       = arrayfun(@replaceMinusOneWithZero, edgeStyleCollectorTable.red);
            edgeStyleCollectorTable.green     = arrayfun(@replaceMinusOneWithZero, edgeStyleCollectorTable.green);
            edgeStyleCollectorTable.blue      = arrayfun(@replaceMinusOneWithZero, edgeStyleCollectorTable.blue);
            edgeStyleCollectorTable.alpha     = arrayfun(@replaceMinusOneWithZero, edgeStyleCollectorTable.alpha);
            edgeStyleCollectorTable.thickness = arrayfun(@replaceMinusOneWithZero, edgeStyleCollectorTable.thickness);
            
%             varfun(@replaceMinusOneWithZero, nodeStyleCollectorTable);
%             varfun(@replaceMinusOneWithZero, edgeStyleCollectorTable);
            
            obj.updateVisualization(nodeStyleCollectorTable, edgeStyleCollectorTable);
        end
        
        function [collectorTable, countTable] = mergeStyleTable(obj, collectorTable, addedTable, countTable)
            columnNames = collectorTable.Properties.VariableNames;
            
            for i = 1:length(columnNames);
                columnName = collectorTable.Properties.VariableNames{i};
                
                [collectorTable.(columnName), countTable.(columnName)] = obj.mergeStyleColumn(collectorTable.(columnName), addedTable.(columnName), countTable.(columnName));
            end
        end
        
        function [collectorColumn, newCountColumn] = mergeStyleColumn(obj, collectorColumn, addedColumn, countColumn)
            
            undefinedCollectorIndexes = ~(collectorColumn ~= -1);
            undefinedAddedIndexes     = ~(addedColumn ~= -1);
            
            bothDefined = ~undefinedCollectorIndexes & ~undefinedAddedIndexes;
            
            newCountColumn = countColumn + ~undefinedAddedIndexes;
            
            collectorColumn(undefinedCollectorIndexes) = addedColumn(undefinedCollectorIndexes);
            collectorColumn(bothDefined) = collectorColumn(bothDefined) .* countColumn(bothDefined) ./ newCountColumn(bothDefined) + addedColumn(bothDefined) ./ newCountColumn(bothDefined);       
        end
        
        function currentStatePerLayer = getActiveLayersAt(obj, time)
            
            activeLayerCellArray = obj.layerArray(logical(obj.layerIsActive));
            
            layerAtTimeInhistory = @(history) history{ 1 + round(time * (length(history) - 1))};
            
            currentStatePerLayer = cellfun(layerAtTimeInhistory, activeLayerCellArray, 'UniformOutput', false);
            
        end

        function updateVisualization(obj, nodeAttributes, edgeAttributes)
            obj.networkPlot.NodeColor    = [nodeAttributes.red, nodeAttributes.green, nodeAttributes.blue];
            obj.networkPlot.EdgeColor    = [edgeAttributes.red, edgeAttributes.green, edgeAttributes.blue];
            % obj.networkPlot.NodeAlpha    = nodeAttributes.alpha;
            % obj.networkPlot.EdgeAlpha    = edgeAttributes.alpha;
            obj.networkPlot.LineWidth    = edgeAttributes.thickness + .01;
            obj.networkPlot.MarkerSize   = nodeAttributes.thickness + .01; 
        end
              
        function initNetworkPlot(obj, connectionMatrix, nodePositions, nodeLabels)
            obj.baseGraph = digraph(sparse(connectionMatrix));
            
            obj.networkPlot = plot(obj.baseGraph);
            
            % obj.networkPlot.layout('force', 'Xstart', nodePositions(:,1), 'Ystart', nodePositions(:,2), 'iterations', 0);
            obj.networkPlot.NodeLabel = nodeLabels;
            obj.networkPlot.XData = nodePositions(:,1);
            obj.networkPlot.YData = nodePositions(:,2);
        end
        
        function addLayer(obj, name, newLayer)
            
            obj.layerNameArray(end + 1) = {name};
            obj.layerIsActive(end + 1 ) = true;
            obj.layerArray(end + 1)     = {newLayer};
            
            obj.addLayerGui(length(obj.layerArray));
            obj.updateTime(obj.currentTime);
        end
        
        function addLayerGui(obj, layerIndex)
            
            % layerGroup = uipanel('Title', 'grrr', 'Parent', obj.layerManagementGroup, 'Visible','on', 'Position', [0    (layerIndex - 1) * 50    200 30]);
              
            % label = {uicontrol(obj.layerManagementGroup, 'Style', 'text', 'String', obj.layerNameArray{layerIndex}, 'Position', [0    0    100 30], 'HandleVisibility', 'off', 'Visible', 'on')};
            
            function setLayerIsActive(checkboxObject, eventData, handles) 
                obj.layerIsActive(layerIndex) = logical(get(checkboxObject,'Value') == get(checkboxObject,'Max'));
                obj.updateTime(obj.currentTime);
            end
              
            checkbox = {uicontrol(obj.layerManagementGroup,'Style','checkbox',...
                  'String',           obj.layerNameArray{layerIndex},...
                  'Position',         [0  layerIndex * 50    100 30],...
                  'HandleVisibility', 'off',...
                  'Visible', 'on',...
                  'Value', true,...
                  'Callback',...
                       @setLayerIsActive...
            )};

            obj.layerGui = vertcat(obj.layerGui, checkbox);  
        end
        
        function styleTableHistory = mapNetworkHistoryToStyleTableHistoryProperty(obj, networkHistory, styleProperty)
            historyLength = length(networkHistory);
            
            lowestInHistory = Inf;
            highestInHistory = -Inf;
            
            for i = 1:historyLength
                networkState = networkHistory{i};
                highestInHistory = max([highestInHistory, max(max(networkState))]);
                lowestInHistory = min([lowestInHistory, min(min(networkState))]);
            end
            
            historyRange = highestInHistory - lowestInHistory;
            function s = scale(v) 
                if historyRange == 0
                    s = repmat(.5, size(v));
                    return;
                end
                
                s = ( v - lowestInHistory) / historyRange;
            end
            
           
            
            styleTableHistory = cell(historyLength, 1);
            
            nodeCount = height(obj.baseGraph.Nodes);
            edgeCount = height(obj.baseGraph.Edges);
            
            unusedValueColumn = ones(nodeCount, 1) * -1;
            red           = unusedValueColumn;
            green         = unusedValueColumn;
            blue          = unusedValueColumn;
            alpha         = unusedValueColumn;
            thickness     = unusedValueColumn;
            
            nodeStyleTable = table(red, green, blue, alpha, thickness);

            unusedValueColumn = ones(edgeCount, 1) * -1;
            red           = unusedValueColumn;
            green         = unusedValueColumn;
            blue          = unusedValueColumn;
            alpha         = unusedValueColumn;
            thickness     = unusedValueColumn;
            
            edgeStyleTable = table(red, green, blue, alpha, thickness);
            
            for i = 1:historyLength
                nextNodeStyleTable = nodeStyleTable;
                nextEdgeStyleTable = edgeStyleTable;
                
                currentNetwork     = networkHistory{i};
                nodeValues         = currentNetwork(1, :)';
                connectionMatrix   = currentNetwork(2:end, :);
                
                graphRepresentation = digraph(connectionMatrix);
                
                for j = 1:height(obj.baseGraph.Edges)
                    startIndex = obj.baseGraph.Edges.EndNodes(j, 1);
                    endIndex   = obj.baseGraph.Edges.EndNodes(j, 2);
                    
                    if ~graphRepresentation.findedge(startIndex, endIndex)
                        graphRepresentation = graphRepresentation.addedge(startIndex, endIndex, connectionMatrix(startIndex, endIndex));
                    end
                end
                
                nodeStyleTable.(styleProperty) = scale(nodeValues);
                edgeStyleTable.(styleProperty) = scale(graphRepresentation.Edges.Weight);
                
                nextStyleHistoryNode = {nextNodeStyleTable, nextEdgeStyleTable};
                styleTableHistory(i) = {nextStyleHistoryNode};
            end
        end
        
    end
    
end

