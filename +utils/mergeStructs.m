function merged = mergeStructs( a, b )
%MERGESTRUCT Summary of this function goes here
%   Detailed explanation goes here

    import utils.mergeStructs;

    if ~isstruct(b)
        merged = b;
        return;
    end
    
    if ~isstruct(a)
        merged = b;
        return;
    end
    
    merged = a;
    fieldArrayB = fieldnames(b);
    fieldArrayBCount = size(fieldArrayB, 1);
    for i = 1:fieldArrayBCount
        field = fieldArrayB{i};

        if (~isfield(a, field))
            merged.(field) = b.(field);
            continue;
        end
        
        merged.(field) = mergeStructs(a.(field), b.(field));

    end
end

