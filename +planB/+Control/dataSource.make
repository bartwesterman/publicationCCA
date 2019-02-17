include +planB/+Control/config.make

datasource: $(DATASOURCE)

$(DATASOURCE):
	mkdir -p $(DATAROOT)
	$(MATLAB) "planB.Control.createDataSource('$(DATAROOT)dataSource.mat', '$(MUTATIONPATH)', '$(EXPRESSIONPATH)', '$(PATHWAYPATH)', 'resources/thesauri/', 'cellLine', 'drug', 'kegg', 'gene', 'tissue', 'cancerType', 'synergy', 'checked');exit;"

