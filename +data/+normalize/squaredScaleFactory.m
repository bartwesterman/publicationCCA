function scaleFunction = squaredScaleFactory( vector )
%SQUAREDSCALEFACTORY Summary of this function goes here
%   Detailed explanation goes here

    vector = vector * -1;

    maxi = max(vector);
    mini = min(vector);

    scale = maxi - mini;

    % scaleFunction = @(v) (1/scale)^2 * (-v - mini)^2  ;

    if (scale == 0)
        scaleFunction = @(v) .5;
        return;
    end
    
    scaleFunction = @(v) ((v - mini) / scale)^2  ;
end

