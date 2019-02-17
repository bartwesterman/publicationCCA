classdef ThesaurusRepository < handle
    %THESAURUSMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        thesaurus;
    end
    
    methods
        function obj = initLoad(obj)
            obj.thesaurus = struct();

            for name = Config.THESAURI_NAMES
                name = name{1};
                newThesaurus = data.Thesaurus().initLoad(name, [Config.THESAURI_PATH name '.ths']);
                newThesaurus.completeConstruction();
                obj.add(name, newThesaurus);
            end   
        end
        
        function obj = initLink(obj)
            nameCellArray = Config.THESAURI_NAMES;
            obj.thesaurus = struct();

            for name = nameCellArray
                
                newThesaurus = data.Thesaurus().initLink(name{1});
                
                obj.add(name{1}, newThesaurus);
            end   
        end
        
        function add(obj, name, thesaurus)
            obj.thesaurus.(name) = thesaurus;
        end
        function thesaurus = get(obj, name)
            thesaurus = obj.thesaurus.(name);
        end
    end
    
end

