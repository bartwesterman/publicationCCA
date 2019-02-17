function num = toNumber( str )
%TONUMBER Summary of this function goes here
%   Detailed explanation goes here
    if (isstring(str) || ischar(str))
        num = str2num(str);
        return;
    end
    
    num = str;

end

