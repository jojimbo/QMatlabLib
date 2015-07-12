
function PriceBS = Euro_OptionBS(EUR1, r, sigma, S0, T)

% Hardcoded for now:
%numberDaysInYear = 365;

%T = datenum(EUR1.MaturityDate) - datenum(ValuationDate);
%T= T/numberDaysInYear;

d1 = (log(S0/EUR1.Strike)+(r+sigma^2/2)*T)/(sigma*sqrt(T));
d2 = (log(S0/EUR1.Strike)+(r-sigma^2/2)*T)/(sigma*sqrt(T));

if strcmpi(EUR1.OptionType,'CALL')
    PriceBS = -EUR1.Strike*exp(-r*T)*normcdf(d2)+S0*normcdf(d1);
elseif strcmpi(EUR1.OptionType,'PUT')
    PriceBS = EUR1.Strike*exp(-r*T)*normcdf(-d2)-S0*normcdf(-d1);
else
    error(['not supported OptionType = ', EUR1.OptionType]);
    
end