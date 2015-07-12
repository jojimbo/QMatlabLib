
function [Z] = GenerateRN(MODEL, nTrials, nSteps, varargin)
%% GenerateRN Function - Generates a set of correlated random number streams
%   with the dimensionality needed by the model
%
% GenerateRN SYNTAX:
%   [Z] = GenerateRN(MODEL, nTrials, nSteps)
%
% GenerateRN DESCRIPTION:
%   Returns a matrix with correlated random number streams, with
%   dimensions:
%     #rows     = nSteps
%     #columns  = MODEL.Dimensionality (NBROWNS)
%     #3Dcols   = nTrials = NSims
%
% GenerateRN INPUTS:
%   1. MODEL    - As an Instrument object
%   2. nTrials  - # of simulations to be performed (#3DCols in the output)
%   3. nSteps   - # of steps that the simulation will use - will be sometimes the product of nPeriods*nSteps for a MC simualtions 
%                   # of independent consecutive draws for each stream
%
% GenerateRN OPTIONAL INPUTS:
%   1. CholDecomp - Precomputed Cholesky decomposition of the
%   correlation matrix to be used
%
% GenerateRN OUTPUTS:
%   1. Z - Matrix with correlated random numbers generated
%     #rows     = nSteps
%     #columns  = MODEL.Dimensionality (NBROWNS)
%     #3Dcols   = nTrials = NSims
%
%% Function GenerateRN
% Copyright 1994-2016 Riskcare Ltd.
%

if     nargin   == 4 % CholDecomp was provided
    C = varargin{1};
    % TODO - add check for Dimensionality of Model and CholDecomp
elseif nargin   == 3
    C = finchol(MODEL.Correlation); % Cholesky decomposition of the Correlation Matris of the model
else
    % TODO - Check error
end

Z = zeros(nSteps, MODEL.Dimensionality, nTrials); % Preallocate

for iTrial=1:nTrials
    z_iTrial = randn(nSteps, MODEL.Dimensionality) * C;
    Z(:,:,iTrial) = z_iTrial;
end

end
