function numbers = roundToMostSignificantNumbers( numbers, significantNumberCount )
%MOSTSIGNIFICANTNUMBERS Summary of this function goes here
%   Detailed explanation goes here
    highestNumber = max(numbers);
    digitCountHighestNumber = ceil(log10(highestNumber));
    requiredDigitShift = significantNumberCount - digitCountHighestNumber;

    digitShiftFactor = 10 ^ (requiredDigitShift);
    
    numbers = round(numbers * digitShiftFactor) / digitShiftFactor;
end

