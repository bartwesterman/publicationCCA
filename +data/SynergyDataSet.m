classdef SynergyDataSet < handle
    %SYNERGYDATASET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        synergyData;
    end
    
    methods
        function obj = initBySynergyData(obj, synergyData)
            obj.synergyData = synergyData;
        end
        
        function matchedWithSensitivities = matchSensitivities(obj, sensitivityData)
            
            synergyClass = str2func(class(obj));
            
            joinedSynergy = innerjoin(obj.synergyData, sensitivityData.pIc50Data,...
                'LeftVariables', {'cellLine', 'drugA', 'drugB', 'synergy'},...
                'RightVariables', {'pIc50'},...
                'LeftKeys', {'cellLine', 'drugA'},...
                'RightKeys', {'cellLine', 'drug'});
            joinedSynergy.Properties.VariableNames{'pIc50'} = 'pIc50A';
            
            if (isempty(joinedSynergy))
                matchedWithSensitivities = synergyClass();
                matchedWithSensitivities.initBySynergyData(joinedSynergy);
                return;
            end
            
            joinedSynergy = innerjoin(joinedSynergy, sensitivityData.pIc50Data,...
                'LeftVariables', {'cellLine', 'drugA', 'pIc50A', 'drugB', 'synergy'},...
                'RightVariables', {'pIc50'},...
                'LeftKeys', {'cellLine', 'drugB'},...
                'RightKeys', {'cellLine', 'drug'});
            joinedSynergy.Properties.VariableNames{'pIc50'} = 'pIc50B';
            
            matchedWithSensitivities = synergyClass();
            matchedWithSensitivities.initBySynergyData(joinedSynergy);
            return;
        end
        
        function sensitivityTable = extractSensitivities(obj)
            synergyValueCount = height(obj.synergyData);
            sensitivityValueCount = 2 * synergyValueCount;
            
            cellLine = zeros(sensitivityValueCount, 1);
            drug     = zeros(sensitivityValueCount, 1);
            pIc50    = zeros(sensitivityValueCount, 1);
            
            cellLine = [obj.synergyData.cellLine; obj.synergyData.cellLine];
            drug     = [obj.synergyData.drugA; obj.synergyData.drugB];
            pIc50    = [obj.synergyData.pIc50A; obj.synergyData.pIc50B];
            
            sensitivityTable = table(cellLine, drug, pIc50);
        end
        
    end
    
end

