classdef SensitivityDataSet < handle
    %SENSITIVITYDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pIc50Data;
    end
    
    methods
        function obj = initBySensitivityData(obj, pIc50Data)
            obj.pIc50Data = pIc50Data;
        end
        

        function objCopy = createMinIc50SensitivityDataSet(obj)
            myClass = str2func(class(obj));
            objCopy = myClass();
            objCopy.initBySensitivityData(obj.pIc50Data);
            objCopy.pIc50Data.pIc50(cellfun(@(x)~isempty(x),  objCopy.pIc50Data.pIc50)) = num2cell(-((-cell2mat(objCopy.pIc50Data.pIc50)).^10)); %convert to ic50

        end
    end
    
end

