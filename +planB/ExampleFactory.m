classdef ExampleFactory < handle
    %BASEMAINANALYSISCONTROLLERADAPTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataSource;
        exampleData;
    end
    
    methods
        function obj = init(obj, dataSource, exampleData)
            obj.dataSource = dataSource;
            obj.exampleData = exampleData;
        end
        
        function exampleSet = createExampleSet(obj)
            indexToEntityId = obj.getEntityIds();
            exampleCount   = obj.exampleData.getExampleCount();
            
            exampleSet = planB.ExampleSet().init(indexToEntityId, exampleCount, obj.dataSource.thesauri);
            
            nextStatusLineTime = 0;
            for exampleIndex = 1:exampleCount
                
                if posixtime(datetime('now')) > nextStatusLineTime
                    nextStatusLineTime = posixtime(datetime('now')) + 60;
                    disp([datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS') ' processsed ' num2str(exampleIndex) ' out of ' num2str(exampleCount) ' examples, in createExample(....)']);
                end
                
                [essentialEntityIds, essentialValues, cellLineId, drugAId, drugBId, exampleId] = obj.exampleData.getExampleData(exampleIndex);
                
                mutationIds   = -obj.dataSource.mutationData.getCellLineMutations(cellLineId);
                expression = obj.dataSource.expressionData.getCellLineExpression(cellLineId);
                
                entityIds = [ essentialEntityIds ; mutationIds             ; expression(:, 1)];
                values    = [ essentialValues    ; ones(size(mutationIds)) ; expression(:, 2)];
                
                exampleSet.addToExampleMatrixRow(exampleIndex, entityIds, values, exampleId, cellLineId, drugAId, drugBId);
            end
        end
        
        function [indexToEntityId] = getEntityIds(obj)
            baseExampleEntityIds = obj.exampleData.getEntityIds();
            
            mutationEntityIds   = -obj.dataSource.mutationData.getUniqueMutations();
            expressionEntityIds = obj.dataSource.expressionData.getUniqueExpressedGenes();
                        
            indexToEntityId = [baseExampleEntityIds ; mutationEntityIds ; expressionEntityIds];
        end
    end
    
end

