function scaleFunction = linearScaleFactory( vector )
%LINEARSCALE Summary of this function goes here
%   Detailed explanation goes here

    maxi = max(vector);
    mini = min(vector);

    scale = maxi - mini;

    if (scale == 0)
        scaleFunction = @(v) .5;
        return;
    end
    
    scaleFunction = @(v) (v - mini) / scale;
end
