function response = dose2response( dose, ec50, hillSlope, top, bottom)
%DOSE2RESPONSE Summary of this function goes here
%   Detailed explanation goes here
    f = chemistry.dose2responseFunction(ec50, hillSlope, top, bottom);

    response = f(dose);

end

