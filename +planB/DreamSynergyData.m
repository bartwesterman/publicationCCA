classdef DreamSynergyData < data.SynergyDataSet
    %DREAMSYNERGYDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesauri;
    end
    
    methods
        function obj = init(obj, thesauri, csvFilePath)
            if nargin == 2
                csvFilePath = Config.DREAM_MONO_AND_COMBINATION_TRAINING;
            end
            
            obj.thesauri = thesauri;
            obj.thesauri.acquireEntityId('synergy', 'evaluationCriterium');
            obj.synergyData = obj.buildFullTable(csvFilePath, thesauri);
            obj.synergyData = obj.synergyData(obj.synergyData.qa == 1, :);
            synergy = obj.synergyData.synergy;
            synergy  = (synergy - min(synergy)) / (max(synergy) - min(synergy));
            obj.synergyData.synergy = synergy; 
            
        end
        
        function synergyData = buildFullTable(obj, csvFilePath, thesauri)
            dreamSynergyCsv = data.csvread(csvFilePath);
            
            cellLineThesaurus   = thesauri.get('cellLine');
            drugThesaurus       = thesauri.get('drug');
            cancerTypeThesaurus = thesauri.get('cancerType');
            tissueThesaurus     = thesauri.get('tissue');
            synergyThesaurus    = thesauri.get('synergy');
            geneThesaurus       = thesauri.get('kegg');
            checkedThesaurus    = thesauri.get('checked');
            exampleIdThesaurus  = thesauri.get('exampleId');
            
            rawCellLineName = dreamSynergyCsv(2:end,1)
            rawDrugAName    = dreamSynergyCsv(2:end, 2);
            rawDrugBName    = dreamSynergyCsv(2:end, 3);
            
            drugComboName   = sort([rawDrugAName rawDrugBName]')';
            
            cellDrugComboName = strcat(rawCellLineName, '@', drugComboName(:, 1), '@', drugComboName(:,2));
            
            
            cellLine  = cellfun(@(label) cellLineThesaurus.getId(label), rawCellLineName);
            drugA     = cellfun(@(label) drugThesaurus.getId(label), rawDrugAName);
            drugB     = cellfun(@(label) drugThesaurus.getId(label), rawDrugBName);
            pIc50A    = num2cell(-log(cellfun(@str2num, dreamSynergyCsv(2:end, 6))));
            pIc50B    = num2cell(-log(cellfun(@str2num, dreamSynergyCsv(2:end, 9))));
            synergy   = cellfun(@str2num, dreamSynergyCsv(2:end, 12));
            exampleId = cellfun(@(label) exampleIdThesaurus.getId(label), cellDrugComboName);
            
            qa          = cellfun(@str2num, dreamSynergyCsv(2:end, 13));
            
            hillSlopeA  = cellfun(@str2num, dreamSynergyCsv(2:end, 7));
            hillSlopeB  = cellfun(@str2num, dreamSynergyCsv(2:end, 10));
            eInfA  = cellfun(@str2num, dreamSynergyCsv(2:end, 8));
            eInfB  = cellfun(@str2num, dreamSynergyCsv(2:end, 11));
            maxConcentrationA  = cellfun(@str2num, dreamSynergyCsv(2:end, 4));
            maxConcentrationB  = cellfun(@str2num, dreamSynergyCsv(2:end, 5));
            combinationId  = dreamSynergyCsv(2:end, 14);
            
            synergyData = table(synergy, cellLine, drugA, drugB, exampleId, pIc50A, pIc50B, hillSlopeA, hillSlopeB, eInfA, eInfB, maxConcentrationA, maxConcentrationB, qa, combinationId);
        end
        
        function entityIds = getEntityIds(obj)
            synergyId = obj.thesauri.acquireEntityId('synergy', 'evaluationCriterium');
            drugIds   = unique([obj.synergyData.drugA; obj.synergyData.drugB]);
            cellIds   = unique(obj.synergyData.cellLine);
            entityIds = [synergyId; drugIds; cellIds];
        end
        
        function count = getExampleCount(obj)
            count = height(obj.synergyData);
        end
        
        function [entityIds, values, cellLineId, drugAId, drugBId, exampleId] = getExampleData(obj, exampleIndex)
            synergyId  = obj.thesauri.acquireEntityId('synergy', 'evaluationCriterium');
            cellLineId = obj.synergyData.cellLine(exampleIndex);
            drugAId    = obj.synergyData.drugA(exampleIndex);
            drugBId    = obj.synergyData.drugB(exampleIndex);
            
            entityIds = [
                synergyId; 
                obj.synergyData.cellLine(exampleIndex);
                drugAId;
                drugBId
            ];
        
            values = [
                obj.synergyData.synergy(exampleIndex);
                1;
                1;
                1
            ];
        
            exampleId = obj.synergyData.exampleId(exampleIndex);
        end
        
        
        function sensitivityTable = extractSensitivities(obj)
            sensitivityTable = extractSensitivities@data.SynergyDataSet(obj);
            sensitivityTable.hillSlope = [obj.synergyData.hillSlopeA;obj.synergyData.hillSlopeB];
            sensitivityTable.eInf = [obj.synergyData.eInfA;obj.synergyData.eInfB];
            sensitivityTable.maxConcentration = [obj.synergyData.maxConcentrationA;obj.synergyData.maxConcentrationB];
        end
    end
    
end

