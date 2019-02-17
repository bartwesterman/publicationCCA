function RES  = responsedose(params,effects) 
% The MIT License (MIT)
% 
% Copyright (c) 2015 Giovanni Di Veroli

% Inverse function of the Hill equation

    ic50 = params(1);
    H    = params(2);
    ECinf = params(3);
    EC0   = params(4);
    
    RES = ((ECinf-EC0)./(effects-EC0)-1).^(-1/H)*ic50;    
end