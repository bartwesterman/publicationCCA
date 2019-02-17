classdef NeuralPathwayLearner < handle
    %NEURALPATHWAYLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        neuralPathwayMatrix;
        recursionDepth;
        dampeningMatrix;
        outputDampening;
        learningRate;
        learningRateIsBatchSizeAdapted;
        kernel;
        
        inputNodes;
        fixedInputNodes;
        
        previousWeightUpdate;
        
        momentumFactor;
        
        tracer;
        
        mustApplyBoldDriver;
        previousError;
        boldDriverDownCorrection;
        boldDriverUpCorrection;
        
        pathwayKnowledge;
        addedConnectionCount;
        nodeCount;
        
        inputInKnowledgeIsNotDirectlyLethal;
    end
    
    properties (Constant)
        kernelLibrary = struct(...
            'linear', struct(...
                'activation', @learning.activationFunctions.linear,...
                'inverseActivation', @(neuronOutput) neuronOutput,...
                'derivative', @learning.activationFunctions.linearDerivative ...
            ),...
            'sigmoid', struct(...
                'activation', @learning.activationFunctions.sigmoid,...
                'inverseActivation', @(networkOutput) -log( -1 + 1 / networkOutput),...
                'derivative', @learning.activationFunctions.sigmoidDerivative ...
            ),...
            'tanh', struct(...
                'activation', @learning.activationFunctions.tanh,...
                'inverseActivation', @(networkOutput) log(2 * ((networkOutput + 1) .^ -1) - 1) / -2,...
                'derivative', @learning.activationFunctions.tanhDerivative ...
            )...
        );
    end
    
    
    methods
        
        function obj = initPerceptron(obj, kernel, learningRate)
            obj.outputDampening = [];
            obj.tracer = [];
            
            obj.kernel = kernel;
            obj.learningRate = learningRate;
            
            nodeCount = 1;
            
            obj.neuralPathwayMatrix = rand(nodeCount + 1, nodeCount);
            obj.recursionDepth = 1;
            
            obj.dampeningMatrix = ones(size(obj.neuralPathwayMatrix));
            
            obj.learningRateIsBatchSizeAdapted = false;
        end
        
        function obj = initFeedForward(obj, kernel, learningRate, nodesPerLayer)
            obj.tracer         = [];
            
            obj.kernel         = kernel;
            obj.learningRate   = learningRate;
            obj.recursionDepth = length(nodesPerLayer);
            
            obj.neuralPathwayMatrix = sparse(obj.createFeedForwardMatrix(nodesPerLayer, @rand));
            obj.dampeningMatrix     = obj.createFeedForwardMatrix(nodesPerLayer, @ones);
            
            obj.outputDampening = obj.initFeedForwardOutputDampening(obj.dampeningMatrix(2:end, :), nodesPerLayer);
            
            obj.learningRateIsBatchSizeAdapted = false;
        end
        
        function obj = initRecurrent(obj, kernel, learningRate, nodeCount, recursionDepth)
            obj.tracer         = [];
            
            obj.kernel         = kernel;
            obj.learningRate   = learningRate;
            obj.recursionDepth = recursionDepth;
            
            obj.neuralPathwayMatrix = rand(nodeCount + 1, nodeCount);
            obj.dampeningMatrix     = ones(nodeCount + 1, nodeCount);
            
            obj.outputDampening = [];
        end
        
        function outputDampening = initFeedForwardOutputDampening(obj, dampeningMatrix, nodesPerLayer)
            outputDampening = zeros(length(nodesPerLayer), sum(nodesPerLayer));
            
            currentState = [zeros(1, sum(nodesPerLayer(1:(end - 1)))) ones(1, nodesPerLayer(end))];
            
            for i = 1:size(outputDampening, 1)
                currentState = (currentState * dampeningMatrix) ~= 0;
                outputDampening(i, :) = currentState;
            end
            
            outputDampening(end, 1) = 1;
        end
        
        function outputDampening = initPathwayOutputDampening(obj, dampeningMatrix, inputNodes)
            
            nodeCount = size(dampeningMatrix, 2);
                                    
            outputDampening = zeros(obj.recursionDepth, nodeCount);
            
            currentState = zeros(1, nodeCount);
            currentState(inputNodes) = 1;
            
            for i = 1:size(outputDampening, 1)
                currentState = (currentState * dampeningMatrix) ~= 0;
                outputDampening(i, :) = currentState;
            end

            % this line assures that even though the dampening matrix
            % extinguishes all signals from the death node, (to make sure
            % the death to death weight is never updated), the output isn't
            % dampened
            firstDeathIndex = find(outputDampening(:,1), 1);
            outputDampening(firstDeathIndex:end, 1) = 1;
            % outputDampening(1, 1) = 0;            

        end
        
        function feedForwardMatrix = createFeedForwardMatrix(obj, nodesPerLayer, valueFactory)
            fromTo = zeros(sum(nodesPerLayer));
            
            for i = 1:(length(nodesPerLayer) - 1)
                outputIndex = i;
                inputIndex  = i + 1;
                
                toLayerStart   = sum(nodesPerLayer(1:(outputIndex - 1))) + 1;
                toLayerEnd     = toLayerStart + nodesPerLayer(outputIndex) - 1;

                fromLayerStart = sum(nodesPerLayer(1:(inputIndex - 1))) + 1;
                fromLayerEnd   = fromLayerStart + nodesPerLayer(inputIndex) - 1;
                
                fromTo(fromLayerStart:fromLayerEnd, toLayerStart:toLayerEnd) = valueFactory(nodesPerLayer(inputIndex), nodesPerLayer(outputIndex));
            end
            
            feedForwardMatrix = [valueFactory(1, size(fromTo, 2)); fromTo];
        end
        % kernel: which element of learning.NeuralPathwayLearner.kernelLibrary
        % nodeCount: the total number of nodes including death, knowledge, and input nodes
        
        function obj = initPathway(obj, kernel, learningRate, nodeCount, pathwayKnowledge, recursionDepth, inputNodes, inputInKnowledgeIsNotDirectlyLethal, fixedInputNodes)
            if nargin < 9
                fixedInputNodes = [];
            end
            if nargin < 8
                inputInKnowledgeIsNotDirectlyLethal = false;
            end
            
            obj.pathwayKnowledge = pathwayKnowledge;
            obj.inputInKnowledgeIsNotDirectlyLethal = inputInKnowledgeIsNotDirectlyLethal;
            obj.nodeCount = nodeCount;
            
            obj.outputDampening = [];
            obj.tracer = [];
            
            obj.inputNodes = inputNodes;
            obj.fixedInputNodes = fixedInputNodes;
            
            obj.kernel = kernel;
            
            obj.learningRate = learningRate;
            knowledgeStart = 2;
            
            % init weight matrix
            obj.neuralPathwayMatrix = zeros(nodeCount + 1, nodeCount);
            
            % insert knowledge
            pathwayKnowledgeNodeCount = size(pathwayKnowledge,1 );
            knowledgeEnd = knowledgeStart + pathwayKnowledgeNodeCount - 1;
            
            obj.neuralPathwayMatrix((knowledgeStart + 1):(knowledgeEnd + 1),knowledgeStart:knowledgeEnd) = pathwayKnowledge;
            
            % create dampening matrix to define what connections can change
            inputNodesInKnowledge = inputNodes(inputNodes <= (size(pathwayKnowledge, 1) +1 ));
            obj.dampeningMatrix = obj.createDampeningMatrix(pathwayKnowledge, inputNodesInKnowledge, inputInKnowledgeIsNotDirectlyLethal);
            
           
            obj.neuralPathwayMatrix(2, :) = 0; % the death node may not connect to any other node
            obj.neuralPathwayMatrix(2, 1) = 1; % but... the death node must store it's value, and retain a link to where the value came from to allow backpropagation to properly increase or decrease it's value
            
            obj.neuralPathwayMatrix((knowledgeStart + 1):(knowledgeEnd + 1), 1) = (2 * rand(pathwayKnowledgeNodeCount, 1) - 1); % knowledge nodes can connect to the death node
            
            obj.neuralPathwayMatrix = sparse(obj.neuralPathwayMatrix);
            obj.dampeningMatrix = sparse(obj.dampeningMatrix);
            
           % insert noise to allow the network to establish new connections
            weightValues = pathwayKnowledge(1:end);
            nonZeroWeightValues = weightValues(weightValues ~= 0);
            lowestAbsoluteWeight = min(abs(nonZeroWeightValues));            
            
            noiseRange = .2 * lowestAbsoluteWeight;
            
            obj.neuralPathwayMatrix = obj.neuralPathwayMatrix + noiseRange * (2 * obj.dampeningMatrix .* rand(size(obj.dampeningMatrix)) - (obj.dampeningMatrix ~= 0));
 
            obj.recursionDepth = recursionDepth;
 
            obj.outputDampening = obj.initPathwayOutputDampening(obj.dampeningMatrix(2:end, :), obj.inputNodes);
            
            obj.learningRateIsBatchSizeAdapted = false;    
            
            obj.scaleWeightsByInputCount();
        end
        
        function scaleWeightsByInputCount(obj)
            % columns are input weights of the neurons matching the index
            % those columns must be scaled down proportional to their
            % inputs
            connectivityMatrix = obj.dampeningMatrix ~= 0;
            inputCountVector = sum(connectivityMatrix, 1);
            inputCountVector(inputCountVector == 0) = 1; % if there are no inputs, the inputs should not be altered
            for neuronIndex = 1:size(obj.neuralPathwayMatrix, 2)
                obj.neuralPathwayMatrix(:,neuronIndex) = obj.neuralPathwayMatrix(:,neuronIndex) / inputCountVector(neuronIndex);
            end
        end
        
        % @TODO: MAKE IT WORK WITH IntraPathwayLearner
        % WARNING: DOES NOT WORK YET WITH INTRAPATHWAY LEARNER!!!!
        function obj = initControl(obj, neuralPathwayLearner)

            % compute random knowledge matrix but with the same number of
            % connections:
            knowledgeMatrixConnectionCount = sum(sum(neuralPathwayLearner.pathwayKnowledge ~= 0));
            
            knowledgeMatrix = zeros(size(neuralPathwayLearner.pathwayKnowledge));
            
            knowledgeMatrix(randperm(prod(size(neuralPathwayLearner.pathwayKnowledge)), knowledgeMatrixConnectionCount)) = 1;
            
            obj.initPathway(neuralPathwayLearner.kernel, neuralPathwayLearner.learningRate, neuralPathwayLearner.nodeCount, knowledgeMatrix, neuralPathwayLearner.recursionDepth, neuralPathwayLearner.inputNodes , neuralPathwayLearner.inputInKnowledgeIsNotDirectlyLethal);
            obj.setMomentumFactor(neuralPathwayLearner.momentumFactor);
            obj.setMustApplyBoldDriver(neuralPathwayLearner.mustApplyBoldDriver);
            if (isempty(neuralPathwayLearner.addedConnectionCount)) 
                return;
            end
            
            allNodesExceptDeath = [2:neuralPathwayLearner.nodeCount];
            allNodesExceptDeathAndInput = allNodesExceptDeath(~ismember(allNodesExceptDeath, neuralPathwayLearner.inputNodes));
           
            inputCount = length(neuralPathwayLearner.inputNodes);
            outputCount = length(allNodesExceptDeathAndInput);
            possibleAddedConnections = inputCount * outputCount;
            randomAddedConnections = randperm(possibleAddedConnections, neuralPathwayLearner.addedConnectionCount);
            [r, c] = ind2sub([inputCount, outputCount], randomAddedConnections);
            fromIndices = neuralPathwayLearner.inputNodes(r);
            toIndices = allNodesExceptDeathAndInput(c);
            
            for i = 1:length(fromIndices)
                obj.connect(fromIndices(i), toIndices(i),2 * rand(1) * length(fromIndices) - 1);
            end
            
%             fromIndices = randperm(neuralPathwayLearner.inputNodes, neuralPathwayLearner.addedConnectionCount);
%             allNodesExceptDeath = [2:neuralPathwayLearner.nodeCount];
%             allNodesExceptDeathAndInput = allNodesExceptDeath(~ismember(allNodesExceptDeath, neuralPathwayLearner.inputNodes));
%             toIndices   = randperm(allNodesExceptDeathAndInput, neuralPathwayLearner.addedConnectionCount);
%             % what kind of effect? positive? or both positive and negative?
%             obj.connect(fromIndices, toIndices,2 * random(size(fromIndices)) - 1);
        end
        
        
        function initNonRandom(obj, weightMatrix, dampeningMatrix, inputNodes, kernel, recursionDepth, learningRate)
            obj.neuralPathwayMatrix = weightMatrix;
            obj.inputNodes = inputNodes;
            
            obj.kernel = kernel;
            obj.recursionDepth = recursionDepth;
            obj.learningRate = learningRate;
            obj.dampeningMatrix = dampeningMatrix;
            
            obj.outputDampening = obj.initPathwayOutputDampening(obj.dampeningMatrix(2:end, :), obj.inputNodes);
            obj.learningRateIsBatchSizeAdapted = false;
            
        end
        
        function setTracer(obj, tracer)
            obj.tracer = tracer;
        end
        
        function obj = initRandom(obj,  kernel, nodeCount, learningRate, recursionDepth)
            obj.outputDampening = [];
            obj.tracer = [];
            obj.kernel = kernel;
            
            obj.neuralPathwayMatrix = (2 * rand(nodeCount + 1, nodeCount) - 1);
            obj.recursionDepth      = recursionDepth;
            obj.learningRate        = learningRate;
            obj.dampeningMatrix = ones(size(obj.neuralPathwayMatrix));
            
            obj.neuralPathwayMatrix = sparse(obj.neuralPathwayMatrix);
            obj.dampeningMatrix = sparse(obj.dampeningMatrix);
            obj.learningRateIsBatchSizeAdapted = false;            
        end
        

        
        function dampeningMatrix = createDampeningMatrix(obj, knowledgeMatrix, inputIndicesInKnowledge, inputInKnowledgeIsNotDirectlyLethal)
            
            knowledgeNodeCount = size(knowledgeMatrix,1);
            
            deathNodeOutputIndex       = 1;            
            
            startOutputIndexKnowledgeNodes = deathNodeOutputIndex + 1;
            endOutputIndexKnowledgeNodes   = knowledgeNodeCount + 1;
            startOutputIndexInputNodes     = endOutputIndexKnowledgeNodes + 1;
            endOutputIndexInputNodes       = size(obj.neuralPathwayMatrix, 2);
            
            knowledgeNodeOutputIndexes = startOutputIndexKnowledgeNodes:endOutputIndexKnowledgeNodes;
            inputNodeOutputIndexes     = startOutputIndexInputNodes:endOutputIndexInputNodes;
            
            biasInputIndex            = 1;
            
            deathNodeInputIndex       = deathNodeOutputIndex + biasInputIndex;
            knowledgeNodeInputIndexes = knowledgeNodeOutputIndexes + biasInputIndex;
            inputNodeInputIndexes     = inputNodeOutputIndexes + biasInputIndex;
            % no node may connect
            dampeningMatrix = zeros(size(obj.neuralPathwayMatrix));
            
            % unless:
            
            % None of the outgoing weigths of the death node can change
            dampeningMatrix(deathNodeInputIndex, :) = 0;
            
            % bias weight to the death node should always remain 0
            dampeningMatrix(biasInputIndex, deathNodeOutputIndex) = 0;

            
            % knowledge nodes can not offer input to any nodes,
            % unless it is allowed by the pathway knowledge, or it is the
            % death node
            
            % so allow all connections that are in the pathway knowledge
            allowedConnections = knowledgeMatrix ~= 0;
             
            dampeningMatrix(knowledgeNodeInputIndexes, knowledgeNodeOutputIndexes) = allowedConnections;
            
            % and allow knowledge nodes to connect to the death node;
            dampeningMatrix(knowledgeNodeInputIndexes, deathNodeOutputIndex) = 1; 
            
            % input nodes may only connect to knowledge nodes, and not to
            % other input nodes
            
            % knowledge nodes may not connect to input (or out of pathway)
            % nodes:
            dampeningMatrix(knowledgeNodeInputIndexes, inputNodeOutputIndexes) = 0;
            
            
            % input (or out of pathway target) nodes may not connect to
            % each other:
            dampeningMatrix(inputNodeInputIndexes, inputNodeOutputIndexes) = 0;
            
%             % connecting to knowledge is ok though, but not to death
            dampeningMatrix(inputNodeInputIndexes, knowledgeNodeOutputIndexes) = 1;

            % and temporarily activating this:
            % input (or out of pathway target) nodes may not connect to
            % death and knowledge nodes either
            dampeningMatrix(inputNodeInputIndexes, 1:(knowledgeNodeCount + 1)) = 0;
            
            % THIS DEACTIVATION DOES MEAN THAT ELSEWHERE IT IS NECESSARY TO CONNECT
            % DRUGS TO TARGETS
            
            % input nodes can not connect to death
            dampeningMatrix(inputNodeInputIndexes, deathNodeOutputIndex) = 0;
            
            
            % the bias weights can only change for the nodes that are not
            % the death node, and not just input nodes
            dampeningMatrix(1, knowledgeNodeOutputIndexes) = 1;
            dampeningMatrix(1, 1) = 0;
            dampeningMatrix(1, inputNodeOutputIndexes) = 0;
            
            if ~inputInKnowledgeIsNotDirectlyLethal
                return;
            end
            
            % input indices in knowledge may not have any bias
            dampeningMatrix(1, inputIndicesInKnowledge) = 0;
            
            % input indices in knowledge may not connect to the death node
            dampeningMatrix(inputIndicesInKnowledge + 1, 1) = 0;
        end

        function setLearningRateIsBatchSizeAdapted(obj, v)
            obj.learningRateIsBatchSizeAdapted = v;
        end

        function [errorHistory, networkHistory] = train(obj, cycleCount, inputSet, correctOutput)
            
            if ~isempty(obj.tracer)
%                 obj.tracer.startTrace('error', cycleCount * obj.recursionDepth);
%                 obj.tracer.startTrace('output', cycleCount * obj.recursionDepth);
%                 obj.tracer.startTrace('weightUpdate', cycleCount);
                
                if size(inputSet, 1) == 1
                    obj.tracer.startTrace('weightOutput', cycleCount * obj.recursionDepth);
                    obj.tracer.startTrace('weightError', cycleCount * (obj.recursionDepth - 1));
                    obj.tracer.startTrace('weights', cycleCount);
                    
                end
            end
            
            networkHistory = cell(cycleCount,  1);
            errorHistory   = zeros(cycleCount, 1);
            
            for i = 1:cycleCount
                networkHistory(i) = {obj.neuralPathwayMatrix};
                
                nextError = obj.trainingCycle(inputSet, correctOutput);
                errorHistory(i) = mean(nextError .* nextError);
                
            end
        end
        
        function finalError = trainingCycle(obj, inputSet, correctOutput)
            activationArrayFun = @(f, networkInput) sparse(arrayfun(f, full(networkInput)));   
            if (obj.activationFunction(0) == 0)
                activationArrayFun = @spfun;
            end

            outputArray = obj.produceOutput(inputSet);
            
            finalOutput = obj.activationFunction(outputArray{end});
            deathRate   = finalOutput(:, 1);
            % observation - error = correct
            % observation - correct = error
            finalError  = deathRate - correctOutput ;
            % check the matrix dimensions
            invertedErrorArray  = obj.backpropagateError(outputArray, [finalError zeros(size(finalError, 1), size(obj.neuralPathwayMatrix, 2)- 1)]);

            % take only the output that is from hidden neurons:
            hiddenOutput = outputArray(1:(end - 1));
            
            % convert network output to actual neuron output
            hiddenActivation = cellfun(@(hiddenOutputElement) obj.activationFunction(hiddenOutputElement), hiddenOutput, 'UniformOutput', false);

            % @TODO: hiddenActivation should be dampened by outputDampening
%             for i = 1:length(hiddenActivation)
%                 hiddenActivation{i} =repmat(obj.outputDampening(i + 1, :), size(hiddenActivation{i}, 1),1 ) .* hiddenActivation{i}
%             end
            
            neuronOutputArray = vertcat({inputSet}, hiddenActivation);
            
            meanSquaredFinalError = finalError' * finalError;
            if ~isempty(obj.mustApplyBoldDriver) && obj.mustApplyBoldDriver && ~isempty(obj.previousError)
                obj.learningRate = obj.applyBoldDriver(obj.learningRate, meanSquaredFinalError, obj.previousError);
            end
            
            weightUpdate = obj.computeWeightUpdate(neuronOutputArray, invertedErrorArray);
            weightUpdate = obj.biasDampenWeightUpdate(weightUpdate);
            obj.neuralPathwayMatrix = obj.neuralPathwayMatrix + weightUpdate;
            
            obj.previousError = meanSquaredFinalError;
            
            if (~isempty(obj.tracer))
                obj.tracer.appendTraceValue('weights', full(obj.neuralPathwayMatrix));
%                 obj.tracer.appendTraceValue('output', outputArray);                
%                 obj.tracer.appendTraceValue('error', invertedErrorArray);
%                 obj.tracer.appendTraceValue('weightUpdate', weightUpdate);
%                 
            end
            
            % obj.zeroDiagonal();
        end
        
        function setMomentumFactor(obj, momentumFactor)
            obj.momentumFactor = momentumFactor;
        end
        
        function setMustApplyBoldDriver(obj, isTrue)
            obj.mustApplyBoldDriver = isTrue;
        end
        
        function learningRate = applyBoldDriver(obj, learningRate, currentError, previousError)
            if abs(currentError) < abs(previousError)
                learningRate = learningRate * 1.03;
            end
            
            if (abs(currentError) - .0001) > abs(previousError)
                learningRate = learningRate * .5;
            end
        end
        
        function output = activationFunction(obj, input)
            output = obj.kernel.activation(input);
            return;
        end
        
        function changeInOutput = derivativeActivationFunction(obj, input)
            changeInOutput = obj.kernel.derivative(input);
            return;
        end
        
        function input = inverseActivationFunction(obj, output)
            input = obj.kernel.inverseActivation(output);
            return;
        end
        
        function [outputArray activationArray] = produceOutput(obj, currentState)            
            outputArray     = cell(obj.recursionDepth, 1);
            activationArray = cell(obj.recursionDepth + 1, 1);
            activationArray{1} = currentState;
            if (~isempty(obj.fixedInputNodes))
                fixedInput = currentState(obj.fixedInputNodes);
            end
            inputCount = size(currentState,1);
            
            activationArrayFun = @(f, networkInput) arrayfun(f, full(networkInput));   
            if (obj.activationFunction(0) == 0)
                activationArrayFun = @spfun;
            end
            
            for i = 1:obj.recursionDepth
                % input needs ones to include the threshold
                preparedInput = sparse([ ones(inputCount, 1) currentState]);

                networkInput = preparedInput * obj.neuralPathwayMatrix;
                
                if ~isempty(obj.outputDampening)
                    networkInput = repmat(obj.outputDampening(i, :), size(networkInput, 1),1 ) .* networkInput;
                end
                
                if ~isempty(obj.tracer) && size(preparedInput, 1) == 1
                    obj.tracer.appendTraceValue('weightOutput', obj.tracer.componentMultiplication(preparedInput, obj.neuralPathwayMatrix));
                end
                
                outputArray{i} = networkInput;
                currentState = obj.activationFunction(networkInput);

                if ~isempty(obj.outputDampening)
                    currentState = repmat(obj.outputDampening(i, :), size(currentState, 1),1 ) .* currentState;
                end
                
                if (~isempty(obj.fixedInputNodes))
                    currentState(obj.fixedInputNodes) = fixedInput;
                end
                activationArray{1 + i} = currentState;
                % currentState = activationArrayFun(@(x) obj.activationFunction(x), networkInput);
            end
        end
        
        function finalOutput = produceFinalOutput(obj, input)
            output = obj.produceOutput(input);
            
            finalOutput = cellfun(@(v) obj.kernel.activation(v), output, 'UniformOutput', false);
            
            if isempty(obj.outputDampening)
                return;
            end
            
            for i = 1:length(finalOutput)
                finalOutput{i} = repmat(obj.outputDampening(i, :), size(finalOutput{i}, 1),1 ) .* finalOutput{i};
            end
        end
        
        function invertedErrorArray = backpropagateError(obj, outputArray, finalError)
            % output - error = correct
            % output = correct + error
            % output - correct = error
            % ->
            % invert(output) - invert(correct) = invert(error)
            
            activationArrayFun = @(f, networkInput) arrayfun(f, full(networkInput));   
            if (obj.activationFunction(0) == 0)
                activationArrayFun = @spfun;
            end
            
            derivativeArrayFun = @(f, networkInput) arrayfun(f, full(networkInput));   
            if (obj.derivativeActivationFunction(0) == 0)
                derivativeArrayFun = @spfun;
            end
            
            invertedErrorArray = cell(obj.recursionDepth, 1);
            currentError = finalError;
             
            for i = obj.recursionDepth:-1:1
                networkOutput = outputArray{i};
                % invertedOutput  = sparse(inverseActivationArrayFun(@(v) obj.inverseActivationFunction(v), output));
                % invertedCorrect = arrayfun(@(v) obj.inverseActivationFunction(v), correct);
                invertedError   = obj.derivativeActivationFunction(networkOutput) .* currentError;
                % invertedError   = sparse(derivativeArrayFun(@(v) obj.derivativeActivationFunction(v), networkOutput)) .* currentError;
                 
                invertedErrorArray{i} = invertedError;
                
                if i == 1
                    continue;
                end
                % previousOutput = activationArrayFun(@(networkOutput) obj.activationFunction(networkOutput), outputArray{i - 1});
                
                % commented previous version that I think contains a bug
                % because it does not backpropagate the error.
                % currentError = sparse(previousOutput * obj.neuralPathwayMatrix');
                
                % start of hypothetical bugfix
                currentError = sparse(invertedError * obj.neuralPathwayMatrix');
                currentError = currentError(:, 2:end) .* repmat(obj.outputDampening(i - 1, :), size(currentError, 1), 1);
                % end of hypothetical bugfix
                
                if ~isempty(obj.tracer) && size(previousOutput, 1) == 1
                    previousOutput = obj.activationFunction(outputArray{i - 1});                
                    obj.tracer.appendTraceValue('weightError', (obj.tracer.componentMultiplication(previousOutput, obj.neuralPathwayMatrix')') .^2);
                end
                
                % currentError = currentError(:, 2:end);
            end
        end
        
        
        function [neuronImportance, weightImportance] = determineImportance(obj, inputSet)
            outputArray = obj.produceOutput(inputSet);
            
            [neuronImportance, weightImportance] = obj.backpropagateImportance({inputSet outputArray{:}});
        end
        
        function [neuronImportance, weightImportance] = backpropagateImportance(obj, outputArray)

            importanceDilutedInBiasInput = 0;
            totalNeuronImportance = 0;
            
            absoluteOutputArray = cellfun(@abs, outputArray, 'UniformOutput', false);
            absoluteMatrix = abs(obj.neuralPathwayMatrix);
            
            neuronImportance = zeros(1, size(obj.neuralPathwayMatrix, 2));
            weightImportance = zeros(size(obj.neuralPathwayMatrix));
            
            exampleCount = length(outputArray{1}(:,1));
            for exampleIndex = 1:exampleCount;
            
                currentImportance = zeros(1,size(absoluteMatrix, 2));
                currentImportance(1,1) = 1;
                
                for i = obj.recursionDepth:-1:1
                    
                    exampleInput = absoluteOutputArray{i}(exampleIndex, :);
                    
                    if i ~= 1
                        exampleInput = obj.activationFunction(exampleInput);
                        exampleInput = exampleInput .* obj.outputDampening(i - 1, :);
                    end
                    
                    preparedExampleInput = [1 exampleInput]';
                    outputWeightedAbsoluteMatrix = repmat(preparedExampleInput, 1, length(exampleInput)) .* absoluteMatrix;
                    
                    sumAbsoluteWeightedOutput = sum(outputWeightedAbsoluteMatrix, 1);
                    
                    relativeImportanceMatrix = outputWeightedAbsoluteMatrix ./ repmat(sumAbsoluteWeightedOutput, length(sumAbsoluteWeightedOutput) + 1, 1);
                    relativeImportanceMatrix(isnan(relativeImportanceMatrix)) = 0;  % if the sumAbsoluteWeightedOutput == 0 then there is no output so no node is important. 
                    relativeImportanceMatrix = relativeImportanceMatrix .* repmat(obj.outputDampening(i,:), size(relativeImportanceMatrix, 1),1);
                    % @TODO: does currentImportance assure that the bias
                    % weight is weighted correctly?
                    weightImportance = weightImportance + relativeImportanceMatrix .* repmat(currentImportance, size(relativeImportanceMatrix, 1), 1);
                    backPropagatedImportance = currentImportance * relativeImportanceMatrix';
                    
                    if i == 1 
                        outputDampenAllButInputNodes = zeros(size(obj.outputDampening(i, :)));
                        outputDampenAllButInputNodes(obj.inputNodes) = 1;
                        importanceDilutedInBiasInput = importanceDilutedInBiasInput + sum(backPropagatedImportance(:, 1));
                        currentImportance = backPropagatedImportance(:, 2:end) .* repmat(outputDampenAllButInputNodes, size(backPropagatedImportance, 1), 1);
                        totalNeuronImportance = totalNeuronImportance + sum(currentImportance);

                        neuronImportance = neuronImportance + currentImportance;
                        continue;
                    end
                    importanceDilutedInBiasInput = importanceDilutedInBiasInput + sum(backPropagatedImportance(:, 1));
                    currentImportance = backPropagatedImportance(:, 2:end) .* repmat(obj.outputDampening(i - 1, :), size(backPropagatedImportance, 1), 1);
                    totalNeuronImportance = totalNeuronImportance + sum(currentImportance);
                    
                    neuronImportance = neuronImportance + currentImportance;
                    
                end
            end
            
            neuronImportance = neuronImportance / totalNeuronImportance;
            weightImportance = weightImportance / sum(sum(weightImportance));% ( obj.recursionDepth * exampleCount);
        end
        
        
        function influenceArray = backpropagateInfluence(obj, outputArray)
            % output - error = correct
            % output = correct + error
            % output - correct = error
            % ->
            % invert(output) - invert(correct) = invert(error)
            
            
            influenceArray = cell(obj.recursionDepth, 1);
            currentInfluence = zeros(size(outputArray{end}));
            currentInfluence(1, 1) = 1;
             
            for i = obj.recursionDepth:-1:1
                networkOutput = outputArray{i};
                % invertedOutput  = sparse(inverseActivationArrayFun(@(v) obj.inverseActivationFunction(v), output));
                % invertedCorrect = arrayfun(@(v) obj.inverseActivationFunction(v), correct);
                invertedInfluence   = obj.derivativeActivationFunction(networkOutput) .* currentInfluence;
                % invertedError   = sparse(derivativeArrayFun(@(v) obj.derivativeActivationFunction(v), networkOutput)) .* currentError;
                 
                influenceArray{i} = invertedInfluence;
                
                if i == 1
                    continue;
                end
                % previousOutput = activationArrayFun(@(networkOutput) obj.activationFunction(networkOutput), outputArray{i - 1});
                
                % commented previous version that I think contains a bug
                % because it does not backpropagate the error.
                % currentError = sparse(previousOutput * obj.neuralPathwayMatrix');
                
                % start of hypothetical bugfix
                currentInfluence = sparse(invertedInfluence * abs(obj.neuralPathwayMatrix)');
                currentInfluence = currentInfluence(:, 2:end) .* repmat(obj.outputDampening(i - 1, :), size(currentInfluence, 1), 1);
                % end of hypothetical bugfix
                
                
            end
        end
                
        function weightUpdate = computeWeightUpdate(obj, neuronOutputArray, invertedErrorArray)
            
            learningRate = obj.learningRate;
            
            if obj.learningRateIsBatchSizeAdapted 
                learningRate = obj.learningRate / size(neuronOutputArray{1}, 1);
            end

            
            weightUpdate = sparse(size(obj.neuralPathwayMatrix, 1), size(obj.neuralPathwayMatrix, 2));
            
            for i = 1:length(invertedErrorArray)
                weightUpdate = weightUpdate - learningRate * sparse(sparse([ones(size(neuronOutputArray{i}, 1), 1) neuronOutputArray{i}]') * invertedErrorArray{i});
            end            
            weightUpdate = sparse(weightUpdate);
            
            if ~isempty(obj.momentumFactor) && ~isempty(obj.previousWeightUpdate)
                weightUpdate = (weightUpdate * (1 - obj.momentumFactor)) + obj.previousWeightUpdate * obj.momentumFactor;
            end
            obj.previousWeightUpdate = weightUpdate;
            
        end
        
        function dampenedWeightUpdateArray = biasDampenWeightUpdate(obj, weightUpdate)

            % dampeningFactorArray = obj.neuralPathwayMatrix .^2 ;
            
            dampenedWeightUpdateArray = sparse(obj.dampeningMatrix .* weightUpdate);
            
        end
        % precondition: fromIndex must always be an input nodes
        function connect(obj, fromIndex, toIndex, effect)
            if (isempty(obj.addedConnectionCount))
                obj.addedConnectionCount = 0;
            end
            obj.addedConnectionCount = obj.addedConnectionCount + length(fromIndex) * length(toIndex);
            obj.dampeningMatrix(fromIndex + 1, toIndex)     = 1;
            obj.neuralPathwayMatrix(fromIndex + 1, toIndex) = effect;
            
            obj.outputDampening = obj.initPathwayOutputDampening(obj.dampeningMatrix(2:end, :), obj.inputNodes);            
        end


    end
    
end

