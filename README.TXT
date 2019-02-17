# CODE
# The most important code can be found in +planB though sometimes this code does still reference old code contained in other folders.
# Machine learning analysis is controlled by matlab functions executed from the shell, and are contained in +planB/+Control. The order of execution is defined in the make files in the same folder, but below you can find a list of shell commands that accomplish the same goal.

# DATA
# All potentially privacy sensitive data has been removed.

# PREREQUISITES:
# mount the VU AAA Chemogenomics drop box folder and make sure that the property
$ DROPBOX_ROOT in Config.m references the drop box folder.

# RUNNING THE MACHINE LEARNING PIPELINE
# The following shell commands run the machine learning pipeline assuming a macosx operating system
# Do note that completing this could take almost an entire day (it did on my computer)

# BEFORE EVERYTHING CREATE DATA SOURCE
mkdir -p ./output/results/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createDataSource('./output/results/dataSource.mat', '~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/mutations_corrected.csv', '~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/gex.csv', 'resources/pathways/all/', 'resources/thesauri/', 'cellLine', 'drug', 'kegg', 'gene', 'tissue', 'cancerType', 'synergy', 'checked');exit;"

# FOR SYNERGY (which must be computed before lethality and synergy)
# preparation
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createDreamSynergyData('./output/results/dataSource.mat', './resources/correctedRawSources/ch1_train_combination_and_monoTherapy.csv', './output/results/synergy/dreamSynergyData.mat'); exit;"
mkdir -p ./output/results/synergy/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.prepareFullExampleSet('./output/results/dataSource.mat', './output/results/synergy/exampleSet.mat', './output/results/synergy/dreamSynergyData.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.removeCellLineIdsFromExampleSet('./output/results/synergy/exampleSet.mat', './output/results/synergy/exampleSetWithoutCellLineIds.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.splitSynergyExampleSet('./output/results/synergy/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.splitSynergyExampleSet('./output/results/synergy/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat'); exit;"

# reduction
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createRandomForestTasks('./output/results/synergy/randomForestReductionTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/synergy/runRandomForestReductionTasks.make ./output/results/synergy/randomForestReductionTasks/  ./output/results/synergy/trainingSet.mat ./output/results/synergy/testSet.mat ./output/results/synergy/randomForestReductionResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runRandomForestReductionTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -f ./output/results/synergy/runRandomForestReductionTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineDimensionReductions('./output/results/synergy/combinedDimensionReductions.mat', './output/results/synergy/randomForestReductionResults/', 120, './output/results/synergy/bestReduction.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/synergy/trainingSet.mat', './output/results/synergy/combinedDimensionReductions.mat', './output/results/synergy/reducedTrainingSet.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/synergy/testSet.mat', './output/results/synergy/combinedDimensionReductions.mat', './output/results/synergy/reducedTestSet.mat'); exit;"
cat reduction.sh >reduction
chmod a+x reduction
# analysis

mkdir -p ./output/results/synergy/neuralNetworkTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createNeuralNetworkTasks('./output/results/synergy/neuralNetworkTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/synergy/runNeuralNetworkTasks.make ./output/results/synergy/neuralNetworkTasks/ ./output/results/synergy/reducedTrainingSet.mat ./output/results/synergy/reducedTestSet.mat ./output/results/synergy/neuralNetworkResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runNeuralNetworkTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/synergy/runNeuralNetworkTasks.make createAll
mkdir -p ./output/results/synergy/supportVectorMachineTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createSupportVectorMachineTasks('./output/results/synergy/supportVectorMachineTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/synergy/runSupportVectorMachineTasks.make ./output/results/synergy/supportVectorMachineTasks/ ./output/results/synergy/reducedTrainingSet.mat ./output/results/synergy/reducedTestSet.mat ./output/results/synergy/supportVectorMachineResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runSupportVectorMachineTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/synergy/runSupportVectorMachineTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/synergy/combinedResults.mat', './output/results/synergy/neuralNetworkResults/', './output/results/synergy/supportVectorMachineResults/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/synergy/runRegressAfterNeuralNetworkResults.make ./output/results/synergy/neuralNetworkResults/ ./output/results/synergy/reducedTrainingSet.mat ./output/results/synergy/reducedTestSet.mat ./output/results/synergy/neuralNetworkResultsAfterRegression/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertToResultAfterRegression('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/synergy/runRegressAfterNeuralNetworkResults.make createAll

# FOR LETHALITY


# preparation
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createDreamLethalityData('./output/results/dataSource.mat', '~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/csv/Raw_Data_csv/ch1_training_combinations_csv/', './resources/correctedRawSources/ch1_train_combination_and_monoTherapy.csv', './output/results/lethality/dreamLethalityData.mat'); exit;"
mkdir -p ./output/results/lethality/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.prepareFullExampleSet('./output/results/dataSource.mat', './output/results/lethality/exampleSet.mat', './output/results/lethality/dreamLethalityData.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.removeCellLineIdsFromExampleSet('./output/results/lethality/exampleSet.mat', './output/results/lethality/exampleSetWithoutCellLineIds.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.mirrorExampleSetSplit('./output/results/lethality/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat', './output/results/lethality/fullTrainingSet.mat', './output/results/lethality/testSet.mat');exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.randomSubSet('./output/results/lethality/fullTrainingSet.mat', './output/results/lethality/trainingSet.mat', '12000');exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.mirrorExampleSetSplit('./output/results/lethality/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat', './output/results/lethality/fullTrainingSet.mat', './output/results/lethality/testSet.mat');exit;"

# reduction

matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createRandomForestTasks('./output/results/lethality/randomForestReductionTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/lethality/runRandomForestReductionTasks.make ./output/results/lethality/randomForestReductionTasks/  ./output/results/lethality/trainingSet.mat ./output/results/lethality/testSet.mat ./output/results/lethality/randomForestReductionResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runRandomForestReductionTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -f ./output/results/lethality/runRandomForestReductionTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineDimensionReductions('./output/results/lethality/combinedDimensionReductions.mat', './output/results/lethality/randomForestReductionResults/', 115, './output/results/lethality/bestReduction.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/lethality/trainingSet.mat', './output/results/lethality/combinedDimensionReductions.mat', './output/results/lethality/reducedTrainingSet.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/lethality/testSet.mat', './output/results/lethality/combinedDimensionReductions.mat', './output/results/lethality/reducedTestSet.mat'); exit;"
cat reduction.sh >reduction
chmod a+x reduction

# analysis

mkdir -p ./output/results/lethality/neuralNetworkTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createNeuralNetworkTasks('./output/results/lethality/neuralNetworkTasks/', 'logsig'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/lethality/runNeuralNetworkTasks.make ./output/results/lethality/neuralNetworkTasks/ ./output/results/lethality/reducedTrainingSet.mat ./output/results/lethality/reducedTestSet.mat ./output/results/lethality/neuralNetworkResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runNeuralNetworkTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/lethality/runNeuralNetworkTasks.make createAll
mkdir -p ./output/results/lethality/supportVectorMachineTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createSupportVectorMachineTasks('./output/results/lethality/supportVectorMachineTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/lethality/runSupportVectorMachineTasks.make ./output/results/lethality/supportVectorMachineTasks/ ./output/results/lethality/reducedTrainingSet.mat ./output/results/lethality/reducedTestSet.mat ./output/results/lethality/supportVectorMachineResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runSupportVectorMachineTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/lethality/runSupportVectorMachineTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/lethality/combinedResults.mat', './output/results/lethality/neuralNetworkResults/', './output/results/lethality/supportVectorMachineResults/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/lethality/runRegressAfterNeuralNetworkResults.make ./output/results/lethality/neuralNetworkResults/ ./output/results/lethality/reducedTrainingSet.mat ./output/results/lethality/reducedTestSet.mat ./output/results/lethality/neuralNetworkResultsAfterRegression/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertToResultAfterRegression('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/lethality/runRegressAfterNeuralNetworkResults.make createAll

# converion to synergy

./+planB/+Control/createMakeFile.py  ./output/results/lethality/convertNeuralNetworkResults.make ./output/results/lethality/neuralNetworkResults/ ./output/results/lethality/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/lethality/convertedNeuralNetworkResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/lethality/convertNeuralNetworkResults.make createAll
./+planB/+Control/createMakeFile.py  ./output/results/lethality/convertNeuralNetworkResultsAfterRegression.make ./output/results/lethality/neuralNetworkResultsAfterRegression/ ./output/results/lethality/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/lethality/convertedNeuralNetworkResultsAfterRegression/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/lethality/convertNeuralNetworkResultsAfterRegression.make createAll
./+planB/+Control/createMakeFile.py  ./output/results/lethality/convertSupportVectorMachineResults.make ./output/results/lethality/supportVectorMachineResults/ ./output/results/lethality/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/lethality/convertedSupportVectorMachineResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertLethalityResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -f ./output/results/lethality/convertSupportVectorMachineResults.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/lethality/combinedConvertedResults.mat', './output/results/lethality/convertedNeuralNetworkResults/', './output/results/lethality/convertedSupportVectorMachineResults/');exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/lethality/combinedConvertedResults.mat', './output/results/lethality/convertedNeuralNetworkResults/', './output/results/lethality/convertedSupportVectorMachineResults/');exit;"

# FOR SYNERGISTIC LETHALITY
# preparation
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createDreamDExpectedData('./output/results/dataSource.mat', '~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/csv/Raw_Data_csv/ch1_training_combinations_csv/', './resources/correctedRawSources/ch1_train_combination_and_monoTherapy.csv', './output/results/dexpected/dreamDExpectedData.mat'); exit;"
mkdir -p ./output/results/dexpected/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.prepareFullExampleSet('./output/results/dataSource.mat', './output/results/dexpected/exampleSet.mat', './output/results/dexpected/dreamDExpectedData.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.removeCellLineIdsFromExampleSet('./output/results/dexpected/exampleSet.mat', './output/results/dexpected/exampleSetWithoutCellLineIds.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.mirrorExampleSetSplit('./output/results/dexpected/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat', './output/results/dexpected/fullTrainingSet.mat', './output/results/dexpected/testSet.mat');exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.randomSubSet('./output/results/dexpected/fullTrainingSet.mat', './output/results/dexpected/trainingSet.mat', '12000');exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.mirrorExampleSetSplit('./output/results/dexpected/exampleSetWithoutCellLineIds.mat', './output/results/synergy/trainingSet.mat', './output/results/synergy/testSet.mat', './output/results/dexpected/fullTrainingSet.mat', './output/results/dexpected/testSet.mat');exit;"

# reduction
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createRandomForestTasks('./output/results/dexpected/randomForestReductionTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/dexpected/runRandomForestReductionTasks.make ./output/results/dexpected/randomForestReductionTasks/  ./output/results/dexpected/trainingSet.mat ./output/results/dexpected/testSet.mat ./output/results/dexpected/randomForestReductionResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runRandomForestReductionTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -f ./output/results/dexpected/runRandomForestReductionTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineDimensionReductions('./output/results/dexpected/combinedDimensionReductions.mat', './output/results/dexpected/randomForestReductionResults/', 115, './output/results/dexpected/bestReduction.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/dexpected/trainingSet.mat', './output/results/dexpected/combinedDimensionReductions.mat', './output/results/dexpected/reducedTrainingSet.mat'); exit;"
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.reduceExampleSet('./output/results/dexpected/testSet.mat', './output/results/dexpected/combinedDimensionReductions.mat', './output/results/dexpected/reducedTestSet.mat'); exit;"
cat reduction.sh >reduction
chmod a+x reduction

# analysis
mkdir -p ./output/results/dexpected/neuralNetworkTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createNeuralNetworkTasks('./output/results/dexpected/neuralNetworkTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/dexpected/runNeuralNetworkTasks.make ./output/results/dexpected/neuralNetworkTasks/ ./output/results/dexpected/reducedTrainingSet.mat ./output/results/dexpected/reducedTestSet.mat ./output/results/dexpected/neuralNetworkResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runNeuralNetworkTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/dexpected/runNeuralNetworkTasks.make createAll
mkdir -p ./output/results/dexpected/supportVectorMachineTasks/
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.createSupportVectorMachineTasks('./output/results/dexpected/supportVectorMachineTasks/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/dexpected/runSupportVectorMachineTasks.make ./output/results/dexpected/supportVectorMachineTasks/ ./output/results/dexpected/reducedTrainingSet.mat ./output/results/dexpected/reducedTestSet.mat ./output/results/dexpected/supportVectorMachineResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.runSupportVectorMachineTask('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/dexpected/runSupportVectorMachineTasks.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/dexpected/combinedResults.mat', './output/results/dexpected/neuralNetworkResults/', './output/results/dexpected/supportVectorMachineResults/'); exit;"
./+planB/+Control/createMakeFile.py ./output/results/dexpected/runRegressAfterNeuralNetworkResults.make ./output/results/dexpected/neuralNetworkResults/ ./output/results/dexpected/reducedTrainingSet.mat ./output/results/dexpected/reducedTestSet.mat ./output/results/dexpected/neuralNetworkResultsAfterRegression/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertToResultAfterRegression('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 2 -f ./output/results/dexpected/runRegressAfterNeuralNetworkResults.make createAll

# conversion to synergy
./+planB/+Control/createMakeFile.py  ./output/results/dexpected/convertNeuralNetworkResults.make ./output/results/dexpected/neuralNetworkResults/ ./output/results/dexpected/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/dexpected/convertedNeuralNetworkResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/dexpected/convertNeuralNetworkResults.make createAll
./+planB/+Control/createMakeFile.py  ./output/results/dexpected/convertSupportVectorMachineResults.make ./output/results/dexpected/supportVectorMachineResults/ ./output/results/dexpected/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/dexpected/convertedSupportVectorMachineResults/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -f ./output/results/dexpected/convertSupportVectorMachineResults.make createAll
./+planB/+Control/createMakeFile.py  ./output/results/dexpected/convertNeuralNetworkResultsAfterRegression.make ./output/results/dexpected/neuralNetworkResultsAfterRegression/ ./output/results/dexpected/reducedTestSet.mat ./output/results/synergy/testSet.mat ./output/results/dexpected/convertedNeuralNetworkResultsAfterRegression/ "matlab -nodisplay -nodesktop -nosplash -r \"planB.Control.convertDExpectedResultToSynergyResult('{0}', '{1}', '{2}', '{3}'); exit;\""
make -j 4 -f ./output/results/dexpected/convertNeuralNetworkResultsAfterRegression.make createAll
matlab -nodisplay -nodesktop -nosplash -r "planB.Control.combineAnalysisResults('./output/results/dexpected/combinedConvertedResults.mat', './output/results/dexpected/convertedNeuralNetworkResults/', './output/results/dexpected/convertedSupportVectorMachineResults/');exit;"
