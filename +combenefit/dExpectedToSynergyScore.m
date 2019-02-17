function TotVol = dExpectedToSynergyScore( C1, C2, combinationMatrix )
%DEXPECTEDTOSYNERGYSCORE Summary of this function goes here
%   Detailed explanation goes here

  Syn = max(combinationMatrix,zeros(size(combinationMatrix)));
  Ant = min(combinationMatrix,zeros(size(combinationMatrix)));
  C1 = C1';
  
  SynVol = 0.0;
  AntVol = 0.0;
  
%   % Potential future correction, suggested 19/03/2015
%   MaxSyn = max(max(Syn(2:end,2:end)));
%   MaxAnt = min(min(Ant(2:end,2:end)));

  for i=2:(length(C1)-1)
    for j=2:(length(C2)-1)
      Incr = log10(C1(i+1)/C1(i)) * log10(C2(j+1)/C2(j));
      
      if((Syn(i,j) + Syn(i+1,j) + Syn(i,j+1) + Syn(i+1,j+1))/4 >= 0 )  
        SynVol = SynVol +  Incr * (Syn(i,j) + Syn(i+1,j) + Syn(i,j+1) + Syn(i+1,j+1))/4; 
      end

      if((Ant(i,j) + Ant(i+1,j) + Ant(i,j+1) + Ant(i+1,j+1))/4 <= 0)
        AntVol = AntVol + Incr * (Ant(i,j) + Ant(i+1,j) + Ant(i,j+1) + Ant(i+1,j+1))/4; 
      end

    end
  end
  
  TotVol = SynVol + AntVol;
end

