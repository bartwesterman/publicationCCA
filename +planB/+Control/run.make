# include +planB/+Control/compile.make

# CONFIGURATION
# TARGET can also be lethality
TARGET = synergy

MATLAB = matlab -nodisplay -nodesktop -nosplash -r

DATAROOT   = ./output/results/
ifdef TEST
	DATAROOT   = ./output/test/
endif
DATAPATH   = $(DATAROOT)$(TARGET)/
DATASOURCE = $(DATAROOT)dataSource.mat

DREAMSYNERGYDATA = ./resources/correctedRawSources/ch1_train_combination_and_monoTherapy.csv
DREAMLETHALITYPATH = "~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/csv/Raw_Data_csv/ch1_training_combinations_csv/"
EXPRESSIONPATH = "~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/gex.csv"
MUTATIONPATH = "~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/mutations_corrected.csv"
SYNERGY_DATA_PATH = $(DATAROOT)synergy/
PATHWAYPATH = resources/pathways/all/
ifdef TEST

	DREAMSYNERGYDATA = ./+planB/+Control/+test/resources/testMakefiles/ch1_train_combination_and_monoTherapy.csv
	DREAMLETHALITYPATH = ./+planB/+Control/+test/resources/testMakefiles/combinations/
	EXPRESSIONPATH = "./+planB/+Control/+test/resources/testMakefiles/gex.csv"
	MUTATIONPATH = "./+planB/+Control/+test/resources/testMakefiles/mutations_corrected.csv"
	PATHWAYPATH = resources/pathways/test/
else
	TEST = false
endif
# TARGET SPECIFIC MAKE RULES
ifeq ($(TARGET), synergy)
EXAMPLEDATA = $(DATAPATH)dreamSynergyData.mat
$(EXAMPLEDATA): $(DATASOURCE)
	$(MATLAB) "planB.Control.createDreamSynergyData('$(DATASOURCE)', '$(DREAMSYNERGYDATA)', '$(EXAMPLEDATA)'); exit;"


$(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat
	$(MATLAB) "planB.Control.splitSynergyExampleSet('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(DATAPATH)trainingSet.mat', '$(DATAPATH)testSet.mat'); exit;"
endif

ifeq (${TARGET}, lethality)
EXAMPLEDATA = $(DATAPATH)dreamLethalityData.mat
$(EXAMPLEDATA): $(DATASOURCE)
	$(MATLAB) "planB.Control.createDreamLethalityData('$(DATASOURCE)', '$(DREAMLETHALITYPATH)', '$(DREAMSYNERGYDATA)', '$(EXAMPLEDATA)'); exit;"

$(DATAPATH)fullTrainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat $(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat
	$(MATLAB) "planB.Control.mirrorExampleSetSplit('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(SYNERGY_DATA_PATH)trainingSet.mat', '$(SYNERGY_DATA_PATH)testSet.mat', '$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)testSet.mat');exit;"

$(DATAPATH)trainingSet.mat: $(DATAPATH)fullTrainingSet.mat
	$(MATLAB) "planB.Control.randomSubSet('$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)trainingSet.mat', '1000');exit;"


$(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat:
	make -j -f +planB/+Control/run.make TEST=$(TEST) TARGET=synergy $(SYNERGY_DATA_PATH)trainingSet.mat
	make -j -f +planB/+Control/run.make TEST=$(TEST) TARGET=synergy $(SYNERGY_DATA_PATH)testSet.mat


$(DATAPATH)convertedNeuralNetworkResults/: $(DATAPATH)convertNeuralNetworkResults.make
	make -j 4 -f $(DATAPATH)convertNeuralNetworkResults.make createAll

$(DATAPATH)convertNeuralNetworkResults.make: $(DATAPATH)neuralNetworkResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertNeuralNetworkResults.make $(DATAPATH)neuralNetworkResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedNeuralNetworkResults/ "$(MATLAB) \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""

$(DATAPATH)convertedSupportVectorMachineResults/: $(DATAPATH)convertSupportVectorMachineResults.make
	make -j 4 -f $(DATAPATH)convertSupportVectorMachineResults.make createAll

$(DATAPATH)convertSupportVectorMachineResults.make: $(DATAPATH)supportVectorMachineResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertSupportVectorMachineResults.make $(DATAPATH)supportVectorMachineResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedSupportVectorMachineResults/ "$(MATLAB) \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)combinedConvertedResults.mat: $(DATAPATH)convertedNeuralNetworkResults/ $(DATAPATH)convertedSupportVectorMachineResults/
	$(MATLAB) "planB.Control.combineAnalysisResults('$(DATAPATH)combinedConvertedResults.mat', '$(DATAPATH)convertedNeuralNetworkResults/', '$(DATAPATH)convertedSupportVectorMachineResults/');exit;"


convertedFinalResult: $(DATAPATH)combinedConvertedResults.mat
endif

# DEBUGGING
# shows the values of all used variables
pathReport:
	echo datapath: $(DATAPATH)
	echo datasource: $(DATASOURCE)
	echo exampledata: $(EXAMPLEDATA)
	echo target: $(TARGET)

# ANALYSIS
finalResult: analysis
	echo Final result is at $(DATAPATH)combinedResults.mat

analysis: $(DATAPATH)combinedResults.mat

$(DATAPATH)combinedResults.mat: $(DATAPATH)neuralNetworkResults/ $(DATAPATH)supportVectorMachineResults/
	$(MATLAB) "planB.Control.combineAnalysisResults('$(DATAPATH)combinedResults.mat', '$(DATAPATH)neuralNetworkResults/', '$(DATAPATH)supportVectorMachineResults/'); exit;"


$(DATAPATH)neuralNetworkResults/: $(DATAPATH)runNeuralNetworkTasks.make $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat +planB/+Control/runNeuralNetworkTask.m
	make -j 4 -f $(DATAPATH)runNeuralNetworkTasks.make createAll

$(DATAPATH)supportVectorMachineResults/: $(DATAPATH)runSupportVectorMachineTasks.make $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat +planB/+Control/runSupportVectorMachineTask.m
	make -j 4 -f $(DATAPATH)runSupportVectorMachineTasks.make createAll


$(DATAPATH)runNeuralNetworkTasks.make: ./+planB/+Control/createMakeFile.py $(DATAPATH)neuralNetworkTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runNeuralNetworkTasks.make $(DATAPATH)neuralNetworkTasks/ $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat $(DATAPATH)neuralNetworkResults/ "$(MATLAB) \"planB.Control.runNeuralNetworkTask('{0}', '{1}', '{2}', '{3}'); exit;\""

$(DATAPATH)runSupportVectorMachineTasks.make: ./+planB/+Control/createMakeFile.py $(DATAPATH)supportVectorMachineTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runSupportVectorMachineTasks.make $(DATAPATH)supportVectorMachineTasks/ $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat $(DATAPATH)supportVectorMachineResults/ "$(MATLAB) \"planB.Control.runSupportVectorMachineTask('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)neuralNetworkTasks/: +planB/+Control/createNeuralNetworkTasks.m
	mkdir -p $(DATAPATH)neuralNetworkTasks/
	$(MATLAB) "planB.Control.createNeuralNetworkTasks('$(DATAPATH)neuralNetworkTasks/'); exit;"

$(DATAPATH)supportVectorMachineTasks/: +planB/+Control/createSupportVectorMachineTasks.m
	mkdir -p $(DATAPATH)neuralNetworkTasks/
	$(MATLAB) "planB.Control.createSupportVectorMachineTasks('$(DATAPATH)supportVectorMachineTasks/'); exit;"

# REDUCTION
reduction: $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat

$(DATAPATH)reducedTrainingSet.mat: $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat
	$(MATLAB) "planB.Control.reduceExampleSet('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)reducedTrainingSet.mat'); exit;"

$(DATAPATH)reducedTestSet.mat: $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat
	$(MATLAB) "planB.Control.reduceExampleSet('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)reducedTestSet.mat'); exit;"


$(DATAPATH)combinedDimensionReductions.mat: $(DATAPATH)randomForestReductionResults/
	$(MATLAB) "planB.Control.combineDimensionReductions('$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)randomForestReductionResults/'); exit;"

reductiondecisionpoint: $(DATAPATH)randomForestReductionResults/

$(DATAPATH)randomForestReductionResults/: $(DATAPATH)runRandomForestReductionTasks.make $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat +planB/+Control/runRandomForestReductionTask.m
	make -j 5 -f $(DATAPATH)runRandomForestReductionTasks.make createAll

$(DATAPATH)runRandomForestReductionTasks.make: ./+planB/+Control/createMakeFile.py  $(DATAPATH)randomForestReductionTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runRandomForestReductionTasks.make $(DATAPATH)randomForestReductionTasks/  $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat $(DATAPATH)randomForestReductionResults/ "$(MATLAB) \"planB.Control.runRandomForestReductionTask('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)randomForestReductionTasks/:
	$(MATLAB) "planB.Control.createRandomForestTasks('$(DATAPATH)randomForestReductionTasks/'); exit;"

# PREPARATION
preparation: $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat


$(DATAPATH)exampleSetWithoutCellLineIds.mat: $(DATAPATH)exampleSet.mat
	$(MATLAB) "planB.Control.removeCellLineIdsFromExampleSet('$(DATAPATH)exampleSet.mat', '$(DATAPATH)exampleSetWithoutCellLineIds.mat'); exit;"

$(DATAPATH)exampleSet.mat: $(DATASOURCE) $(EXAMPLEDATA)
	$(MATLAB) "planB.Control.prepareFullExampleSet('$(DATASOURCE)', '$(DATAPATH)exampleSet.mat', '$(EXAMPLEDATA)'); exit;"

$(DATASOURCE):
	$(MATLAB) "planB.Control.createDataSource('$(DATAROOT)dataSource.mat', '$(MUTATIONPATH)', '$(EXPRESSIONPATH)', '$(PATHWAYPATH)', 'resources/thesauri/', 'cellLine', 'drug', 'kegg', 'gene', 'tissue', 'cancerType', 'synergy', 'checked');exit;"

# reduction graphs

$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetrics.png $(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetricsScaled.png:
	$(MATLAB) "planB.Control.createGraphTreeCountVsPerformanceMetrics('$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetrics.png', '$(DATAPATH)randomForestReductionGraphs/treeCountVsPerformanceMetricsScaled.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png:
	$(MATLAB) "planB.Control.createGraphTreeCountChangeAndRankCorrelation( '$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistributionHighImportance.png:
	$(MATLAB) "planB.Control.createGraphTreeCountVsImportanceDistributionHighImportance('$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistributionHighImportance.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistribution.png':
	$(MATLAB) "planB.Control.createGraphTreeCountVsImportanceDistribution('$(DATAPATH)randomForestReductionGraphs/treeCountVsImportanceDistribution.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceOverview.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceGoodZone.png $(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceBestZone.png:
	$(MATLAB) "planB.Control.createGraphBestPerformer('$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceOverview.png', '$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceGoodZone.png', '$(DATAPATH)randomForestReductionGraphs/bestPerformerImportanceBestZone.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png:
	$(MATLAB) "planB.Control.createGraphTreeCountChangeAndRankCorrelation( '$(DATAPATH)randomForestReductionGraphs/treeCountChangeAndRankCorrelation.png', '$(DATAPATH)randomForestReductionResults/'); exit;"

$(DATAPATH)neuralNetworkGraphs/results.png:
	$(MATLAB) "planB.Control.createGraphNeuralNetworkResults('$(DATAPATH)neuralNetworkResults/', '$(DATAPATH)neuralNetworkGraphs/results.png'); exit;"
