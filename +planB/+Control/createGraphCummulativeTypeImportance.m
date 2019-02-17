function  createGraphCummulativeTypeImportance(importanceResultFilePath, cummulativeTypeImportanceGraphFilePath, cummulativeTypeCountGraphFilePath, importantEntityCount)
%CREATECUMMULATIVETYPEIMPORTANCE Summary of this function goes here
%   Detailed explanation goes here
    load(importanceResultFilePath, 'result');
    
    function realType = getRealTypeOfRow(type, label, importance, entityId)
        if strcmp(type, 'drug')
            realType = 'drug';
            return;
        end
        
        if entityId > 0
            realType = 'expression';
            return;
        end
        
        realType = 'mutation';
        return;
    end
    
    realType = rowfun(@getRealTypeOfRow, result.importance, 'OutputFormat', 'cell');
    
    
    uniqueType = unique(realType);
    
    typeImportance = table();
    typeCount      = table();
    
    for typeName = uniqueType'
        typeName = typeName{1};
        typeImportance.(typeName) = zeros(length(result.importance.importance), 1);
        typeCount.(typeName)      = zeros(length(result.importance.importance), 1);
    end
    
    typeImportance.total = zeros(length(result.importance.importance), 1);
    typeCount.total      = zeros(length(result.importance.importance), 1);
    
    for i = 1:length(result.importance.importance)
        type = realType{i};
        
        if i ~= 1
            typeImportance(i, :) = typeImportance(i - 1, :);
            typeCount(i, :)      = typeCount(i - 1, :);          
        end
        typeImportance.(type)(i) = typeImportance.(type)(i) + result.importance.importance(i);
        typeImportance.total(i)  = typeImportance.total(i) + typeImportance.(type)(i);
        
        typeCount.(type)(i)      = typeCount.(type)(i) + 1;
        typeCount.total(i)       = typeCount.total(i) + 1;
    end
    
    typeImportanceGraph = planB.view.MultiLinePlot().init(typeImportance(1:importantEntityCount, uniqueType), 'Increase of total feature importance by type, with features added in order of greatest importance', 'importance rank', 'accumated importance');
    typeImportanceGraph.save(cummulativeTypeImportanceGraphFilePath);
    typeCountGraph = planB.view.MultiLinePlot().init( typeCount(1:importantEntityCount, uniqueType), 'Increase of features by type, when added in order of importance', 'importance rank', 'accumated importance');
    typeCountGraph.save(cummulativeTypeCountGraphFilePath);

end

