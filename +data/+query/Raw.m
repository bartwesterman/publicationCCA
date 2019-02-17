classdef Raw < data.query.Query
    %RAWEXPRESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sqlString;
    end
    
    methods
        function obj = Raw(sqlString)
            obj.sqlString = sqlString;
        end
        
        function sqlString = compileToSql(obj)
            sqlString = obj.sqlString;
        end
        
    end
    
end

