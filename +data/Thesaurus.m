classdef Thesaurus < handle
    %THESAURUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        filePath;
        labelTable;
        
        unknownSynonymMap;
        
        constructionIsCompleted;
        reNamePairsHaveLoaded;
        synonymArrayArrayHasLoaded;
    end
    
    methods
        
        function obj = initLoad(obj, name, filePath)
            import data.*
            obj.name = name;
            obj.filePath = filePath;
            obj.unknownSynonymMap = containers.Map;
            
            obj.labelTable = data.LabelTable;
            obj.labelTable.init(name);

            obj.constructionIsCompleted = false;
            
            obj.reNamePairsHaveLoaded = false;
            obj.synonymArrayArrayHasLoaded = false;
            
            if (strcmp(filePath, '') || nargin < 3)
                return;
            end
            
            synonymArrayArray = data.thsread(obj.filePath);
            
            obj.storeSynonymArrayArray(synonymArrayArray);

        end
        
        function obj = initLink(obj, name)
            obj.name = name;
            
            obj.labelTable = data.LabelTable;
            obj.labelTable.initLink(name);

            obj.constructionIsCompleted = true;
            
            obj.reNamePairsHaveLoaded = true;
            obj.synonymArrayArrayHasLoaded = true;

        end
        
        function completeConstruction(obj)
            obj.constructionIsCompleted = true;
        end
        
        function id = getId(obj, label)

            id = obj.labelTable.getIdByLabel(label);
            if (isnan(id))
                obj.unknownSynonymMap(label) = true;
                
                obj.storeUnknownSynonym(label);
                
                id = obj.labelTable.getIdByLabel(label);
            end
        end
        
        function storeUnknownSynonym(obj, label)
            if ~obj.constructionIsCompleted
                throw(MException('Thesaurus:storeUnknownSynonym', 'attempting to use before construction completed'));
            end
            
            entityId = obj.labelTable.getNextEntityId();
            
            isCanonical = true;
            isKnownSynonym = false;

            obj.labelTable.insertLabel(label, entityId, isCanonical, isKnownSynonym);
        end
        
        function storeSynonymArrayArray(obj, synonymArrayArray)
            if (obj.reNamePairsHaveLoaded)
                throw(MException('Thesaurus:storeSynonymArrayArray', 'can not storeSynonymArray after reName pairs have loaded'));
            end
            
            conceptCount = size(synonymArrayArray, 1);
            for i = 1:conceptCount
                synonymArray = synonymArrayArray{i}';
                synonymArray = synonymArray(~cellfun(@isempty, synonymArray)); % remove empty cells
                obj.storeSynonymArray(synonymArray)
            end
            
            obj.synonymArrayArrayHasLoaded = true;
        end
        
        function entityId = storeSynonymArray(obj, synonymArray)
            if obj.constructionIsCompleted
                throw(MException('Thesaurus:storeSynonymArray', 'attempting to construct after construction completed'));
            end
            
            entityId = obj.labelTable.getNextEntityId();
            isKnownSynonym = true;
            
            synonymCount = size(synonymArray, 1);
            for i = 1:synonymCount
                label = synonymArray{i}';
                
                currentLabel = obj.labelTable.getIdByLabel(label);
                if ~isnan(currentLabel)
                    throw(MException('Thesaurus:storeSynonymArray', ['Trying to add a synonym that has already been added. This implies a violation of Thesaurus integrity. Label: ' label']));
                end
                
                if(i == 1)
                    obj.addCanonical(label, entityId, isKnownSynonym);
                    continue;
                end
                
                obj.addSynonym(label, entityId, isKnownSynonym);
            end
        end
        
        function addCanonical(obj, label, entityId, isKnownSynonym)
            isCanonical = true;
            obj.labelTable.insertLabel(label, entityId, isCanonical, isKnownSynonym);
        end
        
        function addSynonym(obj, label, entityId, isKnownSynonym)
        	isCanonical = false;
            obj.labelTable.insertLabel(label, entityId, isCanonical, isKnownSynonym);
        end
        
        function storeReNamePairArray(obj, reNamePairArray)
            if obj.constructionIsCompleted
                throw(MException('Thesaurus:addReNamePairArray', 'attempting to construct after construction completed'));
            end
            
            reNamePairCount = size(reNamePairArray, 1);
            
            for i = 1:reNamePairCount
                obj.storeReNamePair(reNamePairArray{i, :});
            end
            
            obj.reNamePairsHaveLoaded = true;
        end
        
        function storeReNamePair(obj, canonicalLabel, synonymLabel)
            
            canonicalSynonym = obj.labelTable.getSynonymByLabel(canonicalLabel);
            normalSynonym   = obj.labelTable.getSynonymByLabel(synonymLabel);
            
            % the added data must be consistent
            if (~obj.reNamePairIsConsistent(canonicalSynonym, normalSynonym))
                throw(MException('Thesaurus:storeReNamePair', 'ReName pair is inconsisten with current Thesaurus'));
            end
            
            if ~isstruct(canonicalSynonym)
                entityId = obj.labelTable.getNextEntityId();
                obj.addCanonical(canonicalLabel, entityId, true);
            else
                entityId = canonicalSynonym.entityid;
            end
            
            if ~isstruct(normalSynonym)
                obj.addSynonym(synonymLabel, entityId, true);
            end
        end
        
        function isConsistent = reNamePairIsConsistent(obj, currentCanonical, currentSynonym)
            if isstruct(currentCanonical) && ~currentCanonical.iscanonical
                
                isConsistent = false;
                return
            end
            
            if isstruct(currentCanonical) && isstruct(currentSynonym)
                if currentCanonical.entityid ~= currentSynonym.entityid
                    isConsistent = false;
                    return
                end
            end
            
            if ~isstruct(currentCanonical) && isstruct(currentSynonym)
                % if synonym exists, and canonical does not, then synonym
                % has a different canonical, and thus the current canonical
                % is inconsistent with the new one
                isConsistent = false;
                return
            end
            
            isConsistent = true;
            
            return;
        end
        
        function mergeSynonymRowArray(obj, synonymRowArray)
            rowCount = size(synonymRowArray, 1);
            for i = 1:rowCount
                obj.mergeSynonymRow(synonymRowArray{i});
            end
        end
        
        function mergeSynonymRow(obj, synonymRow)
            obj.storeSynonymRow(synonymRow);
            
            entityIds = obj.labelTable.getDistinctEntityIdsForLabelRow(synonymRow);
            
            obj.labelTable.mergeEntityIdRowIntoFirstEntity(entityIds);
        end
        
        function label = getCanonicalLabel(obj, entityId)
            labelRow = obj.labelTable.getLabelRowForEntityId(entityId);
            label = labelRow{1};
        end
     
        function entityId = storeSynonymRow(obj, synonymRow)
            if obj.constructionIsCompleted
                throw(MException('Thesaurus:storeSynonymArray', 'attempting to construct after construction completed'));
            end
            
            entityId = obj.labelTable.getNextEntityId();
            isKnownSynonym = true;
            
            synonymCount = size(synonymRow, 2);
            for i = 1:synonymCount
                label = synonymRow{i};
                
                currentLabel = obj.labelTable.getIdByLabel(label);
                if ~isnan(currentLabel) % skip labels that are already present
                    continue;
                end
                obj.addSynonym(label, entityId, isKnownSynonym);
            end
        end
        
        function synonymRowArray = toSynonymRowArray(obj)
            distinctEntityIds = obj.labelTable.getDistinctEntityIdRow();
            distinctEntityIdCount = size(distinctEntityIds, 2);
            
            maxSizeSynonymRow = obj.labelTable.getSizeLargestSynonymGroup();
            
            synonymRowArray = cell(distinctEntityIdCount, 1);
            
            for i = 1:distinctEntityIdCount
                synonymRowArray{i} = obj.labelTable.getLabelRowForEntityId(distinctEntityIds(i));
            end
        end
         
        function saveUnknownSynonyms(obj)
            uknownSynonymString = sprintf(strjoin(obj.unknownSynonymMap.keys(), '\n'));
            unknownSynonymFile = strcat(obj.filePath, '.unknown');
            
            fileID = fopen(unknownSynonymFile,'w');
            fwrite(fileID, uknownSynonymString);
            fclose(fileID);
        end
    end 
    
    methods (Static)
        function mergedSynonymRowArray = convertRedundantSynonymRelationshiptToThsFile(redunandantSynonymFilePath, thsFilePath)
            mkdir([pwd '/tmp']);
            sqlite3.open([pwd '/tmp/conversion.db']);

            converter = data.Thesaurus;
            converter.init('conversion', '');
            
            synonymMatrix = data.csvread(redunandantSynonymFilePath); %[pwd '/resources/thesauri/drug.synonymRelationship.csv']);
            
            synonymRowArray = utils.removeEmpty(utils.rowfun(@utils.removeEmpty, synonymMatrix));
            
            converter.mergeSynonymRowArray(synonymRowArray);
            mergedSynonymRowArray = converter.toSynonymRowArray();
   
            if (nargin > 1)
                data.thswrite(mergedSynonymRowArray, thsFilePath);
            end
            
            sqlite3.close();
            rmdir([pwd '/tmp'], 's');
        end
    end
end

