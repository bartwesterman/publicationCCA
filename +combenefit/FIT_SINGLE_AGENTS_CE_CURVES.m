function [xfit1, xfit2,  opt1,  opt2] = FIT_SINGLE_AGENTS_CE_CURVES(ExpDat, saveornot)
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Fit both drugs dose response curves;

    Uinf_zero = 0.05;
    Uinf_100 = 100.0;

    DATA_STD = std(ExpDat.Resp,0,3);
    % AGENT 1
    C1    = ExpDat.Dose_ag1(2:end);
    E1    = ExpDat.Resp(2:end,1,:);
    E1    =  reshape(E1,[size(E1,1),size(E1,3)]);
    Estd1 = DATA_STD(2:end,1);
    
    [xfit1,fval1,goodf1] = combenefit.Fit_Hill_Curve_MLE(C1,E1,Estd1,ExpDat.Agent1);
    if(xfit1(3)<Uinf_zero)
        xfit1(3)=0.0;
    elseif(xfit1(3)>Uinf_100)
        xfit1(3)=100.0;
    end
        
    opt1=[fval1,goodf1];
    
    % AGENT 2
    C2    = ExpDat.Dose_ag2(2:end)';
    E2    = ExpDat.Resp(1,2:end,:);
    E2    = reshape(E2,[size(E2,2),size(E2,3)]);
    Estd2 = DATA_STD(1,2:end)';
    
    [xfit2,fval2,goodf2] = combenefit.Fit_Hill_Curve_MLE(C2,E2,Estd2,ExpDat.Agent2); 
    if(xfit2(3)<Uinf_zero)
        xfit2(3)=0.0;
    elseif(xfit2(3)>Uinf_100)
        xfit2(3)=100.0;
    end
    opt2=[fval2,goodf2];
    
    % SAVE FITTING PARAMETERS
    if saveornot 
      AllPD1=[xfit1,fval1,goodf1] ;
      AllPD2=[xfit2,fval2,goodf2];
      Tab_params = table(AllPD1', AllPD2','RowNames',{'EC50';'H';'Ucinf';'chi2';'good_of_fit'});
      if(strcmp(ExpDat.Agent1,ExpDat.Agent2))
       ExpDat.Agent2=[ExpDat.Agent2 '_bis']
      end
      Tab_params.Properties.VariableNames = { genvarname(ExpDat.Agent1),genvarname(ExpDat.Agent2) };
      Tab_params.Properties.DimensionNames{1}='Parameters';
      % Check if file has been opened by user and avoid crash
      FILE_NAME = char(strcat(ExpDat.Folder,'\Dose-response\data\single agent d-r parameters.csv'));
      fID = fopen(FILE_NAME,'w');
      if(fID>2)
        fclose(fID); 
        writetable(Tab_params,FILE_NAME,'WriteRowNames',true);   
      else
        warndlg('Combenefit could not save this combination dose response curves parameters because the corresponding .xls file was open!');          
      end
    end    
    
end