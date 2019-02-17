classdef EntityManager < handle
    %ENTITYMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        labelTable;
        labelCount;
        
        entityCount;
        
        unknownLabel;
        
        typeToLabelToEntityId;
        entityIdToLabel;
        entityIdHasCanonicLabel;
        entityIdType;
    end
    
    methods
        
        function obj = init(obj)
            obj.entityCount = 0; 
            obj.labelCount  = 0;
            obj.unknownLabel = containers.Map();

            obj.labelTable = obj.createEmptyLabelTableSized(0);
            
            obj.typeToLabelToEntityId   = containers.Map();
            obj.entityIdToLabel         = containers.Map('KeyType', 'int64', 'ValueType', 'char');
            obj.entityIdHasCanonicLabel = containers.Map('KeyType', 'int64', 'ValueType', 'logical');
            obj.entityIdType            = containers.Map('KeyType', 'int64', 'ValueType', 'char');
            
        end
                
        function entityId = acquireEntityId(obj,label, type)
            
            entityId = obj.getHashCacheLabel(label, type);
            if ~isempty(entityId)
                return;
            end
            

            % entityIndex = obj.findEntityIndex(label, type);
            
            % if (sum(entityIndex) == 0)
                entityId = obj.insertUnknownLabel(label, type);
            %    return
            %end
            
            %entityId = obj.labelTable.entityId(entityIndex);
            % return;
        end
        
        function [label, type] = getLabel(obj, entityId)
            label = obj.entityIdToLabel(entityId);
            type  = obj.entityIdType(entityId);
            return;
            
            canonicalLabelIndex = find(obj.labelTable.entityId == entityId & obj.labelTable.isCanonical);
            if isempty(canonicalLabelIndex)
                canonicalLabelIndex = find(obj.labelTable.entityId == entityId, 1);
            end
            
            label = obj.labelTable.label{canonicalLabelIndex(1)};
            type  = obj.labelTable.type{canonicalLabelIndex(1)};
        end
        
        function [labels, types] = getLabels(obj, entityIds)
            [labels, types] = arrayfun(@(entityId) obj.getLabel(entityId), abs(entityIds), 'UniformOutput', false);
            
            for i = 1:length(entityIds)
                if entityIds(i) < 0
                    labels{i} = [labels{i} ' mutation'];
                end
            end
        end
        
        function result = isType(obj, entityId, type)
            cellLineIndices = cellfun(@(v) strcmp(v, type), obj.labelTable.type);
            cellLineEntityIds = obj.labelTable.entityId(cellLineIndices);
            
            result = ismember(entityId, cellLineEntityIds);
        end
        
        function isPresent = contains(obj, label, type)
            isPresent = sum(obj.findEntityIndex(label, type)) ~= 0;
        end
        
        function entityIndex = findEntityIndex(obj, label, type)
            correctLabelIndexes = strcmp(label, obj.labelTable.label); % cellfun(@(v) strcmp(v, label), obj.labelTable.label);
            if isempty(correctLabelIndexes)
                entityIndex = zeros(size(obj.labelTable.label));
                return;
            end
            entityIndex = correctLabelIndexes & strcmp(type, obj.labelTable.type); % cellfun(@(v) strcmp(v, type), obj.labelTable.type);            
        end
        
        function entityId = insertUnknownLabel(obj, label, type)
            obj.unknownLabel(label) = true;
            
            obj.labelCount  = obj.labelCount + 1;
            obj.entityCount = obj.entityCount + 1;
            
            if (obj.labelCount > height(obj.labelTable))
                obj.assureLabelTableSpace(height(obj.labelTable) * 2);
            end
            
            obj.labelTable.entityId(obj.labelCount) = obj.entityCount;
            obj.labelTable.label(obj.labelCount)    = {label};
            obj.labelTable.type(obj.labelCount)     = {type};
            
            entityId = obj.entityCount;
            obj.setHashCacheLabel(label, type, entityId);
            
            if obj.entityIdToLabel.isKey(entityId)
                return;
            end
            obj.entityIdToLabel(entityId) = label;
            obj.entityIdHasCanonicLabel(entityId) = false;
            obj.entityIdType(entityId) = type;
        end
        
        function unsafeThesaurusInsert(obj, type, synonymArrayArray)
            addedLabelCount = sum(cellfun(@(x) length(x), synonymArrayArray));
            obj.assureLabelTableSpace(obj.labelCount + addedLabelCount);
            
            for i = 1:length(synonymArrayArray)
                obj.unsafeSynonymArrayInsert(type, synonymArrayArray{i});
            end
        end
        
        function entityId = unsafeInsertFirstCanonical(obj, type, label)
            obj.labelCount = obj.labelCount + 1;
            obj.assureLabelTableSpace(obj.labelCount);
            obj.entityCount = obj.entityCount + 1;
            
            obj.labelTable.entityId(obj.labelCount)    = obj.entityCount;
            obj.labelTable.type(obj.labelCount)        = {type};                
            obj.labelTable.label(obj.labelCount)       = {label};
            obj.labelTable.isCanonical(obj.labelCount) = true;
            
            entityId = obj.entityCount;
            obj.setHashCacheLabel(label, type, entityId);
            if obj.entityIdHasCanonicLabel.isKey(entityId)
                disp(['WARNING: EntityManager attempting to create canonical label unsafely, but it already exists: ' label]);
            end
            obj.entityIdToLabel(entityId) = label;
            obj.entityIdHasCanonicLabel(entityId) = true;
            obj.entityIdType(entityId) = type;
            return;
        end
        
        function entityId = mergeEntities(obj, entityIds)
            entityId = entityIds(1);
            if length(entityIds) < 2
                return;
            end
            
            for i = 2:length(entityIds)
                obj.mergeAIntoB(entityIds(i), entityId);
            end
        end
        
        function mergeAIntoB(obj, a, b)
            % mergeLabelTable
            
            aIndexes = obj.labelTable.entityId == a;
            obj.labelTable.entityId(aIndexes) = b;
            
            % mergeTypeToLabelToEntityId
            
            types = obj.typeToLabelToEntityId.keys;
            
            for i = 1:length(types)
                type = types{i};
                
                toLabelToEntityId = obj.typeToLabelToEntityId(type);
                
                labels  = toLabelToEntityId.keys();
                values  = toLabelToEntityId.values(labels);
                indices = cell2mat(values) == a;
                labels  = labels(indices);
                for j = 1:length(labels)
                    label = labels{j};
                    toLabelToEntityId(label) = b;
                    % @TODO double check if this change is correct
                    %if toLabelToEntityId(label) == a
                    %    toLabelToEntityId(label) = b;
                    %end
                end
                
            end
            
            if ~obj.entityIdHasCanonicLabel(b) && obj.entityIdHasCanonicLabel(a)
                obj.entityIdToLabel(b) = obj.entityIdToLabel(a);
                obj.entityIdHasCanonicLabel(b) = true;
            end
            
            if obj.entityIdHasCanonicLabel(b) && obj.entityIdHasCanonicLabel(a) && strcmp(obj.entityIdToLabel(b), obj.entityIdToLabel(a))
                disp(['WARNING: EntityManager.mergeAIntoB(a,b) is trying to merge two entities, both with canonic labels, that are conflicting: label of A is: ' obj.entityIdToLabel(a) ' label of B is: ' obj.entityIdToLabel(b)]);
            end
            obj.entityIdToLabel.remove(a);
            obj.entityIdHasCanonicLabel.remove(a);
            obj.entityIdType.remove(a);
        end
        
        function entityId = mergeSynonymArrayInsert(obj, type, synonymArray)
            entityIndexes = cellfun(@(label) find(obj.findEntityIndex(label, type), 1), synonymArray, 'UniformOutput', false);
            entityIndexes = entityIndexes(~cellfun(@isempty, entityIndexes));
            
            entityIds = unique(obj.labelTable.entityId(cell2mat(entityIndexes)));
            
            if (~isempty(entityIds))
                entityId = obj.mergeEntities(entityIds);
                
                obj.unsafeSynonymArrayInsertWithEntityId(type, synonymArray, entityId);
                return;
            end
            
            entityId = unsafeSynonymArrayInsert(obj, type, synonymArray);
        end
        
        function entityId = unsafeSynonymArrayInsert(obj, type, synonymArray)
            obj.entityCount = obj.entityCount + 1;
            entityId = obj.entityCount;
            obj.unsafeSynonymArrayInsertWithEntityId(type, synonymArray, entityId);
        end
        
        function entityId = unsafeSynonymArrayInsertWithEntityId(obj, type, synonymArray, entityId)
                
            obj.assureLabelTableSpace(obj.labelCount + length(synonymArray));
                   
            for i = 1:length(synonymArray)
                obj.labelCount = obj.labelCount + 1;
                nextLabelId = obj.labelCount;
                label = synonymArray{i};
                obj.labelTable.isCanonical(nextLabelId) = (i == 1);            
                obj.labelTable.entityId(nextLabelId) = entityId;
                obj.labelTable.type(nextLabelId)     = {type};                
                obj.labelTable.label(nextLabelId)    = {label};
                
                obj.setHashCacheLabel(label, type, entityId);
                
                if (i == 1)
%                     if obj.entityIdHasCanonicLabel.isKey(entityId) && obj.entityIdHasCanonicLabel(entityId)
%                         disp(['WARNING: overwriting canonic label for ' obj.entityIdToLabel(entityId) ' with ' label]);
%                     end
                    obj.entityIdToLabel(entityId) = label;
                    obj.entityIdHasCanonicLabel(entityId) = true;
                    obj.entityIdType(entityId) = type;
                end
            end            
        end
        
        function assureLabelTableSpace(obj, requiredSize)
            currentSize = height(obj.labelTable);
            
            if (currentSize >= requiredSize)
                return;
            end
            
            sizeIncrease = requiredSize - currentSize;
            
            obj.labelTable = vertcat(obj.labelTable, obj.createEmptyLabelTableSized(sizeIncrease));
        end
        
        function emptyLabelTable = createEmptyLabelTableSized(obj, labelTableSize)
            label           = cell(labelTableSize,1);
            type            = cell(labelTableSize,1);
            entityId        = zeros(labelTableSize,1);
            isCanonical     = zeros(labelTableSize,1);
            
            emptyLabelTable = table(label, entityId, isCanonical, type);
        end
        
        function setHashCacheLabel(obj, label, type, entityId)
            
            if (~obj.typeToLabelToEntityId.isKey(type))
                obj.typeToLabelToEntityId(type) = containers.Map();
            end
            
            labelToEntityId = obj.typeToLabelToEntityId(type);
  
            labelToEntityId(label) = entityId;
        end
        
        function entityId = getHashCacheLabel(obj, label, type)
            if (~obj.typeToLabelToEntityId.isKey(type))
                obj.typeToLabelToEntityId(type) = containers.Map();
            end
            
            labelToEntityId = obj.typeToLabelToEntityId(type);
            
            if ~labelToEntityId.isKey(label)
                entityId = [];
                return;
            end
            
            entityId = labelToEntityId(label);
        end
        
        function labelRow = getLabelRow(obj, type, entityId)
            correctTypeRowIds     = cellfun(@(v) strcmp(type, v), obj.labelTable.type);
            correctEntityIdRowIds = obj.labelTable.entityId == entityId;
            
            labelRow = obj.labelTable.label(correctTypeRowIds & correctEntityIdRowIds);
            
        end
        
        function thesaurus = get(obj, type)
            thesaurus = data.ThesaurusFacade().init(obj, type);
        end
    end
    
end


