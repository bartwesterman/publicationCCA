function s = toString( v )
%TOSTRING Summary of this function goes here
%   Detailed explanation goes here
    if isnumeric(v) || islogical(v)
        s = num2str(v);
        return;
    end
    
    if isstring(v) || ischar(v)
        s = v;
        return
    end
end

