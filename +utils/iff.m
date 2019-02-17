function v = iff( condition, ifTrue, ifFalse )
    %IF Summary of this function goes here
    %   Detailed explanation goes here
    
    if (condition)
        v = ifTrue;
        return;
    end
    
    v = ifFalse;
end

