function createGraphBestRandomForest(fullGraphFilePath, relevantZoneGraphFilePath, goodZoneGraphFilePath, bestZoneGraphFilePath, randomForestResultsPath, relevantZoneImportantEntityIdCount, goodZoneImportantEntityIdCount, bestZoneImportantEntityIdCount)
    
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
    
    createAndSaveGraph('relevant zone of importance of predictors', 'importance rank predictor', 'importance', importances(1:relevantZoneImportantEntityIdCount), relevantZoneGraphFilePath);

    createAndSaveGraph('good zone of importance of predictors', 'importance rank predictor', 'importance', importances(1:goodZoneImportantEntityIdCount), goodZoneGraphFilePath);

    createAndSaveGraph('best zone of importance of predictors', 'importance rank predictor', 'importance', importances(1:bestZoneImportantEntityIdCount), bestZoneGraphFilePath);
end