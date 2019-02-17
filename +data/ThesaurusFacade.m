classdef ThesaurusFacade < handle
    %THESUARUSFACADE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        entityManager;
        type;
    end
    
    methods
        function obj = init(obj, entityManager, type)
            obj.type = type;
            obj.entityManager = entityManager;
        end
        
        function entityId = getId(obj, label)
            if strcmp(label, '')
                entityId = -1;
                return;
            end
            
            entityId = obj.entityManager.acquireEntityId(label, obj.type);
        end
        
        function entityIds = getIds(obj, labels)
            entityIds = cellfun(@(v) obj.getId(v), labels);
        end
        
        function entityId = getIdForSynonymRow(obj, synonymRow)
            
        end
        
        function label = getCanonicalLabel(obj, entityId)
            
            if entityId == -1
                label = '';
                return;
            end
            
            label = obj.entityManager.getLabel(entityId);
        end
        
        function labelRow = getLabelRow(obj, entityId)
            labelRow = obj.entityManager.getLabelRow(obj.type, entityId);
        end
    end
    
end

