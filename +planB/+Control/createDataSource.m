function obj = createDataSource(targetFileName, dreamMutationFilePath, dreamExpressionFilePath, allPathwayPath, thesauriPath, varargin)
%CREATEDATASOURCE Summary of this function goes here
%   Detailed explanation goes here
    if nargin > 5
        thesauriNames = varargin;
    end

    if ~exist('thesauriNames','var'),            thesauriNames             = Config.THESAURI_NAMES;                      end
    if ~exist('thesauriPath','var'),             thesauriPath              = Config.THESAURI_PATH;                       end
    if ~exist('allPathwayPath','var'),           allPathwayPath            = Config.ALL_PATHWAY_PATH;                    end
    if ~exist('dreamMutationFilePath','var'),    dreamMutationFilePath     = Config.DREAM_CELLLINE_MUTATION;             end
    if ~exist('dreamExpressionFilePath','var'),  dreamExpressionFilePath   = Config.DREAM_CELLLINE_EXPRESSION;           end
    if ~exist('dreamSynergyDataFilePath','var'), dreamSynergyDataFilePath  = Config.DREAM_MONO_AND_COMBINATION_TRAINING; end
    if ~exist('dreamLethalityPath','var'),       dreamLethalityPath        = Config.DREAM_COMBINATIONS_PATH;             end
    if ~exist('dreamQualityTablePath','var'),    dreamQualityTablePath     = Config.DREAM_MONO_AND_COMBINATION_TRAINING; end
    
    obj = planB.DataSource().init(thesauriNames, thesauriPath, allPathwayPath, dreamMutationFilePath, dreamExpressionFilePath, dreamSynergyDataFilePath, dreamLethalityPath, dreamQualityTablePath);
    
    save(targetFileName, 'obj', '-v7.3');
end

