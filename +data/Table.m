classdef Table < handle
    %TABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        schema;
        
    end
    
    methods
        function obj = init(obj, name, schema)
            obj.name   = name;
            obj.schema = schema;
            
            obj.createTable();
        end
        
        function obj = initLink(obj, name, schema)
            obj.name   = name;
            obj.schema = schema;            
        end
        
        function createTable(obj)
            query = sprintf('DROP TABLE IF EXISTS %s', obj.name);
            
            sqlite3.execute(query);
            
            query = sprintf('CREATE TABLE %s (%s)', obj.name, obj.schemaToColumnString());
            
            sqlite3.execute(query);
        end
        
        function schemaString = schemaToColumnString(obj)
            idColumnString = 'id INTEGER PRIMARY KEY AUTOINCREMENT';
            otherColumnStrings = cellfun(@(schemaColumn) obj.createColumnString(schemaColumn), obj.schema, 'UniformOutput', false);
            columnStringArray = vertcat(idColumnString, otherColumnStrings);

            schemaString = strjoin(columnStringArray, ', ');      
        end
        
        function insertSchemaString = schemaToInsertColumnString(obj)
            % columnStringArray = cellfun(@(schemaColumn) obj.createColumnString(schemaColumn), obj.schema, 'UniformOutput', 0);
            insertColumnStringArray = cellfun(@(schemaColumn) obj.createColumnString(schemaColumn), obj.schema, 'UniformOutput', 0);
            insertSchemaString = strjoin(insertColumnStringArray, ', ');
        end
        
        function columnString = createColumnString(obj, schemaColumn)
            columnString = schemaColumn.name;
        end
        
        function valueArrayString = createValueArrayString(obj, valueArray)
            valueStringArray = cellfun(@(v) obj.createValueString(v), valueArray,'UniformOutput', false);
            valueArrayString = strjoin(valueStringArray, ', ');
        end
        
        function valueString = createValueString(obj, value)
            if (isempty(value))
                valueString = 'NULL';
                return;
            end
            
            if (isnumeric(value) || islogical(value))
                valueString = num2str(value);
                return;
            end
            
            if (ischar(value))
                valueString = ['''' value ''''];
                return;
            end
            
            throw (MException('data:Table:createValueString', strcat('Can not convert value to string. Value of class: ', class(value))));
        end
        
        function addCompleteRow(obj, values)
            valueCount = size(values, 2);
            % valueString = obj.createValueArrayString(values);
            valueString = repmat('?,', 1, valueCount);
            valueString = valueString(1:(end-1));
            insertColumnString = obj.schemaToInsertColumnString();
            
            for i = 1:valueCount
                if islogical(values{i})
                    values{i} = 0 + values{i}; % cast logical to double
                end
            end
            
            query = sprintf('INSERT INTO %s (%s) VALUES (%s)', obj.name, insertColumnString, valueString);
            argumentArray = [query values];
            sqlite3.execute(argumentArray{:});
        end
    end
    
end

