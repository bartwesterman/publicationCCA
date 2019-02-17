function r2 = r2( output, correct, varargin )
%R2 Summary of this function goes here
%   Detailed explanation goes here


    % totalSumOfSquares    = sum((correct - mean(correct)) .^2 );
    % sumOfResidualSquared = sum((correct - output) .^2 );
    
    % v = 1 - sumOfResidualSquared / totalSumOfSquares;
    
    if isempty(varargin); c = true; 
    elseif length(varargin)>1; error 'Too many input arguments';
    elseif ~islogical(varargin{1}); error 'C must be logical (TRUE||FALSE)'
    else c = varargin{1}; 
    end

    % Compare inputs
    if ~all(size(correct)==size(output)); error 'Y and F must be the same size'; end

    % Check for NaN
    tmp = ~or(isnan(correct),isnan(output));
    correct = correct(tmp);
    output = output(tmp);

    if c; r2 = max(0,1 - sum((correct(:)-output(:)).^2)/sum((correct(:)-mean(correct(:))).^2));
    else r2 = 1 - sum((correct(:)-output(:)).^2)/sum((correct(:)).^2);
        if r2<0
        % http://web.maths.unsw.edu.au/~adelle/Garvan/Assays/GoodnessOfFit.html
            warning('Consider adding a constant term to your model') %#ok<WNTAG>
            r2 = 0;
        end
    end
end

