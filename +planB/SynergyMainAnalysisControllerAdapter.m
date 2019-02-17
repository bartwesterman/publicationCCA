classdef SynergyMainAnalysisControllerAdapter < planB.BaseMainAnalysisControllerAdapter
    %MAINANALYSISCONTROLLERADAPTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = init(obj, mac)            
            init@planB.BaseMainAnalysisControllerAdapter(obj, mac, planB.DreamSynergyData().init(mac.entityManager));            
        end
        

    end
    
end

