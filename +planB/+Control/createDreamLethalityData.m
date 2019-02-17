function exampleData = createDreamLethalityData( dataSourceFilePath, dreamLethalityPath, dreamQualityTablePath, exampleDataFilePath )
    em = data.EntityManager(); % tell compiler that EntityManager exists
    d = planB.DataSource();
    if ~exist('dreamLethalityPath','var'),       dreamLethalityPath        = Config.DREAM_COMBINATIONS_PATH;             end
    if ~exist('dreamQualityTablePath','var'),    dreamQualityTablePath     = Config.DREAM_MONO_AND_COMBINATION_TRAINING; end

    load(dataSourceFilePath, 'obj');
    
    exampleData = data.DreamDrugDoseLethalityData().init(obj.thesauri, dreamLethalityPath, dreamQualityTablePath);
    utils.assurePathFor(exampleDataFilePath);
    save(exampleDataFilePath, 'exampleData');
    
    % data source might be modified (entityManager/thesauri to be precise), so must be saved again, watch out with
    % paralel builds with make!
    
    save(dataSourceFilePath, 'obj', '-v7.3');
end

