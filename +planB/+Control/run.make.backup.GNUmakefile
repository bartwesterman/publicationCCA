include compile.make

HACK = $(shell module load matlab/2016a)


TARGET = synergy

DATAPATH = ./output/results/$(target)/

ifdef TEST
DATAPATH = ./output/test/$(target)/
DATASOURCE = $(DATAPATH)testDataSource.mat
endif




finalResult: $(DATAPATH)finalResult.mat

$(DATAPATH)finalResult.mat : combineAnalysisResults $(DATAPATH)analysisResults/%.mat
    ./combineAnalysisResults ./combinedResults.mat $(DATAPATH)analysisResults/%.mat


$(DATAPATH)neuralNetworkResults/%.mat : runNeuralNetworkTask $(DATAPATH)neuralNetworkTasks/%.mat
    runNeuralNetworkTask $(DATAPATH)neuralNetworkTasks/%.mat $(DATAPATH)reducedExampleSet.mat

$(DATAPATH)neuralNetworkTasks/%.mat : createNeuralNetworkTasks $(DATAPATH)reducedExampleSet.mat

    createNeuralNetworkTasks $(DATAPATH)reducedExampleSet.mat


$(DATAPATH)reducedExampleSet.mat : reduceExampleSet $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat
    reduceExampleSet $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat

$(DATAPATH)combinedDimensionReductions.mat : combineDimensionReductions $(DATAPATH)dimensionReductionResults/%.mat
    combineDimensionReductions ./$(DATAPATH)randomForestReductionResults/

$(DATAPATH)randomForestReductionResults/%.mat : runRandomForestReductionTask $(DATAPATH)randomForestReductionTasks/%.mat
    runDimensionReductionTask $(DATAPATH)randomForestReductionReductionTasks/%.mat $(DATAPATH)randomForestReductionResults/%.mat

$(DATAPATH)randomForestReductionTasks/%.mat : createRandomForestTasks $(DATAPATH)exampleSetWithoutCellLineIds.mat
    createRandomForestTasks exampleSetWithoutCellLineIds.mat $(DATAPATH)randomForestReductionTasks/

$(DATAPATH)exampleSetWithoutCellLineIds.mat : removeCellLineIdsFromExampleSet $(DATAPATH)exampleSet.mat
    removeCellLineIdsFromExampleSet $(DATAPATH)exampleSet.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat

$(DATAPATH)exampleSet.mat: prepareFullExampleSet $(DATASOURCE)
	prepareFullExampleSet $(DATASOURCE)
