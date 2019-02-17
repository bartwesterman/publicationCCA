classdef UnionDataSet < data.ComplexDataSet
    %DATASETUNION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function queryPattern = getPattern(obj)
            queryPattern = ['FROM ( ' strjoin(cellfun(@(ds) ds.getQuery(), obj.componentDataSetArray), ' UNION ') ' )'];
        end
    end
    
end

