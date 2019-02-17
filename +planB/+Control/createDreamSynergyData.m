function exampleData = createDreamSynergyData( dataSourceFilePath, dreamSynergyDataFilePath, exampleDataFilePath )
%CREATESYNERGYDATA Summary of this function goes here
%   Detailed explanation goes here
    ds = planB.DataSource(); % here so compiler knows DataSource is necessary
    if nargin == 1
        dreamSynergyDataFilePath = Config.DREAM_MONO_AND_COMBINATION_TRAINING;
    end
    
    function v = loadDataSource()
        load(dataSourceFilePath, 'obj');
        v = obj;
    end

    function saveDataSource(obj)
        save(dataSourceFilePath, 'obj', '-v7.3');
    end

    dataSource = loadDataSource();
    exampleData = planB.DreamSynergyData().init(dataSource.thesauri, dreamSynergyDataFilePath);

    utils.assurePathFor(exampleDataFilePath);
    
    save(exampleDataFilePath, 'exampleData', '-v7.3');
    saveDataSource(dataSource);
end

