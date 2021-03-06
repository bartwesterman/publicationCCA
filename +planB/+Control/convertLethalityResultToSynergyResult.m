function synergyResult = convertLethalityResultToSynergyResult(lethalityResultFilePath, lethalityTestSetFilePath, synergyTestSetFilePath, convertedResultFilePath)
%CONVERTLETHALITYRESULTTOSYNERGY Summary of this function goes here
%   Detailed explanation goes here
    function exampleSet = loadExampleSet(filePath)
        load(filePath, 'exampleSet');
    end

    function result = loadResult(filePath)
        load(filePath, 'result');
    end

    function saveResult(filePath, result)
        utils.assurePathFor(filePath);
        save(filePath, 'result', '-v7.3');
    end

    result = loadResult(lethalityResultFilePath);
    
    lethalityTestSet = loadExampleSet(lethalityTestSetFilePath);
    synergyTestSet   = loadExampleSet(synergyTestSetFilePath);
    
    synergyPredictions = zeros(length(synergyTestSet.exampleIds), 1);
    for i = 1:size(synergyTestSet.exampleIds, 1)
        exampleId = synergyTestSet.exampleIds(i);
        exampleIdSubSet = lethalityTestSet.getSubExampleSetByExampleIds(exampleId);
        
        label = lethalityTestSet.entityManager.get('exampleId').getCanonicalLabel(exampleId);
        tokenizedLabel = strsplit(label, '@');
        
        cellLineName = tokenizedLabel{1};
        drugAName = tokenizedLabel{2};
        drugBName = tokenizedLabel{3};
        
        cellLineId = lethalityTestSet.entityManager.get('cellLine').getId(cellLineName);
        drugAId    = lethalityTestSet.entityManager.get('drug').getId(drugAName);
        drugBId    = lethalityTestSet.entityManager.get('drug').getId(drugBName);
        
        drugALevels = exampleIdSubSet.getLevels(drugAId);
        drugBLevels = exampleIdSubSet.getLevels(drugBId);
        
        deathRateMatrix = zeros(size(drugALevels, 1), size(drugBLevels, 1));
        survivalRateMatrix = zeros(size(drugALevels, 1), size(drugBLevels, 1));
        
        for x = 1:size(drugALevels, 1)
        for y = 1:size(drugBLevels, 1)    
            row = exampleIdSubSet.getExamplesByAttributesWithExactValue([drugAId; drugBId], [drugALevels(x, 1); drugBLevels(y, 1)]);
            deathRate = result.learner.predict(row.getInput());
            deathRateMatrix(x, y) = deathRate; % for debugging
            survivalRateMatrix(x, y) = 100 - deathRate * 100;
        end
        end
        synergyPredictions(i) = combenefit.doseMatrixToSynergyScore(drugALevels, drugBLevels, survivalRateMatrix);
    end

    convertedResult = synergyTestSet.analyzePerformance(synergyPredictions);
    convertedResult.learner = result.learner;
    convertedResult.adjustedR2 = NaN; % adjusted r2 is not correct
    
    saveResult(convertedResultFilePath, convertedResult);
    
end

