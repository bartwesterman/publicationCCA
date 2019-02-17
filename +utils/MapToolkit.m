classdef MapToolkit 

    properties
    end
    
    methods(Static)
        function map = listToMap(list)
            map = containers.Map;
            
            uniqueId = 1;
            
            for i = 1:length(list)

                name = list{i};
                
                if (map.isKey(name))
                    continue
                end

                map(name) = uniqueId;
                uniqueId = uniqueId + 1; 
            end
        end
        
        function map = keyValueListsToMap(keyList, valueList)
            map = containers.Map;
            
            for i = 1:length(keyList)
                map(keyList{i}) = valueList{i};
            end
        end
    end
end
