TARGET = synergy

MATLAB = matlab -nodisplay -nodesktop -nosplash -r

DATAROOT   = ./output/results/
ifdef TEST
	DATAROOT   = ./output/test/
endif
DATAPATH   = $(DATAROOT)$(TARGET)/
DATASOURCE = $(DATAROOT)dataSource.mat

DREAMSYNERGYDATA = ./resources/correctedRawSources/ch1_train_combination_and_monoTherapy.csv
DREAMLETHALITYPATH = ~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/csv/Raw_Data_csv/ch1_training_combinations_csv/
EXPRESSIONPATH = ~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/gex.csv
MUTATIONPATH = ~/Dropbox/VU AAA Chemogenomics/2 Data/1 Raw sources/3 Dream/Sanger_molecular_data/mutations_corrected.csv
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

ifeq ($(TARGET), synergy)
	BEST_ENTITY_COUNT = 120
endif

ifeq (${TARGET}, lethality)

	# BEST_ENTITY_COUNT = 250
	BEST_ENTITY_COUNT = 115
	KERNEL_NAME = logsig

endif

ifeq (${TARGET}, dexpected)

	BEST_ENTITY_COUNT = 115
endif
