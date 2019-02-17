classdef TrainingSetBuilder < handle
    %TRAININGSETBUILDER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        entityIdOrder;
        entityIdToIndexMap;
        labelArray;
        isInput;
    end
    
    methods
        function obj = init(obj)
            obj.entityIdOrder = [];
            obj.entityIdToIndexMap = containers.Map();
            obj.labelArray = cell(0);
            obj.isInput = zeros(0, 1);
        end
        
        function assureAttribute(obj, entityId, label, isInput)
            if nargin < 4
                isInput = false;
            end
            
            entityIndexes = obj.entityIdOrder == entityId;
            
            if sum(entityIndexes) > 0
                obj.isInput(entityIndexes) = obj.isInput(entityIndexes) | repmat(isInput, size(obj.isInput(entityIndexes)));
                return;
            end
            
            obj.entityIdOrder(end + 1) = entityId;
            obj.entityIdToIndexMap(num2str(entityId)) = length(obj.entityIdOrder);
            obj.labelArray(end + 1) = {label};
            obj.isInput(end + 1) = isInput;            
        end
        
        function inputIndices = getInputIndices(obj)
            inputIndices = find(obj.isInput);
        end
        
        function index = entityIdToIndex(obj, entityId)
            key = num2str(entityId);
            if ~obj.entityIdToIndexMap.isKey(key)
                index = [];
                return;
            end
            
            index = obj.entityIdToIndexMap(key);
            % index = find(obj.entityIdOrder == entityId, 1);
        end
        
        function c = getAttributeCount(obj)
            c = length(obj.entityIdOrder);
        end
        
        function example = createExample(obj, entityIdValuePair)
            example = sparse(size(obj.entityIdOrder, 1), size(obj.entityIdOrder, 2));
            
            for i = 1:size(entityIdValuePair, 1)
                index = obj.entityIdToIndex(entityIdValuePair(i, 1));
                if (isempty(index))
                    continue;
                end
                example(index) = example(index) + entityIdValuePair(i, 2);
            end
        end
        
        function mapMultipleEntityIdsToSingleEntityId(obj, singleEntityId, multipleEntityIds)
            index = obj.entityIdToIndex(singleEntityId);
            
            for i = 1:length(multipleEntityIds)
                entityId = multipleEntityIds(i);
                obj.entityIdToIndexMap(num2str(entityId)) = index;
            end
        end
        
        function labelArray = getLabelArray(obj)
            labelArray = obj.labelArray;
        end
        
        function entityIds = indexesToEntityIds(obj, indexes)
            entityIds = obj.entityIdOrder(indexes);
        end
    end
    
end

