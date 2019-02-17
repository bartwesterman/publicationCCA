function combinationIndex = doseBasedSynergy( doseXDeadA, doseXDeadB, partAXDead, partBXDead  )
%DOSEBASEDSYNERGY Summary of this function goes here
%   Detailed explanation goes here

    combinationIndex = partAXDead / doseXDeadA + partBXDead / doseXDeadB;
end

