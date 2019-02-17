function combineAnalysisResults( resultFilePath, varargin )
%COMBINEANALYSISRESULTS Summary of this function goes here
%   Detailed explanation goes here
    nn = planB.NeuralNetwork(); % so the compiler knows this class should be loaded

    inputPaths = varargin;
    
    files = cell(length(inputPaths));
    
    for i = 1:length(inputPaths)
        path = inputPaths{i};
        f = dir([path '*.mat']);
        folder = repmat({path}, size(f, 1), 1);
        [f.folder] = folder{:};
        files{i} = f;
    end
    files = vertcat(files{:});
    fileNames = {files.name}';
    paths     = {files.folder}';
    filePaths = strcat(paths, '/', fileNames);
    
    results = cell(size(filePaths, 1), 1);
    for i = 1:size(filePaths, 1)
        filePath = filePaths{i};
        
        load(filePath, 'result');
        results{i} = result;
    end
        
    save(resultFilePath, 'result', '-v7.3');
    

end

