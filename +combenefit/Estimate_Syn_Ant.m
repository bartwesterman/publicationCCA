function ModelEstim = Estimate_Syn_Ant(ModelDat,ExpDat)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

   ModelEstim = ExpDat;  
   for i=1:size(ExpDat.Resp,3) 
      ModelEstim.Resp(:,:,i)  = ModelDat.Avg(:,:) - ExpDat.Resp(:,:,i);
   end
   ModelEstim.Avg = mean(ModelEstim.Resp,3);
   ModelEstim.Std = std(ModelEstim.Resp,0,3);
   ModelEstim.Ttest = combenefit.T_Test_Difference(ModelEstim.Resp);
   
  
   [MaxSyn, SynVol, WeiSynVol, SynSpread, C1Syn, C2Syn, MaxAnt, AntVol, WeiAntVol, AntSpread, C1Ant, C2Ant, TotVol, TotWeiVol] = ...
        combenefit.CalcMetrics(ModelEstim,ExpDat);
    
   ModelEstim.MaxSyn = MaxSyn;
   ModelEstim.SynVol = SynVol;
   ModelEstim.WeiSynVol = WeiSynVol;
   ModelEstim.SynSpread = SynSpread;
   ModelEstim.C1Syn = C1Syn;
   ModelEstim.C2Syn = C2Syn;
   
   ModelEstim.MaxAnt = MaxAnt;
   ModelEstim.AntVol = AntVol;
   ModelEstim.WeiAntVol = WeiAntVol;
   ModelEstim.AntSpread = AntSpread;
   ModelEstim.C1Ant = C1Ant;
   ModelEstim.C2Ant = C2Ant;
   
   ModelEstim.TotVol = TotVol;
   ModelEstim.TotWeiVol = TotWeiVol;
   
 end