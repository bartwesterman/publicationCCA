classdef KeggInterPathwayConnectionMap < handle
    %KEGGINTERPATHWAYCONNECTIONMAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        keggThesaurus;
        
        entryToPathway;
        
        pathwayToEntry;
                
        pathwayCount;
        
        entityIdToIndex;
        
        fromToMatrix;
        
        inputCount;
        
        relevantGeneExpressionList;
    end
    
    methods
        function obj = init(obj, keggThesaurus, pathwayPath, drugToTargetTable, uniqueCellLineIds, mutationData, relevantGeneExpressionList)
            
            obj.entryToPathway  = containers.Map();
            obj.pathwayToEntry  = containers.Map();
            obj.entityIdToIndex = containers.Map();
            
            if (nargin <= 6)
                relevantGeneExpressionList = [];
            end
            
            obj.relevantGeneExpressionList = relevantGeneExpressionList;
            
            obj.loadPathways(keggThesaurus, pathwayPath);
            
            obj.fromToMatrix = obj.initMatrix(obj.entityIdToIndex, obj.entryToPathway, drugToTargetTable, uniqueCellLineIds, mutationData);
            
        end
        
        function loadPathways(obj, keggThesaurus, pathwayPath)
            pathwayFiles = dir([pathwayPath '*.xml']);

            pathwayFileCount = length(pathwayFiles);
            obj.entityIdToIndex = containers.Map();
            
            obj.pathwayCount = 0;
            
            for i = 1:pathwayFileCount
                pathwayFilePath = [pathwayPath pathwayFiles(i).name];

                obj.loadPathway(keggThesaurus, pathwayFilePath);
            end
        end
        
        function loadPathway(obj, keggThesaurus, pathwayFilePath)
            disp(['loading pathway ' pathwayFilePath]);
            
            domTree = xmlread(pathwayFilePath);

            pathwayKeggId = regexp(pathwayFilePath, '\w*(?=\.xml$)', 'match');
            pathwayKeggId = pathwayKeggId{1};
            pathwayEntityId = keggThesaurus.getId(pathwayKeggId);
            
            
            obj.pathwayCount = obj.pathwayCount + 1;            
            obj.entityIdToIndex(num2str(pathwayEntityId)) = obj.pathwayCount;
            
            entries = domTree.getElementsByTagName('entry');

            obj.appendPathwayToEntries(keggThesaurus, pathwayEntityId, entries);
            
        end
        
        function appendPathwayToEntries(obj, keggThesaurus, pathwayEntityId, entriesXml)
            entryList = zeros(1, entriesXml.getLength());
            
            for j = 0:(entriesXml.getLength() - 1)
                entry = entriesXml.item(j);

                keggIds = strsplit(char(entry.getAttribute('name')), ' ');
                entryEntityId = keggThesaurus.getId(keggIds{1});

                entryList(j + 1) = entryEntityId;
            end
            
            expressionFilteredList = entryList;
            if ~isempty(obj.relevantGeneExpressionList)
                expressionFilteredList = intersect(entryList, obj.relevantGeneExpressionList);
            end
            
            arrayfun(@(entryEntityId) obj.appendPathwayToEntry(pathwayEntityId, entryEntityId), expressionFilteredList);
            
            obj.pathwayToEntry(num2str(pathwayEntityId)) = expressionFilteredList;
        end
        
        function appendPathwayToEntry(obj, pathwayEntityId, entryEntityId)
            
            k = num2str(entryEntityId);
            
            if (~obj.entryToPathway.isKey(k))
                obj.entryToPathway(k) = zeros(0);
            end
            
            pathwayVector = obj.entryToPathway(k);
            pathwayVector(end + 1) = pathwayEntityId;
            obj.entryToPathway(k) = pathwayVector;
        end
        
        function m = initMatrix(obj, entityIdToIndex, entryToPathways, drugToTargetTable, uniqueCellLineIds, mutationData)
            
            drugCount = height(drugToTargetTable);
            
            entryCount = length(obj.entryToPathway.keys());
            
            cellLineCount = length(uniqueCellLineIds);
            
            nodeCount = obj.pathwayCount + entryCount + drugCount + cellLineCount; % @TODO include cell line count in the list of inputs
            
            obj.inputCount = drugCount + entryCount + cellLineCount;
            
            pathwayOffset  = 1;
            entryOffset    = pathwayOffset + obj.pathwayCount;
            drugOffset     = entryOffset   + entryCount;
            cellLineOffset = drugOffset    + drugCount;
            
            m = zeros(nodeCount);
            
            % connect all pathways that share compounds
            entryKeys = entryToPathways.keys();
            for i = 1:length(entryKeys)
                entryIdKey = entryKeys{i};
                entryIndex = entryOffset -1 + i;
                
                entityIdToIndex(entryIdKey) = entryIndex;
                
                connectedPathwayIndexList = arrayfun(@(v) entityIdToIndex(num2str(v)), entryToPathways(entryKeys{i}));

                m(entryIndex, connectedPathwayIndexList) = 1;
                
                for j = 1:(size(connectedPathwayIndexList, 2) - 1)
                for k = (j+1):size(connectedPathwayIndexList, 2)
                    x = connectedPathwayIndexList(j);
                    y = connectedPathwayIndexList(k);
                    
                    m(x, y) = 1;
                    m(y, x) = 1;
                end
                end
            end
            
            % link drugs to pathways that contain a compound that contains
            % their target
            function v = getPathwaysForTarget(target) % helper function 
                if ~entryToPathways.isKey(num2str(target))
                    v = [];
                    return;
                end

                v = entryToPathways(num2str(target));
            end
            for i = 1:height(drugToTargetTable)
                drugEntityIdStr = num2str(drugToTargetTable.drug(i));
                targetList   = drugToTargetTable.targetIds{i};
                
                pathwayListList  = arrayfun(@getPathwaysForTarget, targetList, 'UniformOutput', false);
                pathwayList = horzcat(pathwayListList{:});
                
                drugIndex = drugOffset -1 + i;
                
                entityIdToIndex(drugEntityIdStr) = drugIndex;
                
                for j = 1:length(pathwayList)
                    pathwayIndex = entityIdToIndex(num2str(pathwayList(j)));
                    
                    m(drugIndex, pathwayIndex) = 1;
                end
            end
            % insert relationships between cell line and their mutations
            for i = 1:length(uniqueCellLineIds)
                % get index for cell line
                cellLineId = uniqueCellLineIds(i);
                cellLineIndex = cellLineOffset - 1 + i;
                cellLineIdStr = num2str(cellLineId);
                entityIdToIndex(cellLineIdStr) = cellLineIndex;
                

                % get pathways for mutation ids
                mutationIds = mutationData.getCellLineMutations(cellLineId);
                pathwayListList  = arrayfun(@getPathwaysForTarget, mutationIds, 'UniformOutput', false);
                pathwayList = horzcat(pathwayListList{:});
               
                for j = 1:length(pathwayList)
                    % get index for pathways
                    pathwayIndex = entityIdToIndex(num2str(pathwayList(j)));
                    
                    % create association
                    m(cellLineIndex, pathwayIndex) = 1;
                end
            end
            obj.fromToMatrix = m;
        end
        
        function m = getMatrix(obj)
            m = obj.fromToMatrix;
        end
        function bestPathwayList = bestPathwayCombination(obj, targetIdSet, maxPathwayCount)
            bestUniqueTargetCount = -Inf;
            availablePathways = cellfun(@str2num, obj.pathwayToEntry.keys);
            
            targetsPerPathway = containers.Map();
            
            for i = 1:length(obj.pathwayToEntry.keys)
                pathwayKeys = obj.pathwayToEntry.keys;
                pathwayKey  = pathwayKeys{i};
                
                allEntries = obj.pathwayToEntry(pathwayKey);
                targetsPerPathway(pathwayKey) = targetIdSet(ismember(cellfun(@str2num, targetIdSet), allEntries));
            end
            
            maxUniqueTargetCount = length(targetIdSet);
            
            for combinedPathwayCount = 1:maxPathwayCount
                pathwayCombinations = nchoosek(availablePathways, combinedPathwayCount);
                
                for c = 1:length(pathwayCombinations)
                    pathwayList = pathwayCombinations(c, :);
                    uniqueTargetCount = obj.getUniqueTargetCountOfPathwayList(targetsPerPathway, pathwayList);
                    
                    if bestUniqueTargetCount < uniqueTargetCount
                        bestPathwayList       = pathwayList;
                        bestUniqueTargetCount = uniqueTargetCount;
                        
                        if bestUniqueTargetCount == maxUniqueTargetCount
                            return;
                        end
                    end
                end
            end
        end
        
        function uniqueTargetCount = getUniqueTargetCountOfPathwayList(obj, targetsPerPathway, pathwayList)
            uniqueTargetMap = containers.Map();
            
            for i = 1:length(pathwayList)
                targetList = targetsPerPathway(num2str(pathwayList(i)));
                
                for j = 1:length(targetList)
                    uniqueTargetMap(targetList{j}) = true;
                end
            end
            
            uniqueTargetCount = length(uniqueTargetMap.keys);
        end
        
        function indexToEntityIdArray = getOrderedEntityIds(obj)
            entityIdStrings = obj.entityIdToIndex.keys();
            entityCount     = length(entityIdStrings);
            
            indexToEntityIdArray = zeros(length(entityIdStrings), 1);
            
            
            for i = 1:entityCount;
                entityIdString = entityIdStrings{i};
                
                index = obj.entityIdToIndex(entityIdString);
                
                indexToEntityIdArray(index) = str2double(entityIdString);
            end
        end
        
        function entityIds = getEntityIdsOfPathway(obj, pathwayEntityId)
            if ~obj.pathwayToEntry.isKey(num2str(pathwayEntityId))
                entityIds = [];
                return;
            end
            
            entityIds = obj.pathwayToEntry(num2str(pathwayEntityId));
        end
        
        function inputCount = getInputCount(obj)
            inputCount = obj.inputCount;
        end
        
        function pathwayIds = getPathwayIdsForEntityIds(obj, entityIds)
            pathwayIds = zeros(size(entityIds));
            
            for i = 1:length(entityIds)
                pathwayIds(i) = obj.entryToPathway(num2str(entityIds(i)));
            end            
        end
        
        function legend = getLegend(obj, em)
            entityIdKeys = obj.entityIdToIndex.keys();
            indices      = zeros(length(entityIdKeys));
            
            for i = 1:length(entityIdKeys)
                indices(i) = obj.entityIdToIndex(entityIdKeys{i});
            end
            
            [unused, order] = sort(indices);
            
            orderedEntityIdKeys = entityIdKeys(order);
            
            legend = cell(length(orderedEntityIdKeys),2);
            
            for i = 1:length(orderedEntityIdKeys)
                [label, type] = em.getLabel(str2double(orderedEntityIdKeys{i}));
                legend{i,1} = label;
                legend{i,2} = type;
            end
        end
    end
    
end

