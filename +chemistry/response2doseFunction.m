function doseFunction = response2doseFunction(params)
%RESPONSE2DOSEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    % doseFunction = @(response) log(params.ic50) - ( log(((params.maxVal - params.minVal) / (response - params.minVal)) - 1 ) / params.hillSlope);
    
    % probably correct:
    % doseFunction = @(response) params.ic50 * ((params.maxVal - params.minVal) / (response - params.minVal)) ^ (-1 / params.hillSlope);
    doseFunction = @(response) params.ic50 / ( ( ((params.minVal - 100) / (response - 100) ) - 1 ) ^ (1 / params.hillSlope));
end

