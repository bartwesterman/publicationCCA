classdef DreamTargetData < handle
    %DREAMTARGETDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        targetData;
        targetCountPerPathway;
        targetsPerPathway;
        accumulatedTargetTable;
    end
    
    methods
        function obj = init(obj, thesauri, dreamTargetFilePath)

            if nargin < 3
                dreamTargetFilePath = Config.DREAM_TARGET_FILE;
            end
            
            targetDataTable = readtable(dreamTargetFilePath, 'Format', repmat('%q', 1, 13));
            
            drugThesaurus = thesauri.get('drug');
            keggThesaurus = thesauri.get('kegg');
                        
            drugNames = targetDataTable.ChallengeName;
            rawTargetKeggIds  = targetDataTable.keggIDs;

            
            targetIds = cellfun(@(v) obj.extractKeggEntityIdArray(keggThesaurus, v), rawTargetKeggIds, 'UniformOutput', false);
            drug         = cellfun(@(v) drugThesaurus.getId(v), drugNames);
            
            obj.targetData = table(drug, targetIds);
            
            rawPathwayKeggIds = targetDataTable.pathways;
            
            obj.initPathwayData(rawPathwayKeggIds, targetIds);

        end
        
        function uniqueTargetMap = computeUniqueTargetIds(obj)
            
            targetListList = obj.targetData.targetIds;
            
            uniqueTargetMap = containers.Map();
            
            uniqueTargetList = unique(horzcat(targetListList{:}));
            
            function setUniqueTargetMaptoTrue(v)
                uniqueTargetMap(num2str(v)) = true;
            end
            
            arrayfun(@setUniqueTargetMaptoTrue, uniqueTargetList);
            
        end
        
        function initPathwayData(obj, rawPathwayKeggIds, targetIds)
            
            obj.targetCountPerPathway = containers.Map();
            obj.targetsPerPathway = containers.Map();

            pathwayKeggIdsPerTarget = cellfun(@(rawKeggIdList)obj.extractKeggIdArray(rawKeggIdList), rawPathwayKeggIds, 'UniformOutput', false);
            pathwayKeggIdsPerTargetAsCellArray = horzcat(pathwayKeggIdsPerTarget{:});
            pathwayKeggIdsPerTargetAsCellArray = pathwayKeggIdsPerTargetAsCellArray(~cellfun(@isempty, pathwayKeggIdsPerTargetAsCellArray));
            uniquePathwayKeggIds = unique(pathwayKeggIdsPerTargetAsCellArray);
            
            for i = 1:length(uniquePathwayKeggIds)
                nextPathway =uniquePathwayKeggIds{i};
                obj.targetCountPerPathway(nextPathway) = 0;
                obj.targetsPerPathway(nextPathway) = containers.Map();
            end
            
            for i = 1:length(pathwayKeggIdsPerTarget)
                targetIdsForPathway = targetIds{i};
                pathwayKeggIdsForCurrentTarget = pathwayKeggIdsPerTarget{i};
                for j = 1:length(pathwayKeggIdsForCurrentTarget)
                    pathwayKeggId = pathwayKeggIdsForCurrentTarget{j};
                    if isempty(pathwayKeggId)
                        continue;
                    end
                    obj.targetCountPerPathway(pathwayKeggId) = obj.targetCountPerPathway(pathwayKeggId) + 1;
                    targetsOfPathway = obj.targetsPerPathway(pathwayKeggId);
                    
                    for k = 1:length(targetIdsForPathway)
                        targetsOfPathway(num2str(targetIdsForPathway(k))) = true;
                    end
                end
            end 
            
            obj.accumulatedTargetTable = obj.accumulateTargetsForPathways();
        end
        
        function forEachPathwayKeggIdApplyFInTargetCountOrder(obj, f)
            pathwayKeys = obj.targetCountPerPathway.keys();
            targetCounts = cellfun(@(k) obj.targetCountPerPathway(k), pathwayKeys);
            [sortedTargetCounts, order] = sort(targetCounts, 'descend');
            sortedKeys = pathwayKeys(order);
            
            cellfun(f, sortedKeys);
        end
        
        function accumulatedTargetTable = accumulateTargetsForPathways(obj)
            
            addedPathwayKeggId           = cell(length(obj.targetsPerPathway.keys()), 1);
            accummulatedTargetCount = zeros(length(obj.targetsPerPathway.keys()), 1);
            accumulatedTargets      = cell(length(obj.targetsPerPathway.keys()), 1);
            
            accummulatedTargetMap = containers.Map();
            
            accumulatedTargetTable = table(addedPathwayKeggId, accummulatedTargetCount, accumulatedTargets);
            
            pathwayIndex = 1;
            
            function accummulateTargets(pathwayKeggId)
                targetIds = obj.targetsPerPathway(pathwayKeggId).keys();
                for i = 1:length(targetIds)
                    accummulatedTargetMap(targetIds{i}) = true;
                end
                
                accumulatedTargetTable.addedPathwayKeggId{pathwayIndex}           = pathwayKeggId;
                accumulatedTargetTable.accummulatedTargetCount(pathwayIndex) = length(accummulatedTargetMap.keys());
                accumulatedTargetTable.accumulatedTargets(pathwayIndex)      = {accummulatedTargetMap.keys()};
                pathwayIndex = pathwayIndex + 1;
            end
            
            obj.forEachPathwayKeggIdApplyFInTargetCountOrder(@accummulateTargets);
        end
        
        function forEachDrugIdTargetKeggEntityIdCombination(obj, f)
            for i = 1:height(obj.targetData)
                targetVector = obj.targetData.targetIds{i};
                drugId = obj.targetData.drug(i);
                for j = 1:length(targetVector)
                    targetId = targetVector(j);
                    f(drugId, targetId);
                end
            end
        end
        
        
        function standardizedKeggId = standardizeAsHumanKeggId(obj, keggId)
            
            if (strcmp(keggId, 'NA'))
                % standardizedKeggId = ['unknown_' num2str(rand(1))];
                standardizedKeggId = [];
                return;
            end
            
            numericPartIdAsString = regexp(keggId, '\d+', 'match');
            numericPartIdAsString = numericPartIdAsString{1};
            
            standardizedKeggId = ['hsa:' numericPartIdAsString];
        end
        
        function keggIdArray = extractKeggIdArray(obj, rawKeggIdList)
            keggIdArray = cellfun(...
                @(separatedUnstanderdizedKeggId) obj.standardizeAsHumanKeggId(separatedUnstanderdizedKeggId),...
                strsplit(rawKeggIdList, ';'),...
                'UniformOutput', false...
            );
        end
        
        function keggEntityIdArray = extractKeggEntityIdArray(obj, keggThesaurus, rawKeggIdList)
            splitKeggIdList = strsplit(rawKeggIdList, ';');
            
            specifiedKeggIdList = splitKeggIdList(~cellfun(@(v) strcmp(v, 'NA'), splitKeggIdList));
            
            keggEntityIdArray = cellfun(...
                @(separatedUnstanderdizedKeggId) keggThesaurus.getId(obj.standardizeAsHumanKeggId(separatedUnstanderdizedKeggId)),...
                specifiedKeggIdList...
            );
        end
        
        function uniqueTargetIds = getUniqueTargetIds(obj)
            uniqueTargetIds = unique(horzcat(obj.targetData.targetIds{:}));
        end
        
        function drugToTarget = drugToTargetAsMap(obj)
            drugToTarget = containers.Map();
            
            for i = 1:height(obj.targetData)
                drugToTarget(num2str(obj.targetData.drug(i))) = obj.targetData.targetIds{i};
            end
        end
    end
    
end

