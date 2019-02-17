function [ resultMatrix, levelsNodeCountHiddenLayer1, levelsNodeCountHiddenLayer2 ] = resultTableToNodeCountMatrix( resultTable, performanceMeasure )
%RESULTTABLETONODECOUNTMATRIX Summary of this function goes here
%   Detailed explanation goes here

    if isprop(resultTable.learner, 'hiddenLayers')
        hiddenLayerMatrix = arrayfun(@(l)[l.hiddenLayers zeros(1, 2 - length(l.hiddenLayers))], resultTable.learner, 'UniformOutput', false);
        hiddenLayerMatrix = vertcat(hiddenLayerMatrix{:});
    else
        hiddenLayerMatrix = arrayfun(@(l)[l.learner.hiddenLayers zeros(1, 2 - length(l.learner.hiddenLayers))], resultTable.learner, 'UniformOutput', false);
        hiddenLayerMatrix = vertcat(hiddenLayerMatrix{:});
    end

    levelsNodeCountHiddenLayer1 = sort(unique(hiddenLayerMatrix(:,1)));
    levelsNodeCountHiddenLayer2 = sort(unique(hiddenLayerMatrix(:,2)));
    
    resultMatrix = zeros(length(levelsNodeCountHiddenLayer1), length(levelsNodeCountHiddenLayer2)) + NaN;
    
    for i = 1:length(hiddenLayerMatrix)
        
        layer1Index = (levelsNodeCountHiddenLayer1 == hiddenLayerMatrix(i, 1));
        layer2Index = (levelsNodeCountHiddenLayer1 == hiddenLayerMatrix(i, 2));
        
        assert(sum(layer1Index) == 1);
        assert(sum(layer2Index) == 1);
                
        resultMatrix(layer1Index, layer2Index) = resultTable.(performanceMeasure)(i);
    end
end

