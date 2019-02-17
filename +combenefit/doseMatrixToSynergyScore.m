function score = doseMatrixToSynergyScore( aDoses, bDoses, combinationMatrix )
%EXPDATATOSYNERGYSUM Summary of this function goes here
%   Detailed explanation goes here

    ExpDat = struct();
    ExpDat.Dose_ag1 = aDoses;
    ExpDat.Dose_ag2 = bDoses';
    ExpDat.Resp     = combinationMatrix;
    ExpDat.Agent1   = '';
    ExpDat.Agent2   = '';
    ExpDat.minSyn   = 0;
    ExpDat.minAnt   = 0;
    ExpDat.Avg      = mean(combinationMatrix, 3);
    ExpDat.Std      = std(combinationMatrix,0,3);
    
    [ParamsD1, ParamsD2,  opt1,  opt2] = combenefit.FIT_SINGLE_AGENTS_CE_CURVES(ExpDat,false);
    LoeweModel = combenefit.Calculate_Model(ParamsD1,ParamsD2, ExpDat,1);
    LoeweEstim = combenefit.Estimate_Syn_Ant(LoeweModel,ExpDat);

    score = LoeweEstim.TotVol;   
end

