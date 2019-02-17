function doseResponseFunction = fitDoseResponseFunction( dataPoints )
%FITDOSERESPONSEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    % bottom = min(dataPoints(:, 2));
    % unboundFunction = @(ec50, hillSlope, x) (((x / ec50) .^ -hillSlope + 1) .^ -1) * (100 - bottom) + bottom;
    unboundFunction = @(bottom, ec50, hillSlope, x) (((x / ec50) .^ hillSlope + 1) .^ -1) * (100 - bottom) + bottom;
    
    % unboundFunction = @(bottom, ec50, hillSlope, x) ((10.^(((log(ec50)/log(10))      - x) * hillSlope) + 1) .^ -1) * (100 - bottom) + bottom;
    % unboundFunction = @(params, x) params(1) + ( (100 - params(1)) / ( 1 + 10^((log(params(2)) - x) * params(3))));

    params0 = [30, .1 .1];
    lower   = [0, 0, -Inf];
    upper   = [100, Inf, Inf];
    [boundParams,resnorm,~,exitflag,output] = fit(dataPoints(:, 1), dataPoints(:, 2), unboundFunction, 'Start', params0, 'Lower', lower, 'Upper', upper);
    
    doseResponseFunction = @(dose) unboundFunction(boundParams.ec50, boundParams.hillSlope, dose);
    
end

