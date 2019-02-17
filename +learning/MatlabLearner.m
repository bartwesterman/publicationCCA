classdef MatlabLearner < LearnerInterface
    %MATLABADAPATER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model;
        fittingFunction;
        dimensionReducerFactoryFunction;
        dimensionReducerFunction;
    end
    
    methods
        function obj = init(obj, fittingFunction, dimensionReducerFactoryFunction)
            %
            
            obj.dimensionReducerFactoryFunction = dimensionReducerFactoryFunction;
            obj.fittingFunction = fittingFunction;
            
        end
        function train(obj, examples)
            obj.dimensionReducerFunction = obj.dimensionReducerFactoryFunction(examples);
            classes = examples(:, 1);
            items   = examples(:, 2:end); 
            reducedDimensionItems = obj.dimensionReducerFunction(items);
            reducedDimensionExamples = [classes reducedDimensionItems];
            obj.model = obj.fittingFunction(reducedDimensionExamples);
        end
        
        function prediction = predict(obj, items)
            reducedDimensionItems = obj.dimensionReducerFunction(items);
            prediction = obj.model.predict(reducedDimensionItems);
        end
    end
    
end

