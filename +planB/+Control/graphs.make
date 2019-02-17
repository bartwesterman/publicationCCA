include +planB/+Control/config.make

ifeq ($(TARGET), synergy)
	RELEVANT_FEATURE_COUNT = 5000
	GOOD_FEATURE_COUNT = 500
	BEST_FEATURE_COUNT = 65
endif

ifeq (${TARGET}, lethality)
	RELEVANT_FEATURE_COUNT = 500
	GOOD_FEATURE_COUNT = 250
	BEST_FEATURE_COUNT = 150
endif



createRandomForestReductionGraphs: $(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceOverview.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceGoodZone.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceBestZone.png $(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistribution.png $(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistributionHighImportance.png $(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png $(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetrics.png $(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetricsScaled.png $(DATAPATH)randomForestReductionGraphs/cummulativeTypeImportance.png

createNeuralNetworkGraphs: $(DATAPATH)neuralNetworkGraphs/results.png $(DATAPATH)neuralNetworkGraphs/results2.png

createSVMGraphs: $(DATAPATH)supportVectorMachineGraphs/results.png

createAllGraphs: createRandomForestReductionGraphs createNeuralNetworkGraphs createSVMGraphs createConvertedNeuralNetworkGraphs createConvertedSVMGraphs

$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetrics.png $(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetricsScaled.png:
	$(MATLAB) "planB.Control.createGraphTreeCountVsPerformanceMetrics('$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetrics.png', '$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetricsScaled.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png:
	$(MATLAB) "planB.Control.createGraphTreeCountChangeAndRankCorrelation( '$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistributionHighImportance.png:
	$(MATLAB) "planB.Control.createGraphTreeCountVsImportanceDistributionHighImportance('$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistributionHighImportance.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistribution.png:
	$(MATLAB) "planB.Control.createGraphTreeCountVsImportanceDistribution('$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistribution.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceOverview.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceGoodZone.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceBestZone.png:
	$(MATLAB) "planB.Control.createGraphBestRandomForest('$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceOverview.png', '$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceRelevantZone.png', '$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceGoodZone.png', '$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceBestZone.png', '$(DATAPATH)randomForestReductionResults/', $(RELEVANT_FEATURE_COUNT), $(GOOD_FEATURE_COUNT), $(BEST_FEATURE_COUNT)); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png:
	$(MATLAB) "planB.Control.createGraphTreeCountChangeAndRankCorrelation( '$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/cummulativeTypeImportance.png:
	$(MATLAB) "planB.Control.createGraphCummulativeTypeImportance( '$(DATAPATH)bestReduction.mat', '$(DATAPATH)randomForestReductionGraphs/cummulativeTypeImportance.png', '$(DATAPATH)randomForestReductionGraphs/cummulativeTypeCount.png', $(BEST_ENTITY_COUNT)); exit;"


$(DATAPATH)neuralNetworkGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)neuralNetworkResults/', '$(DATAPATH)neuralNetworkGraphs/pearsonResults.png', '$(DATAPATH)neuralNetworkGraphs/weightedPearsonResults.png'); exit;"

$(DATAPATH)neuralNetworkGraphs/results2.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)neuralNetworkResultsAfterRegression/', '$(DATAPATH)neuralNetworkGraphsAfterRegression/pearsonResults.png', '$(DATAPATH)neuralNetworkGraphsAfterRegression/weightedPearsonResults.png'); exit;"


$(DATAPATH)supportVectorMachineGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphSVMResults('$(DATAPATH)supportVectorMachineResults/', '$(DATAPATH)supportVectorMachineGraphs/pearsonResults.png', '$(DATAPATH)supportVectorMachineGraphs/weightedPearsonResults.png'); exit;"

ifeq (${TARGET}, dexpected)

createConvertedNeuralNetworkGraphs: $(DATAPATH)convertedNeuralNetworkGraphs/results.png $(DATAPATH)convertedNeuralNetworkGraphs/results2.png

$(DATAPATH)convertedNeuralNetworkGraphs/results2.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)convertedNeuralNetworkResultsAfterRegression/', '$(DATAPATH)convertedNeuralNetworkGraphsAfterRegression/pearsonResults.png', '$(DATAPATH)convertedNeuralNetworkGraphsAfterRegression/weightedPearsonResults.png'); exit;"

$(DATAPATH)convertedNeuralNetworkGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)convertedNeuralNetworkResults/', '$(DATAPATH)convertedNeuralNetworkGraphs/pearsonResults.png', '$(DATAPATH)convertedNeuralNetworkGraphs/weightedPearsonResults.png'); exit;"

createConvertedSVMGraphs: $(DATAPATH)convertedSupportVectorMachineGraphs/results.png

$(DATAPATH)convertedSupportVectorMachineGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphSVMResults('$(DATAPATH)convertedSupportVectorMachineResults/', '$(DATAPATH)convertedSupportVectorMachineGraphs/pearsonResults.png', '$(DATAPATH)convertedSupportVectorMachineGraphs/weightedPearsonResults.png'); exit;"
else
ifeq (${TARGET}, lethality)

createConvertedNeuralNetworkGraphs: $(DATAPATH)convertedNeuralNetworkGraphs/results.png $(DATAPATH)convertedNeuralNetworkGraphs/results2.png

$(DATAPATH)convertedNeuralNetworkGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)convertedNeuralNetworkResults/', '$(DATAPATH)convertedNeuralNetworkGraphs/pearsonResults.png', '$(DATAPATH)convertedNeuralNetworkGraphs/weightedPearsonResults.png'); exit;"

$(DATAPATH)convertedNeuralNetworkGraphs/results2.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)convertedNeuralNetworkResultsAfterRegression/', '$(DATAPATH)convertedNeuralNetworkGraphsAfterRegression/pearsonResults.png', '$(DATAPATH)convertedNeuralNetworkGraphsAfterRegression/weightedPearsonResults.png'); exit;"



createConvertedSVMGraphs: $(DATAPATH)convertedSupportVectorMachineGraphs/results.png

$(DATAPATH)convertedSupportVectorMachineGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphSVMResults('$(DATAPATH)convertedSupportVectorMachineResults/', '$(DATAPATH)convertedSupportVectorMachineGraphs/pearsonResults.png', '$(DATAPATH)convertedSupportVectorMachineGraphs/weightedPearsonResults.png'); exit;"

else


createConvertedNeuralNetworkGraphs:

createConvertedSVMGraphs:
endif
endif

