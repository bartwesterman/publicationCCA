function map = createMap( keyFunc, array )
%CREATEMAP Summary of this function goes here
%   Detailed explanation goes here

    map = containers.Map;
    
    for i = 1:length(array)
        key = keyFunc(array(i));
        map(key) = array(i);
    end
end

