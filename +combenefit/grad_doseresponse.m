function [d_dic50, d_dH, d_dECinf, d_dEC0] = grad_doseresponse(params,C)    
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli
% Gradient Hill equation
   
   ic50  = params(1);
   H     = params(2);
   ECinf = params(3);
   EC0   = params(4);
   
   Coeff   = ((ic50./C).^H) * (-ECinf + EC0)./((1+((ic50./C).^H)).^2);
   
   d_dic50 = (H./ic50) * Coeff;
   
   d_dH    = log(ic50./C) * Coeff;
   
   d_dECinf = 1./(1+((ic50./C).^H));
   
   d_dEC0   = 1 -  d_dECinf;
   
end