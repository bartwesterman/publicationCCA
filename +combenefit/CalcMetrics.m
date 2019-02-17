function [MaxSyn, SynVol, WeiSynVol, SynSpread, C1Syn, C2Syn, MaxAnt, AntVol,...
           WeiAntVol, AntSpread, C1Ant, C2Ant, TotVol, TotWeiVol ] = CalcMetrics(ModelDat,ExpDat)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

  Syn = max(ModelDat.Avg,zeros(size(ModelDat.Avg)));
  Ant = min(ModelDat.Avg,zeros(size(ModelDat.Avg)));
  C1 = ModelDat.Dose_ag1;
  C2 = ModelDat.Dose_ag2;

  SynVol = 0.0;
  WeiSynVol = 0.0;
  UniVolSyn = 0.0;
  C1Syn = 0.0;
  C2Syn = 0.0;
  
  AntVol = 0.0;
  WeiAntVol = 0.0;
  UniVolAnt = 0.0;
  C1Ant = 0.0;
  C2Ant = 0.0;
  
  MaxSyn = max(max(Syn));
  MaxAnt = min(min(Ant));
  
%   % Potential future correction, suggested 19/03/2015
%   MaxSyn = max(max(Syn(2:end,2:end)));
%   MaxAnt = min(min(Ant(2:end,2:end)));

  for i=2:(length(C1)-1)
    for j=2:(length(C2)-1)
      Incr = log10(C1(i+1)/C1(i)) * log10(C2(j+1)/C2(j));
      
      if((Syn(i,j) + Syn(i+1,j) + Syn(i,j+1) + Syn(i+1,j+1))/4 >= ExpDat.minSyn )  
      SynVol = SynVol +  Incr * (Syn(i,j) + Syn(i+1,j) + Syn(i,j+1) + Syn(i+1,j+1))/4;
      
      WeiSynVol = WeiSynVol +  Incr * (1 - max(min(ExpDat.Avg(i,j)/100.0,1),0)) * ...
                     (Syn(i,j) + Syn(i+1,j) + Syn(i,j+1) + Syn(i+1,j+1))/4;
      
      UniVolSyn = UniVolSyn +  Incr * MaxSyn;  
        
      C1Syn = C1Syn + Incr * ( (Syn(i,j) + Syn(i,j+1))*log10(C1(i)) + ...
                          (Syn(i+1,j+1)+ Syn(i+1,j))*log10(C1(i+1)) )/4;  
       
      C2Syn = C2Syn + Incr * ( (Syn(i,j) + Syn(i+1,j))*log10(C2(j)) + ...
                          (Syn(i,j+1)+ Syn(i+1,j+1))*log10(C2(j+1)) )/4;  
      end

      if((Ant(i,j) + Ant(i+1,j) + Ant(i,j+1) + Ant(i+1,j+1))/4 <= ExpDat.minAnt)
      AntVol = AntVol + Incr * (Ant(i,j) + Ant(i+1,j) + Ant(i,j+1) + Ant(i+1,j+1))/4;
      
      WeiAntVol = WeiAntVol + Incr * max(min(ExpDat.Avg(i,j)/100.0,1),0) * ...
                     (Ant(i,j) + Ant(i+1,j) + Ant(i,j+1) + Ant(i+1,j+1))/4;
      
      UniVolAnt = UniVolAnt +  Incr * MaxAnt;
      
      C1Ant = C1Ant + Incr * ( (Ant(i,j) + Ant(i,j+1))*log10(C1(i)) + ...
                          (Ant(i+1,j+1)+ Ant(i+1,j))*log10(C1(i+1)) )/4;  
       
      C2Ant = C2Ant + Incr * ( (Ant(i,j) + Ant(i+1,j))*log10(C2(j)) + ...
                          (Ant(i,j+1)+ Ant(i+1,j+1))*log10(C2(j+1)) )/4;  
      end

    end
  end
  
%   if(UniVolSyn>0.0)
%     SynSpread = SynVol/UniVolSyn;
%     WeiSynVol = WeiSynVol/UniVolSyn;
%   else
%     SynSpread = 0.0;  
%   end
  if(MaxSyn>0.0)
    SynSpread = sqrt(SynVol/MaxSyn);
  else
    SynSpread = 0.0;  
  end
  WeiSynVol = WeiSynVol; 
  
%   if(UniVolAnt<0.0)
%     AntSpread = AntVol/UniVolAnt;
%     WeiAntVol = -1*WeiAntVol/UniVolAnt;
%   else
%     AntSpread = 0.0;    
%   end

  if(MaxAnt<0.0)
    AntSpread = sqrt(AntVol/MaxAnt);    
  else
    AntSpread = 0.0;    
  end
  WeiAntVol = WeiAntVol;
  
  TotVol = SynVol + AntVol;
  TotWeiVol = WeiSynVol + WeiAntVol;

  if(SynVol>0.0)
    C1Syn = 10^(C1Syn/SynVol);
    C2Syn = 10^(C2Syn/SynVol);
  else
    C1Syn = 0.0;
    C2Syn = 0.0;
  end
  
  if(AntVol<0.0)
    C1Ant = 10^(C1Ant/AntVol);
    C2Ant = 10^(C2Ant/AntVol);
  else
    C1Ant = 0.0;
    C2Ant = 0.0;
  end
   
end