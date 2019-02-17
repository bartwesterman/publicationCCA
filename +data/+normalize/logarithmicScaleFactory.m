function scaleFunction = logarithmicScaleFactory( vector )
%LOGARITHMICSCALE Summary of this function goes here
%   Detailed explanation goes here
    maxi = max(vector);
    mini = min(vector);

    scale = maxi - mini;
    if (scale == 0)
        scaleFunction = @(v) .5;
        return;
    end
    
    scaleFunction = @(v) log(v - mini + 1)/ log(scale + 1);
end

