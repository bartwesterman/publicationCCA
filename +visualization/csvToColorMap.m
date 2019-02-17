function colorMap = csvToColorMap( filePath )
%CSVTOCOLORMAP Summary of this function goes here
%   Detailed explanation goes here

    colorMap = containers.Map;
    
    csvArray = data.csvread(filePath);
    
    for i = 1:size(csvArray, 1)
        csvRow = csvArray(i, :);
        
        name  = csvRow{2};
        
        assert(~strcmp(name, ''), ['name may not be empty! column with empty name: ' i]);
        
        red   = str2num(csvRow{3});
        green = str2num(csvRow{4});
        blue  = str2num(csvRow{5});
        
        colorMap(name) = [red green blue];
    end
end

