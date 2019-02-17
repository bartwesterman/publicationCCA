function stateHistory = simulate( simulationFunction, initialState, iterationCount )
%SIMULATE Summary of this function goes here
%   Detailed explanation goes here

    stateHistory = zeros(iterationCount + 1, length(initialState));

    stateHistory(1, :) = initialState;
    for i = 1:iterationCount
        stateHistory(i + 1, :) = simulationFunction(stateHistory(i, :));
        
    end
end

