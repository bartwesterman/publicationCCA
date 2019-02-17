include +planB/+Control/config.make

reduction: $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat

$(DATAPATH)reducedTrainingSet.mat: $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)trainingSet.mat
	$(MATLAB) "planB.Control.reduceExampleSet('$(DATAPATH)trainingSet.mat', '$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)reducedTrainingSet.mat'); exit;"

$(DATAPATH)reducedTestSet.mat: $(DATAPATH)combinedDimensionReductions.mat $(DATAPATH)exampleSetWithoutCellLineIds.mat
	$(MATLAB) "planB.Control.reduceExampleSet('$(DATAPATH)testSet.mat', '$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)reducedTestSet.mat'); exit;"


$(DATAPATH)combinedDimensionReductions.mat: $(DATAPATH)randomForestReductionResults/
	$(MATLAB) "planB.Control.combineDimensionReductions('$(DATAPATH)combinedDimensionReductions.mat', '$(DATAPATH)randomForestReductionResults/', $(BEST_ENTITY_COUNT), '$(DATAPATH)bestReduction.mat'); exit;"

reductiondecisionpoint: $(DATAPATH)randomForestReductionResults/

$(DATAPATH)randomForestReductionResults/: $(DATAPATH)runRandomForestReductionTasks.make $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat +planB/+Control/runRandomForestReductionTask.m
	make -f $(DATAPATH)runRandomForestReductionTasks.make createAll

$(DATAPATH)runRandomForestReductionTasks.make: ./+planB/+Control/createMakeFile.py  $(DATAPATH)randomForestReductionTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runRandomForestReductionTasks.make $(DATAPATH)randomForestReductionTasks/  $(DATAPATH)trainingSet.mat $(DATAPATH)testSet.mat $(DATAPATH)randomForestReductionResults/ "$(MATLAB) \"planB.Control.runRandomForestReductionTask('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)randomForestReductionTasks/:
	$(MATLAB) "planB.Control.createRandomForestTasks('$(DATAPATH)randomForestReductionTasks/'); exit;"
