function [ output_args ] = explainingImprovementOfAggregatedPerformance( input_args )
%EXPLAININGIMPROVEMENTOFAGGREGATEDPERFORMANCE Summary of this function goes here
%   Detailed explanation goes here

    % put some pattern in an array named reality
    reality = zeros(2200,36);
    reality = ((1:size(reality,1)) * 40)' * ones(1,size(reality,2)) + ones(size(reality,1), 1) * (1:size(reality,2));
    
    % distort the pattern with random values in an array named
    % measuredReality
    measuredReality = reality + (600000 * rand(size(reality)) - 300000);
    
    % scale all values down to values that create nice graphs
    toScale = 100 / (max(measuredReality(:)) - min(measuredReality(:)));
    lowest  = min(measuredReality(:));
    reality         = (reality - lowest) * toScale;
    measuredReality = (measuredReality - lowest) * toScale;
    
    % aggregate those values
    aggregatedReality = mean(reality,2);
    
    
    
    % aggregate values of measuredReality through a mean
    aggregatedMeasuredReality = mean(measuredReality,2);
    
    unAggregatedCorrelation = corr(reality(:), measuredReality(:));
    aggregatedCorrelation   = corr(aggregatedReality, aggregatedMeasuredReality);

    fontSize = 30;
    figure;
    surface(reality,'edgecolor','none');
    title('reality');
    set(gca, 'FontSize', fontSize);
    xlabel('dose combinations', 'FontSize', fontSize);
    ylabel('experiments', 'FontSize', fontSize );    
    
    xticks([1 36]);
    yticks([1 2200]);
    zticks([0 25 50 75 100]);   
    axis([0 36 0 2200 0 100]);
    
    zlabel('the real value', 'FontSize', fontSize);    
    view(38,41);
    figure;    
    surface(measuredReality,'edgecolor','none');
    title('measured reality');
    
    set(gca, 'FontSize', fontSize);
    xlabel('dose combinations', 'FontSize', fontSize);
    ylabel('experiments', 'FontSize', fontSize);    
    xticks([1 36]);
    yticks([1 2200]);    
    zticks([0 25 50 75 100]);    
    axis([0 36 0 2200 0 100]);
    
    zlabel('the measured value', 'FontSize', fontSize);    
    view(38,41);
    
    figure;
    
    hold on;
    
    plot(aggregatedMeasuredReality,'LineWidth',4);
    plot(aggregatedReality,'LineWidth',9);
    t = title('measured and reality aggregated');

    l = legend('measured', 'real');
    set(l, 'FontSize', fontSize);
    set(t, 'FontSize', fontSize);
    
    set(l, 'Location', 'southeast');
    xlabel('the experiments', 'FontSize', fontSize);
    ylabel('the aggregated values', 'FontSize', fontSize);    
      
    set(gca, 'FontSize', fontSize);
    
    disp('unaggregated correlation of reality and measurement: ');
    disp(unAggregatedCorrelation);
    
    disp('aggregated correlation of reality and measurement: ');
    disp(aggregatedCorrelation);
    
end

