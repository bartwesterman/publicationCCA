function responseFunction = dose2responseFunction( ec50, hillSlope, top, bottom)
%DOSE2RESPONSEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    responseFunction = @(dose) bottom + ( (top - bottom) / ( 1 + 10^((log(ec50) - dose) * hillSlope)));
end

