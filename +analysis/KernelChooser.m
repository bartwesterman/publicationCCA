classdef KernelChooser < handle
    %KERNELCHOOSER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hillFunctions;
    end
    
    methods
        % dreamMonoAndCombinationTraining = readtable(Config.DREAM_MONO_AND_COMBINATION_TRAINING)
        function obj = init(obj, dreamMonoAndCombinationTraining)
            parameterTable = obj.restructureParameterTable(dreamMonoAndCombinationTraining);
            parameterTable = obj.filterParameterTable(parameterTable);
            
            obj.hillFunctions = obj.convertParameterTableToFunctions(parameterTable);
        end
        
        function parameterTable = restructureParameterTable(obj, rawTable)
            ic50 = [rawTable.IC50_A;
                    rawTable.IC50_B];
                
            hill = [rawTable.H_A;
                    rawTable.H_B];
                
            bottom = [rawTable.Einf_A;
                      rawTable.Einf_B];
            
            maxDose = str2double([rawTable.MAX_CONC_A;
                       rawTable.MAX_CONC_B]);
             
            parameterTable = table(ic50, hill, bottom, maxDose);
        end
        
        function filteredParameterTable = filterParameterTable(obj, parameterTable)
            sensibleHillRows     = parameterTable.hill   < 10;
            sensibleBottomRows   = parameterTable.bottom < 85;
            sensibleIC50Rows     = parameterTable.ic50   < 5;
            
            sensibleRows = sensibleHillRows & sensibleBottomRows & sensibleIC50Rows;
            
            filteredParameterTable = parameterTable(sensibleRows, :);
        end
        
        function functionArray = convertParameterTableToFunctions(obj, parameterTable)
                        
            functionArray = rowfun(@(ic50, hill, bottom, maxDose)...
                obj.makeHillFunction(ic50, hill, bottom, maxDose)... 
                , parameterTable, 'OutputFormat', 'cell');
        end
        
        function hillFunction = makeHillFunction(obj, ic50, hill, bottom, maxDose)
            
            rescaledIC50   = ic50 * maxDose;
            rescaledBottom = bottom/100;
            % top = 100 / 100 = 1
            
            hillFunction = @(x) (rescaledBottom + (1 - rescaledBottom) ./ (1 + (x/rescaledIC50) .^ (-hill) ));
        end
        
        function [bestKernelName, bestKernel] = chooseKernel(obj, kernelTable)
            
            % loop through the kernelTable and see which kernel can be fit
            % best to the input distribution
            bestKernel  = [];
            bestKnownRootMeanSquaredError = Inf;
            bestKernelName = [];
            
            for i = 1:height(kernelTable)
                
                % pick the next kernel
                kernelFunction = kernelTable.kernelFunction{i};
                
                % the sum of the mean squared error
                rootMeanSquaredError = 0;
                
                % loop through all hill functions that must be fit
                for j = 1:length(obj.hillFunctions)
                    
                    % get the next hillFunction that must be fit
                    hf = obj.hillFunctions{j};
                    
                    % generate input output examples based on the hill function to fit the kernel to
                    examples = obj.generateExamples(hf, 200);
                    
                    % split the examples into training set and test set
                    trainingSet = examples(1:140, :);
                    testSet = examples(141:end, :);
                    
                    % fit the function on the training set
                    fittedFunction = obj.fitFunction(trainingSet.input, trainingSet.output, kernelFunction);

                    % and validate it:
                    
                    % produce output using the input and the learned
                    % function
                    testOutput = fittedFunction(testSet.input);

                    % and update the sum of the mean squared error
                    rootMeanSquaredError = rootMeanSquaredError + sqrt(mean((testOutput - testSet.output).^2) / length(obj.hillFunctions));
                end
                
                if (rootMeanSquaredError < bestKnownRootMeanSquaredError)
                    bestKnownRootMeanSquaredError  = rootMeanSquaredError;
                    bestKernel = kernelFunction;
                    bestKernelName = kernelTable.kernelName{i};
                end
            end
        end
        function testPlot(obj, input, correctOutput, f)
            actualOutput = f(input);
            hold off
            [asdf, order] = sort(input);
            plot(input(order), correctOutput(order));
            hold on
            plot(input(order), actualOutput(order));
        end
        function fittedFunction = fitFunction(obj, input, output, kernel)
            wrappedKernel = obj.wrapWithNeuralParameters(kernel);
            
            boundParams = lsqcurvefit(wrappedKernel, rand(2, 1), input, output);
            
            fittedFunction = @(x) wrappedKernel(boundParams, x);
        end
        
        function wrappedKernel = wrapWithNeuralParameters(obj, kernel)
            % x(1) := weight
            % x(2) := threshold
            wrappedKernel = @(x, xdata) kernel(x(1) * xdata + x(2));
        end
        
        function examples = generateExamples(obj, hf, exampleCount)
            input = rand(exampleCount, 1);
            output = hf(input);
            
            examples = table(input, output);
        end
    end
    
end

