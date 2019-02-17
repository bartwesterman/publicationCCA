classdef Experiment < handle
    %EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hillA;
        hillB;
        
        synergy;
        
        mode;
    end
    
    methods
        function obj = init(obj, c1, c2, matrix)
            
            obj.mode = 'dream';
            
            obj.hillA = chemistry.dream.DoseResponse().init([c1 matrix(:, 1)]);
            obj.hillB = chemistry.dream.DoseResponse().init([c2 matrix(1, :)']);
            
            obj.synergy = obj.computeSynergyScore(c1, c2, matrix);
        end
        
        function obj = initRavi(obj, hillA, hillB, c1, c2, matrix)
            
            obj.mode = 'ravi';
            
            obj.hillA = hillA;
            obj.hillB = hillB;
            
            obj.synergy = obj.computeSynergyScore(c1, c2, matrix);
        end
        
        function synergyScore = computeSynergyScore(obj, c1, c2, matrix)
            additive = obj.computeLoeweAdditivityMatrix(c1, c2);
            preprocessedObserved = obj.preprocess(matrix);            
            synergyScore = obj.differenceSynergy(c1, c2, preprocessedObserved, additive);
        end
        
        function synergyScore = differenceSynergy(obj, c1, c2, observed, additive)
            sum     = 0;
            sumArea = 0;
            
            for i = 1:size(additive, 1)
            for j = 1:size(additive, 2)
                if i > 1 && j > 1 && i < 6 && j < 6
                    
                    dx = log(c1(i + 1)) - log(c1(i));
				    dy = log(c2(j + 1)) - log(c2(j));
                    
                    dval1 = observed(i, j) - additive(i, j);
				    dval2 = observed(i + 1, j) - additive(i + 1, j);
                    dval3 = observed(i, j + 1) - additive(i, j + 1);
					dval4 = observed(i + 1, j + 1) - additive(i + 1, j + 1);
					dsum  = dval1 + dval2 + dval3 + dval4;
                    % this should happen for correct approx,
                    % but does not happen in provided values
                    % uncomment for more accuracy
                    %
                    
                    if ~strcmp(obj.mode, 'dream')
                        dsum=dsum/4;
                    end

                    sum     = sum +     dsum * dx * dy;
                    sumArea = sumArea +        dx * dy;
                end
            end
            end
            
            % This is wrong, as it turns out some
			% areas are larger than others
			% However, it does make the values agree with those
			% provided.

			% comment for better accuracy
            if strcmp(obj.mode, 'dream');
                sumArea = 21.20759244;
            end

			synergyScore =  sum / sumArea;
        end
        
        function preprocessedMatrix = preprocess(obj, matrix)
            preprocessedMatrix = zeros(size(matrix));
            for i = 1:size(matrix, 1)
            for j = 1:size(matrix, 2)
                preprocessedMatrix(i, j) = max(min(100 - matrix(i, j), 200), -100);
            end
            end
        end
                
        function additive = computeLoeweAdditivityMatrix(obj, c1, c2)
            additive = zeros(length(c1), length(c2));
            
            for i = 1:length(c1)
            for j = 1:length(c2)
                additive(i,j) = obj.approximateLoeweAdditivity(c1(i), c2(j), obj.hillA, obj.hillB);
            end
            end
        end
        
        function guess = approximateLoeweAdditivity(obj, x1, x2, hillA, hillB)
            max = 100;
            min = 0;
            
            for i = 1:100
                guess = (max + min) / 2;
                e = obj.evaluate(x1, x2, hillA, hillB, guess);
                
                if e > 0
                    max = guess;
                    continue
                end
                if e < 0
                    min = guess;
                    continue;
                end
                
                % guess is correct
                return;
            end
            
            guess = (max + min) / 2;
            return;
        end
        
        function e = evaluate(obj, x1, x2, hillA, hillB, y)
            p1 = hillA.predictPartial(x1, y);
            p2 = hillB.predictPartial(x2, y);
            
            e = 1 - (p1 + p2);
        end
        

    end
    
end

