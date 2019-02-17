function theDeepCopy = deepCopy( theOriginal )
%DEEPCOPY Summary of this function goes here
%   Detailed explanation goes here

    theDeepCopy = getArrayFromByteStream( getByteStreamFromArray( theOriginal));
end

