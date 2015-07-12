
function P = Vanilla(OptionType, Strike)
%% Vanilla function handle
%
% Vanilla SYNTAX:
%   P = Vanilla()
%
% Vanilla DESCRIPTION:
%   Returns a handle function to calculate the Payoff of a Vanilla Option
%
% CALL:
% $\max(Spot - Strike, 0)$
%
% PUT:
% $\max(Strike - Spot, 0)$
%
% Vanilla INPUTS:
%   [None]
%
% Vanilla OPTIONAL INPUTS:
%   [None]
%
% Vanilla OUTPUTS:
%   1. P - Handle function that depends on the Spot level of the underlying
%
% Vanilla VARIABLES:
%   [None]
%
%% Function Vanilla (payoff) for Vanilla option instruments (European, American, other)
% Copyright 1994-2016 Riskcare Ltd.
%

switch upper(OptionType)
    case 'CALL'
        P = @(Spot) max(Spot-Strike, 0);
    case 'PUT'
        P = @(Spot) max(Strike-Spot, 0);
    otherwise
        error('Not valid Type');
end



end