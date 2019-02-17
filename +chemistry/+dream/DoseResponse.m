classdef DoseResponse < handle
    %DOSERESPONSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        top;
        bottom;
        hillSlope;
        ec50;
    end
    
    methods
        
        function obj = init(obj, dataPoints)
            params = obj.fitDoseResponseFunction(dataPoints);
            obj.hillSlope = params.hillSlope;
            obj.ec50      = params.ec50;
            obj.bottom    = 0;
            obj.top       = 100 - params.bottom;
            
        end
        
        function boundParams = fitDoseResponseFunction(obj, dataPoints)
        %FITDOSERESPONSEFUNCTION Summary of this function goes here
        %   Detailed explanation goes here

            % bottom = min(dataPoints(:, 2));
            % unboundFunction = @(ec50, hillSlope, x) (((x / ec50) .^ -hillSlope + 1) .^ -1) * (100 - bottom) + bottom;
            unboundFunction = @(bottom, ec50, hillSlope, x) (((x / ec50) .^ hillSlope + 1) .^ -1) * (100 - bottom) + bottom;

            % unboundFunction = @(bottom, ec50, hillSlope, x) ((10.^(((log(ec50)/log(10))      - x) * hillSlope) + 1) .^ -1) * (100 - bottom) + bottom;
            % unboundFunction = @(params, x) params(1) + ( (100 - params(1)) / ( 1 + 10^((log(params(2)) - x) * params(3))));

            params0 = [30, 1 .1];
            lower   = [0, 0, 0];
            upper   = [100, max(dataPoints(:, 1)), 10];
            
            boundParams = fit(dataPoints(:, 1), dataPoints(:, 2), unboundFunction, 'Start', params0, 'Lower', lower, 'Upper', upper);
            % doseResponseFunction = @(dose) unboundFunction(boundParams.ec50, boundParams.hillSlope, dose);
        end
        
        function partial = predictPartial(obj, x, y)
            ef1 = (y - obj.bottom) / (obj.top - y);
            
            if ef1 < 0
                partial = 0;
                return
            end
            
            partial = x / (obj.ec50 * sign(ef1) * (abs(ef1) .^ (1 / obj.hillSlope)));
            
        end
        
        function resp = sample(obj, dose)
            resp = obj.bottom...
                + (obj.top - obj.bottom)...
                / (1 + 10 .^...
                            (...
                                (log(obj.ec50) / log(10) - log(dose) / log(10)) *...
                                obj.hillSlope...
                            )...
                  );
                
        end
    end
    
end

