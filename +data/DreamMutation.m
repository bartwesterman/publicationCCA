classdef DreamMutation < handle
    %DREAMMUTATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mutationData;
    end
    
    methods
        function obj = init(obj, geneThesaurus, cellLineThesaurus, csvFilePath)
            if nargin == 3
                csvFilePath = Config.DREAM_CELLLINE_MUTATION;
            end
            
            rawData = readtable(csvFilePath);
                        
            cellLine = cellLineThesaurus.getIds(rawData.cell_line_name);
            gene     = geneThesaurus.getIds(rawData.Gene_name);
            
            obj.mutationData = table(cellLine, gene);
        end
        
        function cellLineMutations = getCellLineMutations(obj, cellLineId)
            cellLineMutations      = obj.mutationData.gene(obj.mutationData.cellLine == cellLineId);
        end
                
        function genes = getUniqueMutations(obj)
            genes = unique(obj.mutationData.gene);
        end
    end
    
end

