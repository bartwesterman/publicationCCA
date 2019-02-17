function networkOutput = tanh( networkInput )
%TANH Summary of this function goes here
%   Detailed explanation goes here

    networkOutput = -1 + 2 * ( 1 + exp(-2 * networkInput)) .^ -1;
end

