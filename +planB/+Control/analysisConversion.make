include +planB/+Control/config.make

ifeq (${TARGET}, lethality)

$(DATAPATH)convertedNeuralNetworkResultsAfterRegression/: $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make
	make -j 4 -f $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make createAll

$(DATAPATH)convertNeuralNetworkResultsAfterRegression.make: $(DATAPATH)neuralNetworkResultsAfterRegression/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make $(DATAPATH)neuralNetworkResultsAfterRegression/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedNeuralNetworkResultsAfterRegression/ "$(MATLAB) \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""




$(DATAPATH)convertedNeuralNetworkResults/: $(DATAPATH)convertNeuralNetworkResults.make
	make -j 4 -f $(DATAPATH)convertNeuralNetworkResults.make createAll

$(DATAPATH)convertNeuralNetworkResults.make: $(DATAPATH)neuralNetworkResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertNeuralNetworkResults.make $(DATAPATH)neuralNetworkResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedNeuralNetworkResults/ "$(MATLAB) \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""

$(DATAPATH)convertedSupportVectorMachineResults/: $(DATAPATH)convertSupportVectorMachineResults.make
	make -f $(DATAPATH)convertSupportVectorMachineResults.make createAll

$(DATAPATH)convertSupportVectorMachineResults.make: $(DATAPATH)supportVectorMachineResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertSupportVectorMachineResults.make $(DATAPATH)supportVectorMachineResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedSupportVectorMachineResults/ "$(MATLAB) \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)combinedConvertedResults.mat: $(DATAPATH)convertedNeuralNetworkResults/  $(DATAPATH)convertedNeuralNetworkResultsAfterRegression/ $(DATAPATH)convertedSupportVectorMachineResults/
	$(MATLAB) "planB.Control.combineAnalysisResults('$(DATAPATH)combinedConvertedResults.mat', '$(DATAPATH)convertedNeuralNetworkResults/', '$(DATAPATH)convertedSupportVectorMachineResults/');exit;"


analysisConversion: $(DATAPATH)combinedConvertedResults.mat
endif

ifeq (${TARGET}, dexpected)

$(DATAPATH)convertedNeuralNetworkResultsAfterRegression/: $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make
	make -j 4 -f $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make createAll

$(DATAPATH)convertNeuralNetworkResultsAfterRegression.make: $(DATAPATH)neuralNetworkResultsAfterRegression/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertNeuralNetworkResultsAfterRegression.make $(DATAPATH)neuralNetworkResultsAfterRegression/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedNeuralNetworkResultsAfterRegression/ "$(MATLAB) \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""



$(DATAPATH)convertedNeuralNetworkResults/: $(DATAPATH)convertNeuralNetworkResults.make
	make -j 4 -f $(DATAPATH)convertNeuralNetworkResults.make createAll

$(DATAPATH)convertNeuralNetworkResults.make: $(DATAPATH)neuralNetworkResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertNeuralNetworkResults.make $(DATAPATH)neuralNetworkResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedNeuralNetworkResults/ "$(MATLAB) \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""

$(DATAPATH)convertedSupportVectorMachineResults/: $(DATAPATH)convertSupportVectorMachineResults.make
	make -f $(DATAPATH)convertSupportVectorMachineResults.make createAll

$(DATAPATH)convertSupportVectorMachineResults.make: $(DATAPATH)supportVectorMachineResults/
	./+planB/+Control/createMakeFile.py  $(DATAPATH)convertSupportVectorMachineResults.make $(DATAPATH)supportVectorMachineResults/ $(DATAPATH)reducedTestSet.mat $(SYNERGY_DATA_PATH)testSet.mat $(DATAPATH)convertedSupportVectorMachineResults/ "$(MATLAB) \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""


$(DATAPATH)combinedConvertedResults.mat: $(DATAPATH)convertedNeuralNetworkResults/ $(DATAPATH)convertedSupportVectorMachineResults/ $(DATAPATH)convertedNeuralNetworkResultsAfterRegression/
endif
	$(MATLAB) "planB.Control.combineAnalysisResults('$(DATAPATH)combinedConvertedResults.mat', '$(DATAPATH)convertedNeuralNetworkResults/', '$(DATAPATH)convertedSupportVectorMachineResults/');exit;"


analysisConversion: $(DATAPATH)combinedConvertedResults.mat
