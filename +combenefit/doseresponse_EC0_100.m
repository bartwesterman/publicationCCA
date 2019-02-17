function res  = doseresponse_EC0_100(params,CC)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli
%
% Hill equation EC0 = 100;

   ic50 = params(1);
   H    = params(2);
   ECinf = params(3);
   EC0   = 100.0;
   
   res = (EC0+((ECinf-EC0)./(1+((ic50./CC).^H))));   
end