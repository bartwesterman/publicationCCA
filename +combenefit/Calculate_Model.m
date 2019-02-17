function [ ModelDat ] = Calculate_Model(ParamsD1,ParamsD2, ExpDat, modeltype)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli
%
% Generate C-E surface based on Loewe, Bliss and HSA models

  C1 = ExpDat.Dose_ag1;
  C2 = ExpDat.Dose_ag2;

  ModelDat = ExpDat;
  ModelDat.Resp = [];
  ModelDat.Std  = [];

  switch modeltype
      
    case 1 %% LOEWE MODEL
      Linear_Isobole_Matrix = zeros(length(C1),length(C2));

      k1 = [ParamsD1, 100];
      k2 = [ParamsD2, 100];

      for i=1:length(C1) 
       for j=1:length(C2) 
        if C2(j)==0&&C1(i)==0
            Linear_Isobole_Matrix(i,j)  = 100;
        else
            Linear_Isobole_Matrix(i,j)  =  ...
                combenefit.E_Linear_Isobole_extended(k1,k2,C1(i),C2(j));
        end
       end
      end
      
      ModelDat.Avg = Linear_Isobole_Matrix;

     case 2 %% BLISS
         
      Bliss_Matrix = combenefit.doseresponse_EC0_100(ParamsD1,C1) * ...
                     combenefit.doseresponse_EC0_100(ParamsD2,C2)/100 ;
                 
      ModelDat.Avg = Bliss_Matrix;
     
     case 3 %% HSA MODEL
       EC1 = combenefit.doseresponse_EC0_100(ParamsD1,C1) * ones(1,length(C2));
       EC2 = ones(length(C1),1) * combenefit.doseresponse_EC0_100(ParamsD2,C2); 
       HSA_Matrix = min(EC1,EC2);
       
       ModelDat.Avg = HSA_Matrix;
       
  end      
  
end
