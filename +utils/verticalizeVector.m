function verticalized = verticalizeVector( v )
%VERTICALIZEVECTOR Summary of this function goes here
%   Detailed explanation goes here
    verticalized = v;

    if (size(v, 1) == 1)
        verticalized = v';
    end
end

