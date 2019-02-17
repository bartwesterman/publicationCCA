function res  = doseresponse(params,CC)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli
%
% Hill equation;

   ic50 = params(1);
   H    = params(2);
   ECinf = params(3);
   EC0   = params(4);
   
   res = (EC0+((ECinf-EC0)./(1+((ic50./CC).^H))));   
end