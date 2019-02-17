function testPlotFitDoseResponseFunction( dataPoints )
%TESTPLOTFITDOSERESPONSEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    fittedDoseResponseFunction = chemistry.dream.fitDoseResponseFunction(dataPoints);
    
    figure;
    hold on;
    plot(dataPoints(:, 1), dataPoints(:, 2));
    output = fittedDoseResponseFunction(dataPoints(:, 1));
    plot(dataPoints(:, 1), output);
    hold off;
end

