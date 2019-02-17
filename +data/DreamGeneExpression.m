classdef DreamGeneExpression < handle
    %DREAMGENEEXPRESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        cellLineToGeneExpressionMap;
       
        availableGenes;
    end
    
    methods
        
        function obj = init(obj, geneThesaurus, cellLineThesaurus, csvFilePath)
            if nargin == 3
                csvFilePath = Config.DREAM_CELLLINE_EXPRESSION;
            end
            
            rawData = table2cell(readtable(csvFilePath, 'ReadVariableNames', false));
            disp('read table');
            cellLineEntityIds = cellfun(@(v) cellLineThesaurus.getId(v), rawData(1, 2:end));
            geneEntityIds     = cellfun(@(v) geneThesaurus.getId(v),     rawData(2:end, 1));
            
            obj.availableGenes = geneEntityIds;
            
            geneToCellLineMatrix = cellfun(@str2double, rawData(2:end, 2:end));
            disp('converted expression strings to numbers');
            cellLineToGene = containers.Map('KeyType','int64','ValueType','any');
            
            for c = 1:length(cellLineEntityIds)
                nextGeneExpressionMap = containers.Map('KeyType','int64','ValueType','any');
                for g = 1:length(geneEntityIds)
                    geneId     = geneEntityIds(g);
                    
                    nextGeneExpressionMap(geneId) = geneToCellLineMatrix(g, c);
                end
                
                cellLineId = cellLineEntityIds(c);
                cellLineToGene(cellLineId) = nextGeneExpressionMap;
            end
            
            obj.cellLineToGeneExpressionMap = cellLineToGene;
        end
        
        function cellLineExpression = getCellLineExpression(obj, cellLineId)
            
            if ~obj.cellLineToGeneExpressionMap.isKey(cellLineId)
                cellLineExpression = zeros(0, 2);
                return;
            end
            
            geneExperessionMap = obj.cellLineToGeneExpressionMap(cellLineId);
            
            geneIdsCell  = geneExperessionMap.keys();
            
            cellLineExpression = zeros(length(geneIdsCell), 2);
            cellLineExpression(:, 1) = cell2mat(geneIdsCell);
            cellLineExpression(:, 2) = cell2mat(geneExperessionMap.values(geneIdsCell));
        end
        
        function genes = getUniqueExpressedGenes(obj)
            genes = unique(obj.availableGenes);
        end
    end
    
end

