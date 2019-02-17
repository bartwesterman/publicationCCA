function v = orDefault( a, b )
%OR Summary of this function goes here
%   Detailed explanation goes here

    if (~isempty(a))
        v = a;
        return;
    end
    
    if (~isempty(b))
        v = b;
        return;
    end
    
    v = false;
end

