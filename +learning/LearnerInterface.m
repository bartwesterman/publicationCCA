classdef (Abstract) LearnerInterface < handle
    %ABSTRACTLEARNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        train(obj, examples)
        prediction = predict(obj, X)
    end
    
end

