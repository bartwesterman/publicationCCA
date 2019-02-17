classdef Csv
    %ABSTRACTDATALOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function lineArray = load(fileName,delimiter)
            import utils.*;
            
            lineArray = cell(0);          % Create a cell array 

            fid = fopen(fileName,'r');   % Open the file
            lineIndex = 1;               % Index of cell to place the next line in
            while true
                nextLine = fgetl(fid);   % Read the first line from the file

                if isequal(nextLine,-1)  % Loop while not at the end of the file
                    break;
                end

                rowContents = Csv.parseLine(nextLine, delimiter);  %# Add the line to the cell array
                for columnIndex = 1:length(rowContents)
                    lineArray{lineIndex, columnIndex} = rowContents{columnIndex};
                end
                lineIndex = lineIndex+1; % Increment the line index
            end
            fclose(fid);                 % Close the file

        end
        
        function lineData = parseLine(line, delimiter)
            
            lineData = textscan(line,'%s', 'Delimiter', delimiter);
            lineData = lineData{1};              %# Remove cell encapsulation
            if strcmp(line(end),delimiter)  %# Account for when the line
              lineData{end+1} = '';                     %#   ends with a delimiter
            end
        end
        
        function write(fileName, csvCellMatrix)
            fileID = fopen(fileName,'w');
            
            [width, height] = size(csvCellMatrix);
            
            for x = 1:width
                for y = 1:height
                    fwrite(fileID,num2str(csvCellMatrix{x,y}));
                    
                    if (y < height)
                        fwrite(fileID, ',');
                    end
                end
                fwrite(fileID, sprintf('\n'));
            end
            fclose(fileID);
        end
    end
    
end

