
function P = Asian(OptionType, Strike)
%% Asian function handle
%
% Asian SYNTAX:
%   P = Asian_Option()
%
% Asian DESCRIPTION:
%   Returns a handle function to calculate the Payoff of a Asian Option
%
% CALL:
% $\max(avg(Spots) - Strike, 0)$
%
% PUT:
% $\max(Strike - avg(Spots), 0)$
%
% Asian INPUTS:
%   [None]
%
% Asian OPTIONAL INPUTS:
%   [None]
%
% Asian OUTPUTS:
%   1. P - Handle function that depends on the Spot level of the underlying
%
% Asian VARIABLES:
%   [None]
%
%% Function Asian for Asian_Option instrument
% Copyright 1994-2016 Riskcare Ltd.
%

switch upper(OptionType)
    case 'CALL'
        P = @(SimulatedSpots) max(mean(SimulatedSpots)-Strike, 0);
    case 'PUT'
        P = @(SimulatedSpots) max(Strike-mean(SimulatedSpots), 0);
    otherwise
        error('Not valid Type');
end



end