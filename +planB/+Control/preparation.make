include +planB/+Control/config.make

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

# $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat $(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat
# 	$(MATLAB) "planB.Control.mirrorExampleSetSplit('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(SYNERGY_DATA_PATH)trainingSet.mat', '$(SYNERGY_DATA_PATH)testSet.mat', '$(DATAPATH)trainingSet.mat', '$(DATAPATH)testSet.mat');exit;"


$(DATAPATH)fullTrainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat $(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat
	$(MATLAB) "planB.Control.mirrorExampleSetSplit('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(SYNERGY_DATA_PATH)trainingSet.mat', '$(SYNERGY_DATA_PATH)testSet.mat', '$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)testSet.mat');exit;"

$(DATAPATH)trainingSet.mat: $(DATAPATH)fullTrainingSet.mat
	$(MATLAB) "planB.Control.randomSubSet('$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)trainingSet.mat', '12000');exit;"

endif


ifeq (${TARGET}, dexpected)
EXAMPLEDATA = $(DATAPATH)dreamDExpectedData.mat
$(EXAMPLEDATA): $(DATASOURCE)
	$(MATLAB) "planB.Control.createDreamDExpectedData('$(DATASOURCE)', '$(DREAMLETHALITYPATH)', '$(DREAMSYNERGYDATA)', '$(EXAMPLEDATA)'); exit;"

# $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat $(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat
# 	$(MATLAB) "planB.Control.mirrorExampleSetSplit('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(SYNERGY_DATA_PATH)trainingSet.mat', '$(SYNERGY_DATA_PATH)testSet.mat', '$(DATAPATH)trainingSet.mat', '$(DATAPATH)testSet.mat');exit;"


$(DATAPATH)fullTrainingSet.mat $(DATAPATH)testSet.mat: $(DATAPATH)exampleSetWithoutCellLineIds.mat $(SYNERGY_DATA_PATH)trainingSet.mat $(SYNERGY_DATA_PATH)testSet.mat
	$(MATLAB) "planB.Control.mirrorExampleSetSplit('$(DATAPATH)exampleSetWithoutCellLineIds.mat', '$(SYNERGY_DATA_PATH)trainingSet.mat', '$(SYNERGY_DATA_PATH)testSet.mat', '$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)testSet.mat');exit;"

$(DATAPATH)trainingSet.mat: $(DATAPATH)fullTrainingSet.mat
	$(MATLAB) "planB.Control.randomSubSet('$(DATAPATH)fullTrainingSet.mat', '$(DATAPATH)trainingSet.mat', '12000');exit;"

endif


preparation: $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat


$(DATAPATH)exampleSetWithoutCellLineIds.mat: $(DATAPATH)exampleSet.mat
	$(MATLAB) "planB.Control.removeCellLineIdsFromExampleSet('$(DATAPATH)exampleSet.mat', '$(DATAPATH)exampleSetWithoutCellLineIds.mat'); exit;"

$(DATAPATH)exampleSet.mat: $(DATASOURCE) $(EXAMPLEDATA) $(DATAPATH)
	$(MATLAB) "planB.Control.prepareFullExampleSet('$(DATASOURCE)', '$(DATAPATH)exampleSet.mat', '$(EXAMPLEDATA)'); exit;"

$(DATAPATH):
	mkdir -p $(DATAPATH)
