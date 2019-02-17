classdef ResultTracker < handle
    %ResultTracker Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        resultFilePath;
        results;
        
        finalResultFilePath;
        finalResults;
        
        isInExperiment;
        currentExperiment;
    end
    
    methods
        function obj = init(obj, resultFilePath)
            % scopeLock = thread.FileLock('./resultTracker.lock');
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'resultTracker init']);
            
            obj.resultFilePath = resultFilePath;
            obj.finalResultFilePath = [resultFilePath '.final.mat'];
            
            obj.reloadFile();
            
            obj.isInExperiment = false;
            obj.currentExperiment = []; 
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'resultTracker initialized']);

            % scopeLock.delete();
        end
                
%         function freeLock(obj)
%             delete('./resultTracker.lock'); 
%         end
%         
%         function unassignIncompleteRows(obj)
%             obj.reloadFile();
%             
%             validIndexes = ~(obj.results.rootMeanSquareError < 0);
%             
%             unassignedTable                     = table();
%             unassignedTable.id                  = obj.results.id{validIndexes};
%             unassignedTable.rootMeanSquareError = obj.results.rootMeanSquareError(validIndexes);
%             unassignedTable.pearson             = obj.results.pearson(validIndexes);
%             unassignedTable.r2                  = obj.results.r2(validIndexes);
%             unassignedTable.adjustedR2          =  obj.results.adjustedR2(validIndexes);
%             
%             unassignedTable.rootMeanSquareErrorTC = obj.results.rootMeanSquareErrorTC(validIndexes);
%             unassignedTable.pearsonTC             = obj.results.pearsonTC(validIndexes);
%             unassignedTable.r2TC                  = obj.results.r2TC(validIndexes);
%             unassignedTable.adjustedR2TC          = obj.results.adjustedR2TC(validIndexes);
% 
%             obj.rewriteFile();
%         end
        
        function isUnassigned = startIfUnassigned(obj, experimentId)
            % scopeLock = thread.FileLock('./resultTracker.lock');
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'ResultTracker startIfUnassigned ' experimentId]);
            
            if obj.isInExperiment
                throw(MException('analysis:ResultTracker:startIfUnassigned', strcat('Attempting to start experiment, but already in experiment: ', experimentId)));
            end
            
            obj.reloadFile();
            
            isUnassigned = true;
            if ~obj.isUnassignedExperiment(experimentId)
                isUnassigned = false;
                return ;
            end
            
            obj.startExperiment(experimentId);
        end
        
        
        % @TODO: make this function and all members work for experimentIdForFold, bestRootMeanSquared, bestRootMeanSquaredTC, bestPearson, bestPearsonTC, bestR2, bestR2TC, bestAdjustedR2, bestAdjustedR2TC);
        function recordResult(obj, experimentId, parameters, foldId, foldIndex, rootMeanSquareError, rootMeanSquareErrorTC, pearson, pearsonTC, r2, r2TC, adjustedR2, adjustedR2TC, totalTrainingCycles, learnerHistory, errorHistory)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'ResultTracker recordResult ' foldId]);
            
            if ~obj.isInExperiment
                throw MException('analysis:ResultTracker:recordResult', strcat('Attempting to record experiment result, but not in experiment: ', id));
            end
            
            if ~strcmp(obj.currentExperiment, foldId)
                throw MException('analysis:ResultTracker:recordResult', strcat('Attempting to record wrong experiment result of ', id, ' instead of current experiment ', obj.currentExperiment ));
            end
            
            % scopeLock = thread.FileLock('./resultTracker.lock');
            obj.reloadFile();
            
            if isempty(obj.results)
                obj.results = obj.createEmptyResults();
            end
            
%             index = find(cellfun(@(v) strcmp(v, id), obj.results.id), 1);
%             
%             obj.results.id{index}                  = id;
%             obj.results.rootMeanSquareError(index) = rootMeanSquareError;
%             obj.results.pearson(index)             = pearson;
%             obj.results.r2(index)                  = r2;
%             obj.results.adjustedR2(index)          = adjustedR2;
%             
%             obj.results.rootMeanSquareErrorTC(index) = rootMeanSquareErrorTC;
%             obj.results.pearsonTC(index)             = pearsonTC;
%             obj.results.r2TC(index)                  = r2TC;
%             obj.results.adjustedR2TC(index)          = adjustedR2TC;
            
            experimentId = {experimentId};

            id = {foldId};
            parameters = {parameters};
            
            learnerHistory = {learnerHistory} ;
            errorHistory   = {errorHistory}   ;
            newRow = table(experimentId, parameters, id, foldIndex, rootMeanSquareError, pearson, r2, adjustedR2, rootMeanSquareErrorTC, pearsonTC, r2TC, adjustedR2TC, totalTrainingCycles, learnerHistory, errorHistory);
            
            obj.results = vertcat(obj.results, newRow);            
            obj.rewriteFile();
            
            obj.isInExperiment = false;
            obj.currentExperiment = [];
            % scopeLock.delete();
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'ResultTracker recorded result ' foldId]);
            
        end
        function isTrue = hasFinalResult(obj)
            isTrue = ~isempty(obj.finalResults);
        end
        function recordFinalResult(obj, parameters, rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2, learner)
            
            obj.finalResults = table(parameters, rootMeanSquaredError, pearsonCorrelation, r2, adjustedR2, learner);
            
            obj.rewriteFile();
        end
        
        function [parametersOfBestResult, trainingCycleCount] = getParametersOfBestResult(obj)
            averageAndVariance     = obj.buildTableOfAverageAndVariance();
            bestIndex              = obj.getBestFromTableOfAverageAndVariance(averageAndVariance);
            parametersOfBestResult = averageAndVariance.parameters(bestIndex);
            trainingCycleCount     = averageAndVariance.meanRootMeanSquareErrorTC(bestIndex);
        end
       
        
        function res = testBuildTableOfAverageAndVariance(obj)
            res = obj.buildTableOfAverageAndVariance();
        end
    end
    
    methods (Access = private)
        function isTrue = isUnassignedExperiment(obj, experimentId)
            
            if isempty(obj.results)
                isTrue = true;
                return;
            end
            
            isTrue = sum(cellfun(@(v) strcmp(experimentId, v), obj.results.id)) == 0;
        end
        function reloadFile(obj)
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'resultTracker reloadFile']);
            
            if exist(obj.resultFilePath, 'file') ~= 2
                return;
            end
            
            load(obj.resultFilePath, 'results');
            
            obj.results = results;
            
            if exist(obj.finalResultFilePath, 'file') ~= 2
                return;
            end
            
            load(obj.finalResultFilePath, 'finalResults');
            
            obj.finalResults = finalResults;

        end
        
        function rewriteFile(obj)
            results = obj.results;
            save(obj.resultFilePath, 'results', '-v7.3');
            
            finalResults = obj.finalResults;
            save(obj.finalResultFilePath, 'finalResults', '-v7.3');
        end
        
        function startExperiment(obj, id)
            % scope lock on file
            % scopeLock = thread.FileLock('./resultTracker.lock');
            
            obj.isInExperiment = true;
            obj.currentExperiment = id;
            % unlock
            % scopeLock.delete();
        end
        
        function t = createEmptyResults(obj)
            id = {};
            experimentId = {};
            parameters = {};
            foldIndex = [];
            rootMeanSquareError   = [];
            rootMeanSquareErrorTC = [];
            pearson               = [];
            pearsonTC             = [];
            r2                    = [];
            r2TC                  = []; 
            adjustedR2            = [];
            adjustedR2TC          = [];
            totalTrainingCycles   = [];
            learnerHistory        = {};
            errorHistory          = {};
            
            t = table(experimentId, parameters, id, foldIndex, rootMeanSquareError, rootMeanSquareErrorTC, pearson, pearsonTC, r2, r2TC, adjustedR2, adjustedR2TC, totalTrainingCycles, learnerHistory, errorHistory);
        end
        
        function averageAndVariance = buildTableOfAverageAndVariance(obj)
            function first = pickFirstCell(inputs)
                first = inputs{1};
            end
            
            crossValidationGroups = findgroups(obj.results.experimentId);
            meanRootMeanSquareError   = splitapply(@mean, obj.results.rootMeanSquareError, crossValidationGroups);
            meanRootMeanSquareErrorTC = splitapply(@mean, obj.results.rootMeanSquareErrorTC, crossValidationGroups);
            
            varRootMeanSquareError   = splitapply(@var, obj.results.rootMeanSquareError, crossValidationGroups);
            varRootMeanSquareErrorTC = splitapply(@var, obj.results.rootMeanSquareErrorTC, crossValidationGroups);
            
            
            parameters = splitapply(@pickFirstCell, obj.results.parameters, crossValidationGroups);
            
            averageAndVariance = table(parameters, meanRootMeanSquareError, meanRootMeanSquareErrorTC, varRootMeanSquareError, varRootMeanSquareErrorTC);
        end
        
        function bestIndex = getBestFromTableOfAverageAndVariance(obj, averageAndVariance)
            bestIndex = find(averageAndVariance.meanRootMeanSquareError == min(averageAndVariance.meanRootMeanSquareError));
        end
        
    end

end

