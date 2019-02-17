function [f g] = FUN_MIN_GRAD(C,E,Estd,xparam)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Function to minimze to fit doseresponse curve, includes gradient

  % If no std present (only one repeat), std is not considered
  Estd_no0                = Estd;
  Estd_no0( Estd_no0==0 ) = 1;
  
  f = 0.0;
  g = zeros(length(xparam),1);
  for i=1:length(C)
    for j=1:size(E,2)
      C_E = combenefit.doseresponse_EC0_100(xparam,C(i));
      % OBJECTIVE FUNCTION CONTRIBUTION
      f = f + ((E(i,j) - C_E)/Estd_no0(i))^2;
      % GRADIENT CONTRIBUTION
      [d_dic50, d_dH, d_dECinf] = combenefit.grad_doseresponse_EC0_100(xparam,C(i));
      grad_C_E                  = [d_dic50, d_dH, d_dECinf];
      for k=1:length(xparam)
         g(k) = g(k) - 2*(E(i,j)-C_E)/Estd_no0(i)^2 * grad_C_E(k);   
      end
    end
  end
  
end