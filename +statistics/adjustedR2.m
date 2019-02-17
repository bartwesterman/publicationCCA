function v = adjustedR2( output, correct, explanatoryVariableCount )
%ADJUSTEDR2 Summary of this function goes here
%   Detailed explanation goes here
    r2 = statistics.r2(output, correct);
    
    sampleCount = length(output);
    v = r2 - ((1 - r2) * explanatoryVariableCount) / (sampleCount - explanatoryVariableCount - 1);
end

