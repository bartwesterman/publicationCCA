classdef ReversibleReaction < handle
    %REACTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kRateConstantLeft;
        stochiometricCoefficientsLeft;
        partialOrderReactantLeft; % not the partial order we know in math but the one in chemistry
        
        kRateConstantRight;
        stochiometricCoefficientsRight;
        partialOrderReactantRight; % not the partial order we know in math but the one in chemistry
        
        previousStateChange;
        previousRateLeft;
        previousRateRight;
    end
    
    methods
        function stateChange = timeCycle(obj, state)
            rateLeft = obj.kRateConstantLeft * state .^ obj.partialOrderReactantLeft;
            
            obj.previousRateLeft  = rateLeft;
            
            stateChangeLeft = rateLeft * (state .* obj.stochiometricCoefficientsLeft);
            
            rateRight = obj.kRateConstantRight * state .^ obj.partialOrderReactantRight;
            obj.previousRateRight = rateRight;
            
            stateChangeRight = rateRight * (state .* obj.stochiometricCoefficientsRight);
            
            
            stateChange = stateChangeLeft + stateChangeRight;
            obj.previousStateChange = stateChange;
        end
        
        function inputStateErrors = backpropagateError(obj, outputStateErrors)
            inputStateErrors = outputStateErrors .* obj.previousStateChange;
        end
        
        function parameterChange(obj, inputState, outputStateErrors)
            
            stochiometricCoefficientsLeftError = obj.previousRateLeft * (obj.stochiometricCoefficientsLeft .* outputStateErrors);
            
            rateLeftError = sum(obj.stochiometricCoefficientsLeft .* outputStateErrors); % TODO: replace this by correct vector math for speed
            
            kRateConstantLeftError = sum(inputState .^ obj.partialOrderReactantLeft) * rateLeftError;
            partialOrderReactantLeftError = (log(inputState) .* inputState .^ obj.partialOrderReactantLeft) * (rateLeftError * obj.kRateConstantLeft);
            
            inputStateLeftError = sum((obj.partialOrderReactantLeft .^ -1) .* inputState .^ (obj.partialOrderReactantLeft -1 ))   * (rateLeftError * obj.kRateConstantLeft) 


            stochiometricCoefficientsRightError = obj.previousRateRight * (obj.stochiometricCoefficientsRight .* outputStateErrors);
            
            rateRightError = sum(obj.stochiometricCoefficientsRight .* outputStateErrors); % TODO: replace this by correct vector math for speed
            
            kRateConstantRightError = sum(inputState .^ obj.partialOrderReactantRight) * rateRightError;
            partialOrderReactantRightError = (log(inputState) .* inputState .^ obj.partialOrderReactantRight) * (rateRightError * obj.kRateConstantRight);
            
            inputStateRightError = sum((obj.partialOrderReactantRight .^ -1) .* inputState .^ (obj.partialOrderReactantRight -1 ))   * (rateRightError * obj.kRateConstantRight) 
        end
    end
    
end

