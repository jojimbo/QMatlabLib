%% Function Euro_Options for Heston_RC_01 model
% Copyright 1994-2016 Riskcare Ltd.

function [C, S0] = Euro_Options(OBJ, EUR1, Spots, r, v0, ValuationDate)

%% HESTON Closed Form solution for Euro_Option for a range of Spot prices at once
C = zeros(length(Spots), 1);
EUR_aux = EUR1;
for k = 1:length(Spots)
    S0 = Spots(k);
    C(k) = OBJ.Euro_Option(EUR_aux, r, S0, v0, ValuationDate);
end

end