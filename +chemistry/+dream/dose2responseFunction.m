function responseFunction = dose2responseFunction( ec50, hillSlope, bottom)
%DOSERESPONSEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

    responseFunction = @(dose) bottom + ( (100 - bottom) / ( 1 + 10^((log(ec50) - dose) * hillSlope)));

end

