function output = tanhDerivative( networkInput )
%TANHDERIVATIVE Summary of this function goes here
%   Detailed explanation goes here

    output =  -learning.activationFunctions.tanh(networkInput) .^ 2 + 1;
end

