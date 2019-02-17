classdef AfterLearningRegression < handle
    %AFTERLEARNINGREGRESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        learner;
        
        bestFit;
        
        allFits;
    end
    
    methods
        function obj = init(obj, learner, trainingSet)
            obj.learner = learner;            
        end
       
        function output = predict(obj, input)
            output = obj.bestFit.func(obj.learner.predict(input));
        end
        
        function doFunctionFitting(obj, trainingSet)
            obj.allFits = struct;
            
            lowestKnownRootMeanSquaredError = Inf;
            
            for name = {'poly1', 'poly2', 'poly3', 'exp1', 'exp2', 'power2'} % power1 raised an error
                name = name{1};
                prediction = obj.learner.predict(trainingSet.getInput());
                
                try
                    [fittedFunction, goodnessOfFit] = fit(prediction, trainingSet.getOutput(), name);
                catch
                    continue; 
                end
                
                result = struct;
                result.('name') = name;
                result.('func') = fittedFunction;
                result.('goodnessOfFit') = goodnessOfFit;
                
                obj.allFits.(name) = result;
                
                if goodnessOfFit.rmse < lowestKnownRootMeanSquaredError
                    lowestKnownRootMeanSquaredError = goodnessOfFit.rmse;
                   
                    obj.bestFit = result;
                end
            end
        end
        
        function results = analyze(obj, trainingSet, testSet)
        
            obj.doFunctionFitting(trainingSet);
        
            outputs = obj.predict(testSet.getInput());
            
            results = testSet.analyzePerformance(outputs);
            results.learner = obj;
        end
    end
    
end

