function [xfit,fval,goodf] = Fit_Hill_Curve_MLE(C,E,Estd,name)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Fit Hill equation based on maximum likelihood fitting

  % INITIAL GUESS
  x0= [1 1 0];

  % BOUNDARY
  LB = [C(1)/100.0 0.1 0];
  UB = [C(end) 10 100];

  FUN_MIN_GRAD_PARAMETRIZED = @(x)combenefit.FUN_MIN_GRAD(C,E,Estd,x);
  if license('test','optimization_toolbox')
    % IF OPTIMIZATION TOOLBOX IS PRESENT, AN ANALYTICAL GRADIENT BASED
    % MINIMIZATION APPROACH IS USED (trust-region-reflective)
    if(exist('optimoptions', 'file'))
      options = optimoptions('fmincon','Algorithm','trust-region-reflective','Display','off','GradObj','on','MaxIter',2000,...
                           'MaxFunEvals',10000,'TolFun',1e-8,'TolX',1e-8);
    else
      options = optimset('Algorithm','trust-region-reflective','Display','off','GradObj','on','MaxIter',2000,...
                           'MaxFunEvals',10000,'TolFun',1e-8,'TolX',1e-8);  
    end
    [xfit1,fval1] = fmincon(FUN_MIN_GRAD_PARAMETRIZED,x0,[],[],[],[],LB,UB,[],options);
  end
    % WE also USE A CONSTRAINED VERSION OF FREELY AVAILABLE fminsearch 
    % (THIS USES DERIFVATIVE FREE SIMPLEX ALGORITHM)
    [xfit2,fval2] =  combenefit.fminsearchbnd(FUN_MIN_GRAD_PARAMETRIZED,x0,LB,UB,optimset(...
                     'MaxIter',2000,'MaxFunEvals',10000,'TolFun',1e-8,'TolX',1e-8));                             

     % The best result is retained
     if(fval1<fval2)
         xfit=xfit1;
         fval=fval1;
     else
         xfit=xfit2;
         fval=fval2;         
     end

  if(size(E,2)>=2)
   % Goodness of Fit
   dof = length(C)* size(E,2) - 3; %(= npoints*nobs - npara)
   chi2 = fval; 
   goodf = 1 - chi2cdf(chi2,dof);
  
   if (goodf<0.05)
     warndlg(['WARNING: Your goodness of fit value (P(X>=Chi2)=',num2str(goodf),'), for ',char(name),' dose-response curve is too low and the fitting' ...
             ,' might be unsatisfactory. You should ensure that this does not affect your results. You can attempt to increase the number of replicates' ...
             ,'and/or refine concentration ranges. It might also be that a standard Hill equation does not correctly account for your specific agent effects.']);
   end
  else
%     fval = 0.0;
    goodf= 0.0;  
  end
  
  % Assumed constant if maximum decrease close less than 5%
  if(xfit(3)>95.0)
      xfit(1)= 1.0;
      xfit(2)= 0.0;
      xfit(3)= 100.0;
  end
end