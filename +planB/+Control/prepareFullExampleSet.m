function exampleSet = prepareFullExampleSet(dataSourceFilePath, exampleSetFilePath, exampleDataFilePath)
%PREPAREFULLEXAMPLESET Summary of this function goes here
%   Detailed explanation goes here
    mac = analysis.MainAnalysisController(); % here so compiler knows main analysis controller is necessary
    es  = planB.ExampleSet();
    dsd = planB.DreamSynergyData();
    dld = data.DreamDrugDoseLethalityData();
    ed  = planB.Control.test.MockExampleData();
    med = planB.Control.test.MockExpressionData();
    mmd = planB.Control.test.MockMutationData();
    ds  = planB.DataSource();
    dm = data.DreamMutation();
    dge = data.DreamGeneExpression();
    em  = data.EntityManager();
    
    
    
    function v = loadDataSource()
        load(dataSourceFilePath, 'obj');
        v = obj;
    end

    ds = loadDataSource();
    
    load(exampleDataFilePath, 'exampleData');
    
    exampleSet = planB.ExampleFactory() ...
                    .init(ds, exampleData) ...
                    .createExampleSet();
                
    save(exampleSetFilePath, 'exampleSet', '-v7.3');
end

