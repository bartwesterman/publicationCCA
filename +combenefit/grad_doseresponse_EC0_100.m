function [d_dic50, d_dH, d_dECinf] = grad_doseresponse_EC0_100(coefficients,C)    
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Gradient Hill equation, EC0 fixed at 100
 
 all_coefficients = [coefficients 100];
 [d_dic50, d_dH, d_dECinf] = combenefit.grad_doseresponse(all_coefficients,C) ;
   
end