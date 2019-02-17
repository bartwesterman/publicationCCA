classdef StructToolkit
    %STRUCTTOOLKIT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function merged = cat(varargin)
            merged = struct;
            
            for i = 1:nargin
                next = varargin(i);
                fields = fieldnames(next);
                
                for j = 1:size(fields, 1)
                    field = fields(j);
                    if ~isfield(merged, field)
                        merged.(field) = zeros(0);
                    end
                    merged.(field) = vertcat(merged.(field), next.(field));
                end
            end
        end
    end
    
end

