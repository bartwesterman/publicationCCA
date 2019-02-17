classdef EntityIndexer < handle
    %DRUGINDEXER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesaurus;
        indexToEntityId;
        indexCount;
    end
    
    methods
        
        function obj = init(obj, thesaurus)
            obj.thesaurus = thesaurus;
            obj.indexToEntityId = zeros(100, 1);
            obj.indexCount = 0;
        end
        
        function index = acquireIndexByEntityId(obj, entityId)
            index = find(obj.indexToEntityId == entityId, 1);
            
            if ~isempty(index)
                return;
            end
            
            obj.indexCount = obj.indexCount + 1;
            if obj.indexCount > length(obj.indexToEntityId)
                obj.indexToEntityId = [obj.indexToEntityId ; zeros(length(obj.indexToEntityId))];
            end
            obj.indexToEntityId(obj.indexCount) = entityId;
            index = obj.indexCount;
        end
        
        function index = acquireIndexByLabel(obj, label)
            index = obj.acquireIndexByEntityId(obj.thesaurus.getId(label));
        end
    end
    
end

