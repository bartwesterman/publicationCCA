classdef DataSource < handle
    %DATASOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesauri;

        pathwayEntityIds;

        exampleData;
        
        expressionData;
        mutationData;
        
    end
    
    methods
        function obj = init(obj, thesauriNames, thesauriPath, allPathwayPath, dreamMutationFilePath, dreamExpressionFilePath, dreamSynergyDataFilePath, dreamLethalityPath, dreamQualityTablePath)
            
            if ~exist('thesauriNames','var'),            thesauriNames             = Config.THESAURI_NAMES;                      end
            if ~exist('thesauriPath','var'),             thesauriPath              = Config.THESAURI_PATH;                       end
            if ~exist('allPathwayPath','var'),           allPathwayPath            = Config.ALL_PATHWAY_PATH;                    end
            if ~exist('dreamMutationFilePath','var'),    dreamMutationFilePath     = Config.DREAM_CELLLINE_MUTATION;             end
            if ~exist('dreamExpressionFilePath','var'),  dreamExpressionFilePath   = Config.DREAM_CELLLINE_EXPRESSION;           end
            
            obj.initThesauri(thesauriNames, thesauriPath, allPathwayPath);
            obj.mutationData      = data.DreamMutation().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'), dreamMutationFilePath);
            obj.expressionData    = data.DreamGeneExpression().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'), dreamExpressionFilePath);            
        end
        
        function initThesauri(obj, thesauriNames, thesauriPath, allPathwayPath)
            obj.thesauri = data.EntityManager().init();
            
            for i = 1:length(thesauriNames)
                type = thesauriNames{i};
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') ' initializing thesaurus:' thesauriPath type '.ths']);
                synonymArrayArray = data.thsread([thesauriPath type '.ths']);
                obj.thesauri.unsafeThesaurusInsert(type, synonymArrayArray);
            end

            obj.pathwayEntityIds = full(data.pathway.KeggPathway.expandThesaurusFromKGML(obj.thesauri, allPathwayPath));
        end
        function exampleSet = createExampleSet(obj)
            indexToEntityId = obj.getEntityIds();
            exampleCount   = obj.exampleData.getExampleCount();
            
            exampleSet = planB.ExampleSet().init(indexToEntityId, exampleCount, obj.thesauri);
            
            for exampleIndex = 1:exampleCount
                [essentialEntityIds, essentialValues, cellLineId] = obj.exampleData.getExampleData(exampleIndex);
                
                mutationIds   = -obj.mutationData.getCellLineMutations(cellLineId);
                expressionIds = obj.expressionData.getCellLineExpression(cellLineId);
                
                entityIds = [ essentialEntityIds ; mutationIds             ; expressionIds];
                values    = [ essentialValues    ; ones(size(mutationIds)) ; ones(size(expressionIds))];
                
                exampleSet.addToExampleMatrixRow(exampleIndex, entityIds, values);
            end
        end
        
        function [indexToEntityId] = getEntityIds(obj)
            baseExampleEntityIds = obj.exampleData.getEntityIds();
            
            mutationEntityIds   = -obj.mutationData.getUniqueMutations();
            expressionEntityIds = obj.expressionData.getUniqueExpressedGenes();
                        
            indexToEntityId = [baseExampleEntityIds ; mutationEntityIds ; expressionEntityIds];
        end
    end
    
end

