classdef DataSet < handle
    %DATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        selectionInterface;
    end
    
    methods
        function obj = init(obj, selectionInterface)
            obj.selectionInterface = selectionInterface;
        end
        
        function pattern = getPattern(obj)
            
        end
        
        function query = getQuery(obj)
            query = ['SELECT ' strjoin(obj.selectionInterface) ' ' obj.getPattern() ];
        end
    end
    
end

