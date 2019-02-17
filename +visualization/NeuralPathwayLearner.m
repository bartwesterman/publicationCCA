classdef NeuralPathwayLearner
    %NEURALNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        frameSequence;
    end
    
    methods
        function obj = init(obj, networkHistory)
            figure
            bestScale = 0;
            minimalValue = Inf;
            for i = 1:length(networkHistory);
                networkState = networkHistory{i};
                bestScale = max([bestScale, -min(min(networkState)), max(max(networkState))]);
                minimalValue = min( min(min(networkState)), minimalValue);
            end
            
            for i = 1:length(networkHistory);
                obj.renderNetworkState(networkHistory{i}, minimalValue, bestScale);
                frameSequence(i) = getframe;
            end
            obj.frameSequence = frameSequence;
        end
        
        function play(obj)
            movie(obj.frameSequence);
        end
        
        function renderNetworkState(obj, networkState, minimalValue, bestScale)
            thresholds = networkState(1, :);
            fromTo = networkState(2:end, :);
            
            g = digraph(fromTo);
            
            p = plot(g);
            
            onlyPositiveThresholds = thresholds;
            onlyPositiveThresholds(thresholds < 0) = 0;
            
            onlyNegativeThresholds = thresholds;
            onlyNegativeThresholds(thresholds > 0) = 0;

            
            p.NodeColor = [(-minimalValue + onlyNegativeThresholds' / bestScale) (onlyPositiveThresholds' / bestScale) ones(size(onlyNegativeThresholds))' ];
            
            onlyPositiveWeights = g.Edges.Weight;
            onlyPositiveWeights(g.Edges.Weight < 0) = 0;
            
            
            onlyNegativeWeights = g.Edges.Weight;
            onlyNegativeWeights(g.Edges.Weight > 0) = 0;
            
            p.EdgeColor = [((-minimalValue + onlyNegativeWeights) / bestScale) (onlyPositiveWeights / bestScale) zeros(size(onlyNegativeWeights))];
            layout(p,'force','Iterations',10);
        end
    end
end

