

compileAll: build/createDataSource build/createDreamLethalityData build/createDreamSynergyData build/prepareFullExampleSet build/removeCellLineIdsFromExampleSet build/createRandomForestTasks build/runRandomForestReductionTask build/combineDimensionReductions build/reduceExampleSet build/createNeuralNetworkTasks build/runNeuralNetworkTask build/combineAnalysisResults

message: /home/calvano/chemogenomics/Config.m
	echo yes

# $(shell ./getDependencies.sh +planB/+Control/createDataSource.m) build
build/createDataSource:
	cp +planB/+Control/createDataSource.m .
	mcc -m createDataSource.m -d build -o createDataSource
	rm createDataSource.m

# $(shell ./getDependencies.sh +planB/+Control/createDreamLethalityData.m) build
build/createDreamLethalityData:
	cp +planB/+Control/createDreamLethalityData.m .
	mcc -m createDreamLethalityData.m -d build -o createDreamLethalityData
	rm createDreamLethalityData.m

# $(shell ./getDependencies.sh +planB/+Control/createDreamSynergyData.m) build
build/createDreamSynergyData:
	cp +planB/+Control/createDreamSynergyData.m .
	mcc -m createDreamSynergyData.m -d build -o createDreamSynergyData
	rm createDreamSynergyData.m

# $(shell ./getDependencies.sh +planB/+Control/prepareFullExampleSet.m) build
build/prepareFullExampleSet:
	cp +planB/+Control/prepareFullExampleSet.m .
	mcc -m prepareFullExampleSet.m -d build -o prepareFullExampleSet
	rm prepareFullExampleSet.m

# $(shell ./getDependencies.sh +planB/+Control/removeCellLineIdsFromExampleSet.m) build
build/removeCellLineIdsFromExampleSet:
	cp +planB/+Control/removeCellLineIdsFromExampleSet.m .
	mcc -m removeCellLineIdsFromExampleSet.m -d build -o removeCellLineIdsFromExampleSet
	rm removeCellLineIdsFromExampleSet.m

# $(shell ./getDependencies.sh +planB/+Control/createRandomForestTasks.m) build
build/createRandomForestTasks:
	cp +planB/+Control/createRandomForestTasks.m .
	mcc -m createRandomForestTasks.m -d build -o createRandomForestTasks
	rm createRandomForestTasks.m

# $(shell ./getDependencies.sh +planB/+Control/runRandomForestReductionTask.m) build
build/runRandomForestReductionTask:
	cp +planB/+Control/runRandomForestReductionTask.m .
	mcc -m runRandomForestReductionTask.m -d build -o runRandomForestReductionTask
	rm runRandomForestReductionTask.m

# $(shell ./getDependencies.sh +planB/+Control/combineDimensionReductions.m) build
build/combineDimensionReductions:
	cp +planB/+Control/combineDimensionReductions.m .
	mcc -m combineDimensionReductions.m -d build -o combineDimensionReductions
	rm combineDimensionReductions.m

# $(shell ./getDependencies.sh +planB/+Control/reduceExampleSet.m) build
build/reduceExampleSet:
	cp +planB/+Control/reduceExampleSet.m .
	mcc -m reduceExampleSet.m -d build -o reduceExampleSet
	rm reduceExampleSet.m

# $(shell ./getDependencies.sh +planB/+Control/createNeuralNetworkTasks.m) build
build/createNeuralNetworkTasks:
	cp +planB/+Control/createNeuralNetworkTasks.m .
	mcc -m createNeuralNetworkTasks.m -d build -o createNeuralNetworkTasks
	rm createNeuralNetworkTasks.m

# $(shell ./getDependencies.sh +planB/+Control/runNeuralNetworkTask.m) build
build/runNeuralNetworkTask:
	cp +planB/+Control/runNeuralNetworkTask.m .
	mcc -m runNeuralNetworkTask.m -d build -o runNeuralNetworkTask
	rm runNeuralNetworkTask.m

# $(shell ./getDependencies.sh +planB/+Control/combineAnalysisResults.m) build
build/combineAnalysisResults:
	cp +planB/+Control/combineAnalysisResults.m .
	mcc -m combineAnalysisResults.m -d build -o combineAnalysisResults
	rm combineAnalysisResults.m


build:
	mkdir build
