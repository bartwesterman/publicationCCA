function RES = Fun_Lin_Iso(E,k1, k2, D1,D2)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli
% Function to solvee extended version of linear isobole equation

  if D1==0&&D2==0
    RES = abs(E - combenefit.doseresponse(k1, D1)); % setting E to CTRL value
  elseif(D1==0)
    RES = abs(E - combenefit.doseresponse(k2, D2)); % setting E to U2(D2) value
   elseif(D2==0)
    RES = abs(E - combenefit.doseresponse(k1, D1)); % setting E to U1(D1) value
  else
      if(E>k1(3))
        A = D1/combenefit.responsedose(k1,E);
      else
        A = 2.0; % Effect greater than D1 efficacy not acceptable
      end
      if(E>k2(3))
            B = D2/combenefit.responsedose(k2,E);
      else
          B = 2.0; % Effect greater than D2 efficacy not acceptable
      end
    RES = abs(1 - (A+B));
  end
  
end