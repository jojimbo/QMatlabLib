
function P = Payoff_Euro_Option(OBJ)
%% Payoff_Euro_Option function handle
%
% Payoff_Euro_Option SYNTAX:
%   P = Payoff_Euro_Option()
%
% Payoff_Euro_Option DESCRIPTION:
%   Returns a handle function to calculate the Payoff of a Euro_Option
%
% CALL:
% $\max(Spot - Strike, 0)$
%
% PUT:
% $\max(Strike - Spot, 0)$
%
% Payoff_Euro_Option INPUTS:
%   [None]
%
% Payoff_Euro_Option OPTIONAL INPUTS:
%   [None]
%
% Payoff_Euro_Option OUTPUTS:
%   1. P - Handle function that depends on the Spot level of the underlying
%
% Payoff_Euro_Option VARIABLES:
%   [None]
%
%% Function Payoff_Euro_Option for Euro_Option instrument
% Copyright 1994-2016 Riskcare Ltd.
%

switch upper(OBJ.OptionType)
    case 'CALL'
        P = @(Spot) max(Spot-OBJ.Strike, 0);
    case 'PUT'
        P = @(Spot) max(OBJ.Strike-Spot, 0);
    otherwise
        error('Not valid Type');
end



end