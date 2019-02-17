classdef Repository < handle
    %REPOSITORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesauri;
        
        dreamSynergies;
        dreamPIc50s;
        
    end
    
    methods (Access=public)
        
        function obj = initLoad(obj)
                  
            for i= 1:200
                sqlite3.close()
            end
            delete(Config.DATABASE_FILEPATH);
            sqlite3.open(Config.DATABASE_FILEPATH);
            
            obj.thesauri = data.ThesaurusRepository().initLoad();
            
            obj.initDataRepositories();
        end
        
        
        function obj = initNoDatabase(obj)
            obj.thesauri = data.EntityManager().init();
            
            for i = 1:length(Config.THESAURI_NAMES)
                type = Config.THESAURI_NAMES{i};
                synonymArrayArray = data.thsread([Config.THESAURI_PATH type '.ths']);
                obj.thesauri.unsafeThesaurusInsert(type, synonymArrayArray);
            end
            
            obj.initDataRepositories();            
        end
        
        
        function obj = initLink(obj)
            obj.thesauri = data.ThesaurusRepository().initLink();
            
            obj.initDataRepositories();
        end
    end
    
    methods (Access=private)
        function obj = initDataRepositories(obj)
            
            obj.dreamSynergies           = data.DreamSynergyData().init(obj.thesauri);
            obj.dreamPIc50s              = data.SensitivityDataSet().initBySensitivityData(obj.dreamSynergies.extractSensitivities());
            
        end    
    end
end

