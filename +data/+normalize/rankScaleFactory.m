function scaleFunction = rankScaleFactory( vector )
%RANKSCALEFACTORY Summary of this function goes here
%   Detailed explanation goes here

    rankIndexCount = length(vector);
    sortedVector = sort(vector);
    
    valueToRankIndex = containers.Map();
    
    for i = 1:rankIndexCount
        valueToRankIndex(num2str(sortedVector(i))) = i;
    end
    
    scaleFunction = @(vect) arrayfun(@(val) (valueToRankIndex(num2str(val)) - 1) / (rankIndexCount - 1), vect);

end

