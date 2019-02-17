classdef MainAnalysisController < handle
    %MAINANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        thesauri;
        
        % general data sources
        doseLethalityData;
        
        expressionData;
        mutationData;
        
        % for pathway analysis
        keggApi;
        targetData;
        
        pathwayEntityIds;
        
        pathwayConnectionMap;
        pathwayUnification;
        
        % analysis controllers for learners
        interPathwayAnalysisController;
        intraPathwayAnalysisController;
        
        % output
        intraPathwayResultTracker;
        interPathwayResultTracker;
        
        relevanceSortedEntityIds;
        randomForestGeneExpressionAnalysisResults;
                
        initThesauriCompleted;
        initDataSourcesCompleted;
        initKeggApiCompleted;
        initTargetDataCompleted;
        initMutationDataCompleted;            
        randomForestAnalysisCompleted;
        
        initPathwayUnificationCompleted;            
        initDoseLethalityDataCompleted;
        initPathwayConnectionMapCompleted;
        initExpressionDataCompleted;
        
        initOtherAnalysisControllersCompleted;
        
        initCompleted;
    end
    
    methods
        function obj = init(obj)
            if obj.initCompleted
                return;
            end
            obj.initThesauri();

            if strcmp(Config.stoppingPoint(), 'initThesauri')
                Config.stoppingPoint('');
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initThesauri reached'));
            end
            
            obj.initDataSources();
            if strcmp(Config.stoppingPoint(), 'initDataSources')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initDataSources reached'));
            end
            
            obj.initOtherAnalysisControllers();
            if strcmp(Config.stoppingPoint(), 'initOtherAnalysisControllers')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initOtherAnalysisControllers reached'));
            end
            obj.initResultTrackers(); % Called to prevent save file from corrupting
            
            obj.initCompleted = true;
            saveWorkspace;
        end
        
        function obj = initDataSources(obj)
            if obj.initDataSourcesCompleted
                return;
            end
            
            obj.initKeggApi();
            if strcmp(Config.stoppingPoint(), 'initKeggApi')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initKeggApi reached'));
            end
            obj.initTargetData();
            if strcmp(Config.stoppingPoint(), 'initTargetData')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initTargetData reached'));
            end
            obj.initMutationData();
            if strcmp(Config.stoppingPoint(), 'initMutationData')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initMutationData reached'));
            end
            obj.initDoseLethalityData();
            if strcmp(Config.stoppingPoint(), 'initDoseLethalityData')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initDoseLethalityData reached'));
            end
            obj.initExpressionData();
            if strcmp(Config.stoppingPoint(), 'initExpressionData')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initExpressionData reached'));
            end
            obj.initPathwayConnectionMap();
            if strcmp(Config.stoppingPoint(), 'initPathwayConnectionMap')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initPathwayConnectionMap reached'));
            end
            obj.initPathwayUnification();  
            if strcmp(Config.stoppingPoint(), 'initPathwayUnification')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point initPathwayUnification reached'));
            end
            obj.initDataSourcesCompleted = true;
            saveWorkspace;
        end
        
        function obj = initThesauri(obj)
            if obj.initThesauriCompleted
                return;
            end
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') ' initThesauri()']);
            obj.thesauri = data.EntityManager().init();
            
            for i = 1:length(Config.THESAURI_NAMES)
                type = Config.THESAURI_NAMES{i};
                disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') ' initializing thesaurus:' Config.THESAURI_PATH type '.ths']);
                synonymArrayArray = data.thsread([Config.THESAURI_PATH type '.ths']);
                obj.thesauri.unsafeThesaurusInsert(type, synonymArrayArray);
            end

            obj.pathwayEntityIds = full(data.pathway.KeggPathway.expandThesaurusFromKGML(obj.thesauri, Config.ALL_PATHWAY_PATH));
            
            % load digre path if you want to see some quick results
            % data.pathway.KeggPathway.expandThesaurusFromKGML(obj.thesauri, Config.DIGRE_PATHWAY_PATH);
            
            obj.initThesauriCompleted = true;
            saveWorkspace;
        end
        
%         function expandThesaurusFromKGML(obj, kgmlFilePathArray)
%             for i = 1:length(kgmlFilePathArray)
%                 nextKgmlFilePath = kgmlFilePathArray(i).name;
%                 
%                 domTree = xmlread([Config.SELECTED_PATHWAY_PATH nextKgmlFilePath]);
%                 
%                 entries = domTree.getElementsByTagName('entry');
%                
%                 for j = 0:(entries.getLength() - 1)
%                     entry = entries.item(j);
%                     
%                     keggIds = strsplit(char(entry.getAttribute('name')), ' ');
%                     
%                     obj.thesauri.mergeSynonymArrayInsert('kegg', keggIds);
%                 end
%             end
%         end
        
        function obj = initDoseLethalityData(obj)
            disp('initDoseLethalityData()');
            if obj.initDoseLethalityDataCompleted
                return;
            end
            obj.doseLethalityData = data.DreamDrugDoseLethalityData().init(obj.thesauri);
            obj.initDoseLethalityDataCompleted = true;
            saveWorkspace;
        end
        
        function obj = initExpressionData(obj)
            disp('initExpressionData()');
            if obj.initExpressionDataCompleted
                return;
            end
            obj.expressionData = data.DreamGeneExpression().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'));
            obj.initExpressionDataCompleted = true;
            saveWorkspace;
        end
        
        function obj = initMutationData(obj)
            disp('initMutationData()');
            if obj.initMutationDataCompleted
                return;
            end
            obj.mutationData = data.DreamMutation().init(obj.thesauri.get('kegg'), obj.thesauri.get('cellLine'));
            obj.initMutationDataCompleted = true;
            saveWorkspace;
        end
        
        
        function obj = initKeggApi(obj)
            disp('initKeggApi()');
            if obj.initKeggApiCompleted
                return;
            end
            obj.keggApi = data.pathway.KeggApi().init();
            
            obj.initKeggApiCompleted = true;
            saveWorkspace;
        end
                
        function obj = initTargetData(obj)
            if obj.initTargetDataCompleted
                return;
            end
            obj.targetData = data.DreamTargetData().init(obj.thesauri);
            
            obj.initTargetDataCompleted = true;
            saveWorkspace;
        end
           
        function entityId = keggIdsToEntityId(obj, label, keggIds, keggType)
%             nameSet = obj.keggApi.keggIdToNameSet(keggId);
%             nameIsKnownSet = cellfun(@(name) obj.thesauri.contains(name), nameSet);
% 
%             knownNameIndex = find(nameIsKnownSet);
%             
%             if (~isempty(knownNameIndex))
%                 name = nameSet{knownNameIndex};
%             else
%                 name = nameSet{1};            
%             end
%             
%             type = Config.KEGG_TYPE_TO_WESTERMAN_TYPE.(keggType);

            synonymArray = {['unknown' num2str(rand(1)) num2str(rand(1))]};
            if ~strcmp(keggIds, 'unknown')
                synonymArray = vertcat( {label},keggIds );
            end

            entityId = obj.thesauri.unsafeSynonymArrayInsert('kegg', synonymArray);
            
            % entityId = obj.thesauri.acquireEntityId(keggId, 'kegg');            
        end
        
        
        function obj = initPathwayConnectionMap(obj)
            if obj.initPathwayConnectionMapCompleted
                return;
            end
            obj.runRandomForestExpressionAnalysis();
            if strcmp(Config.stoppingPoint(), 'runRandomForestExpressionAnalysis')
                Config.stoppingPoint('');
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point runRandomForestExpressionAnalysis reached'));
            end
            
            obj.pathwayConnectionMap = data.pathway.KeggInterPathwayConnectionMap().init(obj.thesauri.get('kegg'), Config.ALL_PATHWAY_PATH, obj.targetData.targetData, obj.doseLethalityData.getUniqueCellLineIds(), obj.mutationData, obj.relevanceSortedEntityIds(1:min(end, Config.GENE_EXPRESSION_TO_PATHWAY_ACTIVATION_COUNT)));
            
            obj.initPathwayConnectionMapCompleted = true;
            saveWorkspace;
        end
        
        function obj = initPathwayUnification(obj)
            disp('initPathwayUnification()');
            
            obj.pathwayUnification = data.pathway.KeggPathway().init(obj.thesauri.get('kegg'));

            obj.pathwayUnification.loadFolder(Config.SELECTED_PATHWAY_PATH);
            
        end
        
        function obj = initResultTrackers(obj)
            obj.interPathwayResultTracker = analysis.ResultTracker();
            obj.interPathwayResultTracker.init(Config.INTER_PATHWAY_RESULT_TRACKER_FILE_PATH);
            
            obj.intraPathwayResultTracker = analysis.ResultTracker();
            obj.intraPathwayResultTracker.init(Config.INTRA_PATHWAY_RESULT_TRACKER_FILE_PATH);
        end
        
        function obj = initOtherAnalysisControllers(obj)
            if obj.initOtherAnalysisControllersCompleted
                return;
            end
            
            obj.interPathwayAnalysisController = analysis.InterPathwayAnalysisController();
            obj.interPathwayAnalysisController.initWithDataSources(obj.thesauri, obj.keggApi, obj.targetData, obj.pathwayConnectionMap, obj.doseLethalityData, obj.expressionData, obj.mutationData);
            
            obj.intraPathwayAnalysisController = analysis.IntraPathwayAnalysisController() ;
            obj.intraPathwayAnalysisController.initWithDataSources(obj.thesauri, obj.keggApi, obj.targetData, obj.pathwayUnification,   obj.doseLethalityData, obj.expressionData, obj.mutationData);
            
            obj.initOtherAnalysisControllersCompleted = true;
            saveWorkspace;
        end
        
        function runRandomForestExpressionAnalysis(obj)
            if obj.randomForestAnalysisCompleted
                return;
            end
            randomForestAnalysisController = analysis.RandomForestAnalysisController();
            randomForestAnalysisController.initWithDataSources(obj.thesauri, obj.doseLethalityData, obj.expressionData, full(obj.pathwayEntityIds));
            
            obj.randomForestGeneExpressionAnalysisResults = randomForestAnalysisController.run();
            
            obj.relevanceSortedEntityIds = obj.randomForestGeneExpressionAnalysisResults.importance.entityId;

            obj.randomForestAnalysisCompleted = true;
            saveWorkspace;
        end
        
        function run(obj)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'run']);
            obj.initResultTrackers();
            
            obj.interPathwayAnalysisController.run(obj.interPathwayResultTracker);
            if strcmp(Config.stoppingPoint(), 'interPathwayAnalysisController.run')
                Config.stoppingPoint('');                
                throw(MException('MainAnalysisController:stoppingPoint','Stopping point interPathwayAnalysisController.run reached'));
            end
            obj.intraPathwayAnalysisController.run(obj.intraPathwayResultTracker);
        end
        
        function runJustInterPathway(obj)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'runJustInterpathway']);
            obj.initResultTrackers();
            
            obj.interPathwayAnalysisController.run(obj.interPathwayResultTracker);
        end
    end
    
end

