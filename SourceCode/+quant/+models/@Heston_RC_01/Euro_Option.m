%% Function Euro_Option for Heston_RC_01 model
% Copyright 1994-2016 Riskcare Ltd.

function C = Euro_Option(OBJ, EUR1, r, S0, v0, ValuationDate)

%% HESTON Closed Form solution for Euro_Option

% Hardcoded for now:
numberDaysInYear = 365;

T = datenum(EUR1.MaturityDate) - datenum(ValuationDate);
T= T/numberDaysInYear;

switch upper(EUR1.OptionType)
    case {'CALL'}
        % It seems that in the Heston Trap paper there was an erratum!!
        F = (@(u)(exp(r.*T).*real( (exp(-1i.*u.*log(EUR1.Strike)).*OBJ.phi_Heston(T, S0, v0, u-1i))./(1i.*u.*exp(r.*T)) )-...
            EUR1.Strike.*real( (exp(-1i.*u.*log(EUR1.Strike)).*OBJ.phi_Heston(T, S0, v0, u))./(1i.*u)) ) );
        integral = quadgk(F, 0, Inf,'RelTol',1e-8,'AbsTol',1e-12);
        %integral = quadcc(F, 0, Inf);
        C = 0.5.*(S0.*exp(-OBJ.q.*T) - EUR1.Strike.*exp(-r.*T)) + (1./pi).*exp(-r.*T).*integral;
    case {'PUT'}
        error('Not yet implemented');
end

end
