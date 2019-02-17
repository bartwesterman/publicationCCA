function createGraphBestPerformer(fullGraphFilePath, goodZoneGraphFilePath, bestZoneGraphFilePath, randomForestResultsPath)
    
    bestResult = planB.Control.getBestPerformer(randomForestResultsPath);

    importances = bestResult.importance.importance;
    
    function createAndSaveGraph(titleString, xLabel, yLabel, data, filePath)
        f = figure;
        plot(data);
        title(titleString);
        xlabel(xLabel);
        ylabel(yLabel);
        saveas(f, filePath);
        
    end
    createAndSaveGraph('overview of importance of predictors', 'importance rank predictor', 'importance', importances, fullGraphFilePath);
    
    goodZoneImportantEntityIdCount = planB.Control.determineImportanceBoundry(importances, .01, .01);    
    createAndSaveGraph('good zone of importance of predictors', 'importance rank predictor', 'importance', importances(1:goodZoneImportantEntityIdCount), goodZoneGraphFilePath);

    bestZoneImportantEntityIdCount = planB.Control.determineImportanceBoundry(importances, .0000001, .089);
    createAndSaveGraph('best zone of importance of predictors', 'importance rank predictor', 'importance', importances(1:bestZoneImportantEntityIdCount), bestZoneGraphFilePath);
end