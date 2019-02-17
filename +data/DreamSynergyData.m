classdef DreamSynergyData < data.SynergyDataSet
    %DREAMSYNERGYDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = init(obj, thesauri, csvFilePath)
            if nargin == 2
                csvFilePath = Config.DREAM_MONO_AND_COMBINATION_TRAINING;
            end
            dreamSynergyCsv = data.csvread(csvFilePath);
            
            cellLineThesaurus   = thesauri.get('cellLine');
            drugThesaurus       = thesauri.get('drug');
            cancerTypeThesaurus = thesauri.get('cancerType');
            tissueThesaurus     = thesauri.get('tissue');
            synergyThesaurus    = thesauri.get('synergy');
            geneThesaurus       = thesauri.get('gene');
            checkedThesaurus    = thesauri.get('checked');
            
            cellLine = cellfun(@(label) cellLineThesaurus.getId(label), dreamSynergyCsv(2:end,1));
            drugA    = cellfun(@(label) drugThesaurus.getId(label), dreamSynergyCsv(2:end, 2));
            drugB    = cellfun(@(label) drugThesaurus.getId(label), dreamSynergyCsv(2:end, 3));
            pIc50A   = num2cell(-log(cellfun(@str2num, dreamSynergyCsv(2:end, 6))));
            pIc50B   = num2cell(-log(cellfun(@str2num, dreamSynergyCsv(2:end, 9))));
            synergy  = cellfun(@str2num, dreamSynergyCsv(2:end, 12));
            
            qa          = cellfun(@str2num, dreamSynergyCsv(2:end, 13));
            
            hillSlopeA  = cellfun(@str2num, dreamSynergyCsv(2:end, 7));
            hillSlopeB  = cellfun(@str2num, dreamSynergyCsv(2:end, 10));
            eInfA  = cellfun(@str2num, dreamSynergyCsv(2:end, 8));
            eInfB  = cellfun(@str2num, dreamSynergyCsv(2:end, 11));
            maxConcentrationA  = cellfun(@str2num, dreamSynergyCsv(2:end, 4));
            maxConcentrationB  = cellfun(@str2num, dreamSynergyCsv(2:end, 5));
            combinationId  = dreamSynergyCsv(2:end, 14);
            
            obj.synergyData = table(synergy, cellLine, drugA, drugB, pIc50A, pIc50B, hillSlopeA, hillSlopeB, eInfA, eInfB, maxConcentrationA, maxConcentrationB, qa, combinationId);
 
        end
        
        function sensitivityTable = extractSensitivities(obj)
            sensitivityTable = extractSensitivities@data.SynergyDataSet(obj);
            sensitivityTable.hillSlope = [obj.synergyData.hillSlopeA;obj.synergyData.hillSlopeB];
            sensitivityTable.eInf = [obj.synergyData.eInfA;obj.synergyData.eInfB];
            sensitivityTable.maxConcentration = [obj.synergyData.maxConcentrationA;obj.synergyData.maxConcentrationB];
        end
    end
    
end

