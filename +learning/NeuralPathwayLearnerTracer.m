classdef NeuralPathwayLearnerTracer < handle
    %NEURALPATHWAYLEARNERTRACER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        valueTypeMap;
        valueTypeCounterMap;
        
    end
    
    methods
        
        function obj = init(obj)
            obj.valueTypeMap = containers.Map();
            obj.valueTypeCounterMap = containers.Map();
        end
        
        function isTrue = mustTrace(obj, valueType)
            isTrue = obj.valueTypeMap.isKey(valueType);
        end
        
        function appendTraceValue(obj, valueType, value)
            
            if (iscell(value))
                for i = 1:length(value)
                    obj.appendTraceValue(valueType, value{i});
                end
                return;
            end
            
            % increase the value counter 
            obj.valueTypeCounterMap(valueType) = obj.valueTypeCounterMap(valueType) + 1;            
                        
            % add it to the trace array
            traceArray = obj.valueTypeMap(valueType);               % get the trace array
            traceArray{obj.valueTypeCounterMap(valueType)} = value; % update the trace array
            obj.valueTypeMap(valueType) = traceArray;               % store the trace array
        end
        
        function startTrace(obj, valueType, valueCount)
            obj.valueTypeCounterMap(valueType) = 0;
            obj.valueTypeMap(valueType) = cell(valueCount, 1);
            
        end
        
        function multipliedComponents = componentMultiplication(obj, vec, mat)
            multipliedComponents = zeros(size(mat));
            
            for i = 1:length(vec)
                multipliedComponents(i, :) = vec(i) * mat(i, :);
            end
        end
    end
    
end

