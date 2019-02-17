classdef MainAnalysisControllerAdapter < handle
    %BASEMAINANALYSISCONTROLLERADAPTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mac;
        exampleData;
    end
    
    methods
        function obj = init(obj, mac, exampleData)
            obj.mac = mac;
            obj.exampleData = exampleData;
            
            % make compiler know that this file depends on
            % MainAnalysisController:
            compilerInfo = analysis.MainAnalysisController();
        end
        
        function exampleSet = createExampleSet(obj)
            indexToEntityId = obj.getEntityIds();
            exampleCount   = obj.exampleData.getExampleCount();
            
            exampleSet = planB.ExampleSet().init(indexToEntityId, exampleCount, obj.mac.thesauri);
            
            for exampleIndex = 1:exampleCount
                [essentialEntityIds, essentialValues, cellLineId] = obj.exampleData.getExampleData(exampleIndex);
                
                mutationIds   = -obj.mac.mutationData.getCellLineMutations(cellLineId);
                expressionIds = obj.mac.expressionData.getCellLineExpression(cellLineId);
                
                entityIds = [ essentialEntityIds ; mutationIds             ; expressionIds];
                values    = [ essentialValues    ; ones(size(mutationIds)) ; ones(size(expressionIds))];
                
                exampleSet.addToExampleMatrixRow(exampleIndex, entityIds, values);
            end
        end
        
        function [indexToEntityId] = getEntityIds(obj)
            baseExampleEntityIds = obj.exampleData.getEntityIds();
            
            mutationEntityIds   = -obj.mac.mutationData.getUniqueMutations();
            expressionEntityIds = obj.mac.expressionData.getUniqueExpressedGenes();
                        
            indexToEntityId = [baseExampleEntityIds ; mutationEntityIds ; expressionEntityIds];
        end
    end
    
end

