function array = removeEmpty( array )
%REMOVEEMPTY Summary of this function goes here
%   Detailed explanation goes here

    array = array(cellfun(@(v) ~isempty(v), array));
end

