classdef SupportVectorMachine < handle
    %NEURALNETWORK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        KERNELS = {'gaussian', 'linear', 'polynomial'};
    end
    
    properties
        learner;
        kernel;
    end
    
    methods
        function obj = init(obj, kernel)
            if nargin < 2 
                kernel = 10;
            end
            
            obj.kernel = kernel;
        end
        
        function results = analyze(obj, trainingSet, testSet)
                        
            obj.learner = fitrsvm(trainingSet.getInput(), trainingSet.getOutput(), 'KernelFunction', obj.kernel,'Standardize',true);
            
            outputs = obj.learner.predict(testSet.getInput());
            
            results = testSet.analyzePerformance(outputs);
            results.learner = obj;
        end
        
        function output = predict(obj, input)
            output = obj.learner.predict(input);
        end
        
        function hash = getHash(obj)
            hash = ['planB.SupportVectorMachine.init(' strrep(obj.kernel, ' ', '_' ) ')'];
        end
    end
    
    methods (Static)
        function tasks = createTasks()

            kernels = planB.SupportVectorMachine.KERNELS;
            
            tasks = cell(length(kernels), 1);
            
            nextTask = 1;
            
            for k = kernels
                tasks{nextTask} = planB.SupportVectorMachine().init(k{1});
                nextTask = nextTask + 1;
            end
        end
    end
end

