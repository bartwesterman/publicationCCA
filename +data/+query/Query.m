classdef (Abstract) Query < handle
    %QUERY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        sqlString = compileToSql(obj);
    end
    
end

