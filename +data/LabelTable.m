classdef LabelTable < data.Table
    %LABELTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        
        SCHEMA = {
            struct('name', 'label', 'type', 'TEXT(100)'); 
            struct('name', 'entityId', 'type', 'INTEGER'); 
            struct('name', 'isCanonical', 'type', 'INTEGER');
            struct('name', 'isKnownSynonym', 'type', 'INTEGER')
        };
    end
    
    methods
        function obj = init(obj, name)

            init@data.Table(obj, name, data.LabelTable.SCHEMA);
        end
        
        function obj = initLink(obj, name)

            initLink@data.Table(obj, name, data.LabelTable.SCHEMA);
        end
        
        
        function id = getIdByLabel(obj, label)
            % query = sprintf( 'SELECT entityId FROM %s WHERE label = ''%s''', obj.name, label);
            results = sqlite3.execute(['SELECT entityId FROM ' obj.name ' WHERE label = ?'], label);
            
            if (isempty(results))
                id = NaN;
                return;
            end
            
            id = results(1).entityid;
            return;
        end
        
        function synonymResult = getSynonymByLabel(obj, label)
            results = sqlite3.execute(['SELECT id, label, entityId, isCanonical, isKnownSynonym FROM ' obj.name ' WHERE label = ?'], label);
            if (isempty(results))
                synonymResult = NaN;
                return;
            end
            
            synonymResult = results(1);
            return;
        end
        
        function labelRow = getLabelRowForEntityId(obj, entityId)
            results = sqlite3.execute(['SELECT label FROM ' obj.name ' WHERE entityId = ? ORDER BY isCanonical DESC'], entityId);
            
            labelRow = utils.multiAnsToArray(results.label);
        end

        function insertLabel(obj, label, entityId, isCanonical, isKnownSynonym)
            if (nargin < 5)
                isKnownSynonym = true;
            end
            
            if (nargin < 4)
                isCanonical = false;
            end
            
            if (nargin < 3)
                entityId = obj.getNextEntityId();
            end
            
            obj.addCompleteRow({label, entityId, isCanonical, isKnownSynonym})
        end
        
        function distinctEntityIdRow = getDistinctEntityIdRow(obj)
            results = sqlite3.execute(['SELECT DISTINCT entityId FROM ' obj.name ' ORDER BY entityId ASC']);
            
            distinctEntityIdRow = cell2mat(utils.multiAnsToArray(results.entityid));
        end
        
        function maxSizeSynonymRow = getSizeLargestSynonymGroup(obj)
            results = sqlite3.execute(['SELECT MAX(c) FROM (SELECT count(label) as c FROM ' obj.name ' GROUP BY entityId)']);
            maxSizeSynonymRow = results.max_c(1);
        end
        
        function sortedIdVector = getDistinctEntityIdsForLabelRow(obj, labelRow)
            
            labelCount = size(labelRow, 2);
            
            if labelCount == 0
                return
            end
            
            paramString = repmat('?,', 1, labelCount);
            paramString = paramString(1:end-1);
            
            query = ['SELECT DISTINCT entityid FROM ' obj.name ' WHERE label in ( ' paramString ' ) ORDER BY entityId ASC'];
            
            args = [query labelRow];
            
            results = sqlite3.execute(args{:});

            if isempty(results)
                sortedIdVector = [];
                return;
            end
            
            sortedIdVector = cell2mat(utils.multiAnsToArray(results.entityid));
        end
        
        function mergeEntityIdRowIntoFirstEntity(obj, entityIdRow)
            
            entityCount = size(entityIdRow, 2);
            
            paramString = repmat('?,', 1, entityCount - 1);
            paramString = paramString(1:end-1);
            
            query = ['UPDATE ' obj.name ' SET entityid = ? WHERE entityid IN (' paramString ')'];
            
            args = [query num2cell(entityIdRow)];

            sqlite3.execute(args{:});
        end
        
        function nextId = getNextEntityId(obj)
            query = sprintf( 'SELECT MAX(entityId) AS max FROM %s', obj.name);
            results = sqlite3.execute(query);
            
            if (isempty(results.max))
                nextId = 1;
                return;
            end
            
            nextId = results(1).max + 1;
        end
    end
    
end

