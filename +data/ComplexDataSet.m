classdef ComplexDataSet < data.DataSet
    %COMPLEXDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        componentDataSetArray;
    end
    
    methods
        function obj = init(obj, selectionInterface)
            data.DataSet.init(obj, selectionInterface);
            obj.componentDataSetArray = {};
        end
        
        function addDataSet(obj, dataSet)
            obj.componentDataSetArray{end} = dataSet;
        end
    end
    
end

