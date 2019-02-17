function RES = FUN_MIN(C,E,Estd,xparam)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Function to minimize to fit dose response curve

RES = 0.0;
for i=1:length(C)
    for j=1:size(E,2)
        if (Estd(i)>0)
          RES = RES + ((E(i,j) - doseresponse_EC0_100(xparam,C(i)))/Estd(i))^2;
        else
          RES = RES + ((E(i,j) - doseresponse_EC0_100(xparam,C(i))))^2;  
        end
    end
end

end