classdef KeggApi < handle
    %API Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        base;
        keggIdToNameSetCache;
        
        delayedCacheSaveCall;
    end
    
    methods
        
        function obj = init(obj)
            obj.base = Config.KEGG_API_BASE;
            
            obj.initCache();
            obj.delayedCacheSaveCall = timer('TimerFcn',@(x,y)obj.saveCache(),'StartDelay',10);
        end
        
        function initCache(obj)
            if ~exist(Config.KEGG_ID_NAME_SET_FILE_PATH, 'file')
                obj.keggIdToNameSetCache = containers.Map();
                return;
            end
            
            cacheFileData = load(Config.KEGG_ID_NAME_SET_FILE_PATH);
            obj.keggIdToNameSetCache = cacheFileData.cache;
            
        end
        
        function saveCache(obj)
            cache = obj.keggIdToNameSetCache;
            save(Config.KEGG_ID_NAME_SET_FILE_PATH, 'cache');
        end
        
        function debounceCacheSave(obj)
            stop(obj.delayedCacheSaveCall);
            start(obj.delayedCacheSaveCall);
        end
        
        function clearCache(obj)
                obj.keggIdToNameSetCache = containers.Map();            
        end
        
        function [nameSet type] = keggIdToNameSetTypePair(obj, keggId)

            response = urlread(strcat(obj.base,'get/', keggId));
           
            nameSetString = regexpi(response, '\nNAME(.*)\n\S', 'tokens');
            nameSetString = nameSetString{1};
            nameSetString = nameSetString{1};
            nameSet = strsplit(nameSetString, '\n');
            nameSet = cellfun(@strtrim, nameSet, 'UniformOutput', false);
            
            type = regexpi(response, '^ENTRY\s+\S+\s+(\S*)\s*\n', 'tokens');
            type = type{1};
        end
        
        function nameSet = keggIdToNameSet(obj, keggId)
            if (obj.keggIdToNameSetCache.isKey(keggId))
                nameSet = obj.keggIdToNameSetCache(keggId);
                return;
            end
            
            try
                response = urlread(strcat(obj.base,'get/', keggId));
            catch ME
                nameSet = {['nameRequestFailedFor_' keggId]};
                return
            end 
           
            nameSetString = regexp(response, '\nNAME(.*?)\n(?=\S)', 'tokens');
            nameSetString = nameSetString{1}{1};
            if (~isempty(regexp(response, '^?\n?ENTRY.*?Compound\n?$?', 'match')))
                nameSet = strsplit(nameSetString, ';\n');
            else
                nameSet = strsplit(nameSetString, ',');
            end
            nameSet = cellfun(@strtrim, nameSet, 'UniformOutput', false);
            
            obj.keggIdToNameSetCache(keggId) = nameSet;
            obj.debounceCacheSave();
        end
        
        %{
        function pathwayDbInfo = getPathwayDbInfo(obj)
            pathwayDbInfo = urlread(strcat(obj.base,'info/pathway'));
        end
    
        function keggId = ncbiGiToKegg(obj, ncbiGi)

            % ncbiGi = 'ncbi-geneid:3113320';
            keggId = regexpi(urlread(strcat(obj.base,'conv/genes/',ncbiGi)),'(?<=(??@ncbiGi)\s+)\w+\W+\w*','match');
        end
        
        function organismList = listOrganisms(obj)
            response = urlread(strcat(obj.base,'list/organism'));
            organismList = regexpi(response,'[^\n]+','match')';
        end
        
        function organism = getOrganismByName(obj, name)
            organisms = obj.listOrganisms();
            hsa_idx = find(~cellfun(@isempty,regexpi(organisms,name)));
            organism = organisms(hsa_idx);
        end
        
        function pathways = getPathwaysByOrganismCode(obj, organismCode)
            
            response = urlread(strcat(obj.base,'list/','pathway/',organismCode));
            pathways = regexpi(response,'[^\n]+','match')'; % convert to cellstr
        end
        
        function pathwayId = getHumanPathwayIdByName(obj, name)
            pathwayList = obj.getPathwaysByOrganismCode('hsa');
            
            pathwayIndexes = find(~cellfun(@isempty,regexpi(pathwayList, name)));
            pathwayList(pathwayIndexes);
            pathwayId = regexpi(pathwayList(pathwayIndexes),'(?<=path:)\w+','match');
            pathwayId = pathwayId{1};
        end
        
        function pathwayRecord = getPathwayRecordById(obj, pathwayId)
            pathwayRecord = urlread(char(strcat(obj.base,'get/',pathwayId)));
        end
       %} 
    end
    
end

