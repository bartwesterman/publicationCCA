classdef Union < Query
    %UNION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        leftSelect;
        rightSelect;
        isAll;
    end
    
    methods
        function obj = Union(leftSelect, rightSelect, isAll)
            if (nargin < 4)
                isAll = false;
            end
            if (nargin < 3)
                rightSelect = [];
            end
            
            if (nargin < 2)
                leftSelect = [];
            end
            
            
            obj.leftSelect = leftSelect;
            obj.rightSelect = rightSelect;
            obj.isAll = isAll;
        end
        
        function sqlString = compileToSql(obj)
            
            leftString = obj.leftSelect.compileToSql();
            rightString = obj.rightSelect.compileToSql();
            
            unionFragment = ' UNION ';
            
            if (obj.isAll)
                unionFragment = ' UNION ALL ';
            end
            
            sqlString = ['( ' leftString ' ) ' unionFragment ' ( ' rightString ' ) '];
        end
    end
    
end

