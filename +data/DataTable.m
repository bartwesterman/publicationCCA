classdef DataTable < data.Table
    %DATATABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        semanticSchema;
    end
    
    methods
        function obj = init(obj, name, semanticSchema)
            obj.semanticSchema = semanticSchema;
            
            schema = obj.semanticSchemaToSchema(semanticSchema);
            init@data.Table(obj, name, schema);
        end
        
        function save(obj, data)
            for i = 1:size(data,1)
                obj.insertSemanticRow(data(i, :));
                if (mod(i, 10000) == 0)
                    disp(['processed ' num2str(i) ' of ' num2str(size(data,1)) ' for database ' obj.name])
                end
            end
        end
        
        function insertSemanticRow(obj, semanticRow)
            normalRow = obj.semanticToNormalRow(semanticRow);
            if (iscell(normalRow))
                obj.addCompleteRow(normalRow);
            end
        end
        
        function schema = semanticSchemaToSchema(obj, semanticSchema)            
            columnCount = size(semanticSchema, 1);
            schema = cell(columnCount, 1);

            for i = 1:columnCount
                schema{i} = obj.semanticToNormalColumn(semanticSchema{i});
            end
        end
        
        function normalColumn = semanticToNormalColumn(obj, semanticColumn)
            normalColumn = struct;
            normalColumn.name = semanticColumn.name;
            normalColumn.type = obj.semanticToNormalType(semanticColumn.type);
        end
        
        function normalType = semanticToNormalType(obj, semanticType)
            if (isa(semanticType, 'data.Thesaurus'))
                normalType = 'INTEGER';
                return;
            end
            
            normalType = semanticType;
        end
        
        function normalRow = semanticToNormalRow(obj, semanticRow)
            rowCouldBeConverted = true;
            
            columnCount = size(obj.semanticSchema,1);
            normalRow = cell(1, columnCount);
            for i = 1:columnCount
                normalCell = obj.semanticToNormalCell(obj.semanticSchema{i}, semanticRow{1, i});
                if (isnan(normalCell))
                    rowCouldBeConverted = false;
                end
                normalRow{1, i} = normalCell;
            end
            
            if (~rowCouldBeConverted)
                normalRow = NaN;
                return;
            end
            
        end
        
        function normalCell = semanticToNormalCell(obj, semanticSchemaColumn, semanticCell)

            if (isempty(semanticCell))
                normalCell = [];
                return;
            end
            if (isa(semanticSchemaColumn.type, 'data.Thesaurus'))
                normalCell = semanticSchemaColumn.type.getId(semanticCell);
                return;
            end
            
            if strcmp(semanticSchemaColumn.type, 'INTEGER')
                normalCell = int16(str2num(semanticCell));
                return;
            end
            
            if strcmp(semanticSchemaColumn.type, 'REAL')
                normalCell = utils.toNumber(semanticCell);
                return;
            end
            
            if (strcmp('TEXT', semanticSchemaColumn.type(1:length('TEXT'))))
                normalCell = semanticCell;
                return;
            end
            
            throw MException('data:DataTable:semanticToNormalCell', strcat('Semantic type unknown: ', semanticSchemaColumn.type));
        end
    end
end

