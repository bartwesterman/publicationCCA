classdef PathwayAnalysisController < analysis.BaseAnalysisController
    %PATHWAYANALYSISCONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        keggApi;
        targetData;

        neuralPathwayLearner;
    end
    
    methods
        
        function initKeggApi(obj)
            disp('initKeggApi()');
            obj.keggApi = data.pathway.KeggApi().init();
        end
                
        function initTargetData(obj)
            obj.targetData = data.DreamTargetData().init(obj.thesauri);
        end
           
        function entityId = keggIdsToEntityId(obj, label, keggIds, keggType)
%             nameSet = obj.keggApi.keggIdToNameSet(keggId);
%             nameIsKnownSet = cellfun(@(name) obj.thesauri.contains(name), nameSet);
% 
%             knownNameIndex = find(nameIsKnownSet);
%             
%             if (~isempty(knownNameIndex))
%                 name = nameSet{knownNameIndex};
%             else
%                 name = nameSet{1};            
%             end
%             
%             type = Config.KEGG_TYPE_TO_WESTERMAN_TYPE.(keggType);

            synonymArray = {['unknown' num2str(rand(1)) num2str(rand(1))]};
            if ~strcmp(keggIds, 'unknown')
                synonymArray = vertcat( {label},keggIds );
            end

            entityId = obj.thesauri.unsafeSynonymArrayInsert('kegg', synonymArray);
            
            % entityId = obj.thesauri.acquireEntityId(keggId, 'kegg');            
        end
        
        function prediction = generatePrediction(obj, exampleList)
            
            prediction = zeros(size(exampleList, 1), 1);
            disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'PathwayAnalysisController making prediciton ' num2str(length(prediction))]);
            
            for i = 1:length(prediction)
                if (mod(i, 50) == 1)
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'PathwayAnalysisController prediction loop' num2str(length(prediction))]); 
                end
                outputArray = obj.neuralPathwayLearner.produceFinalOutput(exampleList(i, :));
                if (mod(i, 50) == 1)
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'PathwayAnalysisController prediction loop; output produced' num2str(length(prediction))]); 
                end
                prediction(i) = outputArray{end}(1);
                if (mod(i, 50) == 1)
                    disp([datestr(now, 'yyyy_mm_dd_HH:MM:SS') 'PathwayAnalysisController prediction extracted' num2str(length(prediction))]); 
                end
            end
        end

        function training(obj, exampleList, target)

%            obj.neuralPathwayLearner.recursionDepth = 6;

%            obj.neuralPathwayLearner.train(1, exampleList, target);
            
%             totalTime = (60 * 60 * .05 );
%             
%             trainingCycleCount = totalTime / timePerTrainingCycle; 

            trainingCycleCount = 1;

            timeToStopTraining = addtodate(now, 4, 'hour');
            
            while (now < timeToStopTraining)
                selectedIndex = randi([1 length(exampleList)]);
                obj.neuralPathwayLearner.train(trainingCycleCount, exampleList(selectedIndex, :), target(selectedIndex, :));
            end
            
            disp('TRAINING COMPLETE');
        end
        
        function trainingStep(obj, exampleList, target, batchSize)

%            obj.neuralPathwayLearner.recursionDepth = 6;

%            obj.neuralPathwayLearner.train(1, exampleList, target);
            
%             totalTime = (60 * 60 * .05 );
%             
%             trainingCycleCount = totalTime / timePerTrainingCycle; 

            trainingCycleCount = 1;
            
            selectedExampleIndexes = randsample(1:length(target), batchSize);
            
            obj.neuralPathwayLearner.train(trainingCycleCount, exampleList(selectedExampleIndexes, :), target(selectedExampleIndexes, :));

        end
        function [importanceSortedEntityIds, sortedNeuronImportance] = identifyImportantNodes(obj, exampleSet)
            [neuronImportance, weightImportance] = obj.neuralPathwayLearner.determineImportance(exampleSet);
            
            entityIdOrder = obj.trainingSetBuilder.entityIdOrder;
            
            [sortedNeuronImportance, sortedNeuronIndexes] = sort(neuronImportance, 'descend');
            
            importanceSortedEntityIds = entityIdOrder(sortedNeuronIndexes);
        end
        
        function learner = getLearner(obj)
            learner = obj.neuralPathwayLearner;
        end
    end
    
end

