function values = iterativeZScoreFilter( zCutoff, values )
%ITERATIVEZSCOREFILTER Summary of this function goes here
%   Detailed explanation goes here

    while (true)
        m    = mean(values);
        oneZ = std(values);

        zScore = abs((values - m) ./oneZ);
        valueCountBeforeFilter = length(values);
        values = values(zScore < zCutoff); 
        valueCountAfterFilter = length(values);
        
        if (valueCountBeforeFilter == valueCountAfterFilter)
            return;
        end
    end
    
end

