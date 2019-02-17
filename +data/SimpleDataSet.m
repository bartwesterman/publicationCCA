classdef SimpleDataSet < data.DataSet
    %ATOMICDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pattern;
    end
    
    methods
        function obj = init(obj, selectionInterface, pattern)
            data.DataSet.init(obj, selectionInterface);
            obj.pattern = pattern;
        end
        
        function queryPattern = getPattern(obj)
            queryPattern = obj.pattern;
        end
    end
    
end

