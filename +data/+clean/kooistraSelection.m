function [ output_args ] = kooistraDreamSelection( zScoreCuttof, sensitivityData )
%KOOISTRASELECTION Summary of this function goes here
%   Detailed explanation goes here

    onlyQAOne = sensitivityData(sensitivityData.qa == 1, :)
    
    moderateHillSlope = onlyQAOne(onlyQAOne.hillSlope > .1 & onlyQAOne.hillSlope < 10, :);
    
    onlyEffectiveDrugs = moderateHillSlope(moderateHillSlope.einf <= 80, :);
    
    [groupId, cellLine, drug] = findgroups(onlyEffectiveDrugs.cellLine, onlyEffectiveDrugs.drug);
    
    selectedIc50 = splitapply(@(v)...
        median(...
            data.clean.iterativeZScoreFilter(zScoreCuttoff, v)...
        ...), onlyEffectiveDrugs.pIc50, groupId);

end

