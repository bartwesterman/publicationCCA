classdef NeuralNetwork < handle
    %NEURALNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        learner;
        hiddenLayers;
        kernelName;
    end
    
    methods
        function obj = init(obj, hiddenLayers, kernelName)
            if nargin < 2 
                hiddenLayers = 10;
            end
            
            obj.hiddenLayers = hiddenLayers;
            obj.learner = fitnet(obj.hiddenLayers); % standard feedforward net with 10 hidden neurons
            obj.learner.trainParam.showWindow=0;  
            obj.learner.divideParam.trainRatio = .8;
            obj.learner.divideParam.valRatio   = .2;
            obj.learner.divideParam.testRatio = 0; % testing is done by NeuralNetwork itself.
            
            if nargin > 2
                obj.learner.layers{:}.transferFcn = kernelName;
                obj.kernelName = kernelName;
            end
        end
        
        function results = analyze(obj, trainingSet, testSet)
                        
            [obj.learner, tr] = train(obj.learner, trainingSet.getInput()', trainingSet.getOutput()');
            
            outputs = obj.predict(testSet.getInput());
            
            results = testSet.analyzePerformance(outputs);
            results.learner = obj;
        end
        
        function output = predict(obj, input)
            output = obj.learner(input')';
        end
        
        function hash = getHash(obj)
            hash = ['planB.NeuralNetwork.init(' strrep(mat2str(obj.hiddenLayers), ' ', '_' )];
            if ~isempty(obj.kernelName)
                hash = [hash ',' obj.kernelName];
            end
            hash = [hash ')'];
        end
        
                function nc = nodeCount(obj)
            nc = sum(obj.hiddenLayers) + 1;
        end
        
        function total = weightCount(obj, inputCount)
            allLayers = [obj.hiddenLayers 1];
            previousLayerCount = inputCount;
            currentTotal = 0;
            
            for i = 1:length(allLayers)
                currentTotal = currentTotal + previousLayerCount * allLayers(i);
                previousLayerCount = allLayers(i);
            end
           
            total = currentTotal;
        end
    end
    
    methods (Static)
        function tasks = createTasks(kernelName)
%             tasks = cell(4);
%             
%             tasks{1} = planB.NeuralNetwork().init([]);
%             tasks{2} = planB.NeuralNetwork().init(10);
%             tasks{3} = planB.NeuralNetwork().init([5 3]);
%             tasks{4} = planB.NeuralNetwork().init([10 5]);
            
            exponents = 2 .^ (0:5);
            taskCount = length(exponents) * (length(exponents) + 1) + 1;
            
            tasks = cell(taskCount, 1);
            
            nextTask = 1;
            if nargin == 0
                tasks{nextTask} = planB.NeuralNetwork().init([]);
            elseif nargin == 1
                tasks{nextTask} = planB.NeuralNetwork().init([], kernelName);
            end
            
            nextTask = nextTask + 1;
            for firstLayerCount = exponents
                for secondLayerCount = [0 exponents]
                    if secondLayerCount == 0
                        secondLayerCount = [];
                    end
                    if nargin == 0
                        task = planB.NeuralNetwork().init([firstLayerCount secondLayerCount]);
                    elseif nargin == 1
                        task = planB.NeuralNetwork().init([firstLayerCount secondLayerCount], kernelName);
                    end
                    tasks{nextTask} = task;
                    nextTask = nextTask + 1;
                end
            end
        end

            
    end
end

