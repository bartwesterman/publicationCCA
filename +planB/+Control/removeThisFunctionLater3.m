function removeThisFunctionLater3()
%REMOVETHISFUNCTIONLATER Summary of this function goes here
%   Detailed explanation goes here

    planB.Control.runNeuralNetworkTask('./output/results/synergy/neuralNetworkTasks/planB.NeuralNetwork.init([],123123123).mat', './output/results/synergy/reducedExampleSet.mat',     './output/results/synergy/neuralNetworkResults/planB.NeuralNetwork.init([],123123123).mat');
    planB.Control.runNeuralNetworkTask('./output/results/synergy/neuralNetworkTasks/planB.NeuralNetwork.init(10,123123123).mat', './output/results/synergy/reducedExampleSet.mat',         './output/results/synergy/neuralNetworkResults/planB.NeuralNetwork.init(10,123123123).mat');
    planB.Control.runNeuralNetworkTask('./output/results/synergy/neuralNetworkTasks/planB.NeuralNetwork.init([5_3],123123123).mat', './output/results/synergy/reducedExampleSet.mat',      './output/results/synergy/neuralNetworkResults/planB.NeuralNetwork.init([5_3],123123123).mat');
    planB.Control.runNeuralNetworkTask('./output/results/synergy/neuralNetworkTasks/planB.NeuralNetwork.init([10_5],123123123).mat', './output/results/synergy/reducedExampleSet.mat',     './output/results/synergy/neuralNetworkResults/planB.NeuralNetwork.init([10_5],123123123).mat');
end

