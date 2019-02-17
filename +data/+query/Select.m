classdef Select
    %SELECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        selectVar;
        fromVar;
        whereVar;
    end
    
    methods
        
        function obj = Select()
            obj.select = {};
            obj.from = [];
            obj.where = [];
        end
        
        function obj = select(obj, condition)
            obj.select = horzcat(obj.select, condition);
        end

        function obj = from(obj, table)
            obj.from = table;
        end
        
        function obj = where(obj, condition)
            obj.where = condition;
        end
        
        function sqlString = compileToSql(obj)
            
            selectString = ['SELECT ' strjoin( cellfun(@(v) v.compileToSql(), obj.selectVar))];
            
            fromString = '';
            if (~isempty(obj.fromVar))
                fromString = [' FROM ' obj.fromVar.compileToSql];
            end
            
            whereString = '';
            if (~isempty(obj.whereVar))
                fromString = [' WHERE ' obj.whereVar.compileToSql];
            end
            sqlString = [selectString fromString whereString];
        end
        
    end
    
end

