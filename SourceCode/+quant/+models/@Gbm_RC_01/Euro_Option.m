%% Function Euro_Option for Gbm_RC_01 model
% Copyright 1994-2016 Riskcare Ltd.

function PriceBS = Euro_Option(OBJ, EUR1, S0, AsOfDate)

%% Black Scholes (GBM) Closed Form solution for Euro_Option

T = yearfrac(AsOfDate, EUR1.MaturityDate, 0); % 0 for Act/Act

d1 = (log(S0/EUR1.Strike)+(OBJ.drift+OBJ.sigma^2/2)*T)/(OBJ.sigma*sqrt(T));
d2 = (log(S0/EUR1.Strike)+(OBJ.drift-OBJ.sigma^2/2)*T)/(OBJ.sigma*sqrt(T));

Df= exp(-OBJ.drift*T);

switch upper(EUR1.OptionType)
    case {'CALL'}
        PriceBS = -EUR1.Strike*Df*normcdf(d2)+S0*normcdf(d1);
    case {'PUT'}
        PriceBS = EUR1.Strike*Df*normcdf(-d2)-S0*normcdf(-d1);
    otherwise
        error('Not yet implemented');
end

end
