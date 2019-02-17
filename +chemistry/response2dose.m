function dose = response2dose( response, ec50, hillSlope, top, bottom)
%RESPONSE2DOSE Summary of this function goes here
%   Detailed explanation goes here
    doseFunction = response2doseFunction( ec50, hillSlope, top, bottom)
    
    dose = doseFunction( response );

end

