classdef ExampleSet < handle
    %EXAMPLESET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        schema;
        data;
    end
    
    methods
        function obj = init(obj, schema, data)
            obj.schema = schema;
            obj.data   = data;
        end
        
        function b = mustNormalizeColumn(obj, semanticSchemaColumn)
            if strcmp(semanticSchemaColumn.type, 'REAL')
                b = true;
                return;
            end
            
            b = false;
            return;
        end
        
        function normalizeColumns(obj, normalizationFunction)
            for i = 1:length(obj.schema)
                schemaColumn = obj.schema(i);
                
                if (obj.mustNormalizeColumn(schemaColumn))
                    obj.data(:, i) = normalizationFunction(obj.data(:, i));
                end
            end
        end
        
        
        function normalizeLinearly(obj)
            obj.normalizeColumns(@data.normalize.linear);
        end
        
        function normalizeLogarithmically(obj)
            obj.normalizeColumns(@data.normalize.logarithmic);
        end
        
        function normalizeOptimally(obj)
            obj.normalizeColumns(@data.normalize.optimal);            
        end
    end        
    methods (Static)
    end
    
end

