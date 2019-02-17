function coordinates = createGraphNeuralNetworkResults( neuralNetworkResultPath, neuralNetworkPearsonResultGraphFilePath, neuralNetworkWeightedPearsonResultGraphFilePath)
%CREATEGRAPHNEU Summary of this function goes here
%   Detailed explanation goes here
    resultList = planB.Control.loadMatlabObjectPath(neuralNetworkResultPath, 'result');
    
    function c = resultToCoordinate(result, property)
        z = result.(property);
        if isprop(result.learner, 'hiddenLayers')
            hiddenLayers = result.learner.hiddenLayers;
        else
            hiddenLayers = result.learner.learner.hiddenLayers;
        end
        
        if isempty(hiddenLayers)
            c = [0 0 z];
            return;
        end
        
        if length(hiddenLayers) == 1
            c = [hiddenLayers 0 z];
            return;
        end
        
        c = [hiddenLayers z];
    end

    function graphForProperty(property, filePath)
        coordinates = cellfun(@(result)resultToCoordinate(result, property), resultList, 'UniformOutput', false);
        coordinates = vertcat(coordinates{:});

        psp = planB.view.PinScatterPlot().init(coordinates, [property ' performance neural networks'], 'node count layer 1', 'node count layer 2', property);

        utils.assurePathFor(filePath);
        psp.save(filePath);
    end

    graphForProperty('pearsonCorrelation', neuralNetworkPearsonResultGraphFilePath);
    graphForProperty('weightedPearson', neuralNetworkWeightedPearsonResultGraphFilePath);
end

