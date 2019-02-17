classdef CellCleaners
    %DREAMCHALLENGECELLCLEANERS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        % cells in the dream challenge data that should contain numbers
        % often also contain "". So a special conversion function is
        % necessary to parse them.
        function n = cleanNumeric(c, varargin)

            
            
            if (isa(c, 'numeric')) 
                n = c;
                return;
            end

            if (isa(c, 'char'))
                n = str2num(strrep(c, '"', ''));
                return;
            end
            celldisp(c)
            
            cClass = class(c);
            
            errorMessage = strcat('Cannot convert cell value to number. Cell value has class ', cClass);
            
            throw(MException('dream:CellCleaners:cleanNumeric',errorMessage));
        end
    end
    
end

