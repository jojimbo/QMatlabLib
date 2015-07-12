
function P = EvaluatePayoff(OBJ, Simulations)
%% EvaluatePayoff function
%
% EvaluatePayoff SYNTAX:
%   P = EvaluatePayoff()
%
% EvaluatePayoff DESCRIPTION:
%   Returns the evaluated payoff of the instrument on the provided
%   simulated paths
%
% EvaluatePayoff INPUTS:
%   1. Simulations: TimeSeries object that contains the Simulations
%                   relevant to price the instrument
%
% EvaluatePayoff OPTIONAL INPUTS:
%   [None]
%
% EvaluatePayoff OUTPUTS:
%   1. P - Handle function that depends on the Spot level of the underlying
%
% EvaluatePayoff VARIABLES:
%   [None]
%
%% Function EvaluatePayoff that calls on and evaluates the Payoff for the instrument being priced
% Copyright 1994-2016 Riskcare Ltd.
%


% TODO - Support combinations of features
if ~isempty(OBJ.Features)
    features = OBJ.Features.keys;
    values = OBJ.Features.values;
    for i=1:length(OBJ.Features)
        switch upper(features{i})
            case 'ASIAN'
                if values{i} == true
                    % Asian Option - used all the simulation paths for its payoff
                    P = OBJ.Payoff(Simulations(:,:));
                end
            case 'AMERICAN'
                if values{i} == true
                    % American Option - used all the simulation paths for its payoff
                    P = OBJ.Payoff(Simulations(end,:));
                end
            otherwise
        end
    end
    return
end

% If it has reached here it is completely Vanilla instrument
P = OBJ.Payoff(Simulations(end,:));


end