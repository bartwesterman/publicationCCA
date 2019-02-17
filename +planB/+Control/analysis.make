include +planB/+Control/config.make


analysis: $(DATAPATH)combinedResults.mat $(DATAPATH)neuralNetworkResultsAfterRegression/

$(DATAPATH)combinedResults.mat: $(DATAPATH)neuralNetworkResults/ $(DATAPATH)supportVectorMachineResults/
	$(MATLAB) "planB.Control.combineAnalysisResults('$(DATAPATH)combinedResults.mat', '$(DATAPATH)neuralNetworkResults/', '$(DATAPATH)supportVectorMachineResults/'); exit;"

$(DATAPATH)neuralNetworkResultsAfterRegression/: $(DATAPATH)runRegressAfterNeuralNetworkResults.make $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat +planB/+Control/convertToResultAfterRegression.m
	make -j 2 -f $(DATAPATH)runRegressAfterNeuralNetworkResults.make createAll

$(DATAPATH)neuralNetworkResults/: $(DATAPATH)runNeuralNetworkTasks.make $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat +planB/+Control/runNeuralNetworkTask.m
	make -j 2 -f $(DATAPATH)runNeuralNetworkTasks.make createAll

$(DATAPATH)supportVectorMachineResults/: $(DATAPATH)runSupportVectorMachineTasks.make $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat +planB/+Control/runSupportVectorMachineTask.m
	make -j 4 -f $(DATAPATH)runSupportVectorMachineTasks.make createAll

$(DATAPATH)runRegressAfterNeuralNetworkResults.make: ./+planB/+Control/createMakeFile.py $(DATAPATH)neuralNetworkResults/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runRegressAfterNeuralNetworkResults.make $(DATAPATH)neuralNetworkResults/ $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat $(DATAPATH)neuralNetworkResultsAfterRegression/ "$(MATLAB) \"planB.Control.convertToResultAfterRegression('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)runNeuralNetworkTasks.make: ./+planB/+Control/createMakeFile.py $(DATAPATH)neuralNetworkTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runNeuralNetworkTasks.make $(DATAPATH)neuralNetworkTasks/ $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat $(DATAPATH)neuralNetworkResults/ "$(MATLAB) \"planB.Control.runNeuralNetworkTask('{0}', '{1}', '{2}', '{3}'); exit;\""

$(DATAPATH)runSupportVectorMachineTasks.make: ./+planB/+Control/createMakeFile.py $(DATAPATH)supportVectorMachineTasks/
	./+planB/+Control/createMakeFile.py $(DATAPATH)runSupportVectorMachineTasks.make $(DATAPATH)supportVectorMachineTasks/ $(DATAPATH)reducedTrainingSet.mat $(DATAPATH)reducedTestSet.mat $(DATAPATH)supportVectorMachineResults/ "$(MATLAB) \"planB.Control.runSupportVectorMachineTask('{0}', '{1}', '{2}', '{3}'); exit;\""

ifndef KERNEL_NAME
$(DATAPATH)neuralNetworkTasks/: +planB/+Control/createNeuralNetworkTasks.m
	mkdir -p $(DATAPATH)neuralNetworkTasks/
	$(MATLAB) "planB.Control.createNeuralNetworkTasks('$(DATAPATH)neuralNetworkTasks/'); exit;"
else
$(DATAPATH)neuralNetworkTasks/: +planB/+Control/createNeuralNetworkTasks.m
	mkdir -p $(DATAPATH)neuralNetworkTasks/
	$(MATLAB) "planB.Control.createNeuralNetworkTasks('$(DATAPATH)neuralNetworkTasks/', '$(KERNEL_NAME)'); exit;"
endif

$(DATAPATH)supportVectorMachineTasks/: +planB/+Control/createSupportVectorMachineTasks.m
	mkdir -p $(DATAPATH)supportVectorMachineTasks/
	$(MATLAB) "planB.Control.createSupportVectorMachineTasks('$(DATAPATH)supportVectorMachineTasks/'); exit;"
