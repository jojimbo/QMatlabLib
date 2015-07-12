
function varargout = simByRiskcare(OBJ, nPeriods, dt, nTrials, Z, nSteps, StartState)
    %% simByRiskcare - Perform simulation(s) of the GBM_RC_01 model
    %
    % simByRiskcare SYNTAX:
    %   [Paths, Times, Z] = simulate(OBJ, ...)
    %
    % simByRiskcare DESCRIPTION:
    % Performs a simulation(s) for a GBM_RC_01 model
    %
    % simByRiskcare INPUTS:
    %   1. OBJ: Object of type GBM_RC_01
    %   2. nPeriods - Positive scalar integer number of simulation periods. NPERIODS
    %     determines the number of rows of the simulated output series Paths
    %
    % simByRiskcare OPTIONAL INPUTS:
    %   1. nTrials - #simulations to perform (By default only 1)
    %   2. DeltaTime
    %   3. Processes
    %   4. Z
    %   5. nSteps
    %   6. Antithetic
    %   7. StartState
    %   8. StorePaths
    %   9. Method
    %   10.
    %
    % simByRiskcare OUTPUTS:
    %   1. Paths - (NPERIODS + 1) x NVARS x NTRIALS 3-D time series array of simulated
    %     paths of correlated state variables. Each row of Paths is the transpose
    %     of the state vector "X(t)" at time "t" for a given trial.
    %     Includes:
    %       - S_Sim: Simulated path of the underlying
    %     #rows     = NPERIODS
    %     #columns  = NTRIALS = NSims
    %
    %   2. Times - (NPERIODS + 1) x 1 column vector of observation times associated
    %     with the simulated paths. Each element of Times is associated with the
    %     corresponding row of Paths (see above).
    %
    %   3. Z - NTIMES x NBROWNS x NTRIALS 3-D time series array of dependent random
    %     variates used to generate the Brownian motion vector (i.e., Wiener
    %     processes) that drove the simulated results found in Paths. NTIMES is
    %     the number time steps at which the state vector is sampled, including
    %     any intermediate times designed to improve accuracy but not necessarily
    %     reported in the Paths output time series.
    %
    % simByRiskcare VARIABLES:
    %   1. T: Time horizon for the simulation
    %
    %% Function simByRiskcare for GBM_RC_01 model
    % Copyright 1994-2016 Riskcare Ltd.
    %


%% Simulation variables
%dt = T/NPERIODS;
T = ceil(dt.*nPeriods);
Times = (0:dt:T)';

%% Random number generation
% Generate (correlated) random numbers if they haven't been provided externally
if isempty(Z)
    C = finchol(OBJ.Correlation);
    Z_new = quant.math.GenerateRN(OBJ, nTrials, nPeriods*nSteps, C);
else
    Z_new = Z;
end
Z1 = squeeze(Z_new);

%% Simulation
dBt = sqrt(dt)*Z1;

S = zeros(length(Times), nTrials); % length(Times) = NPERIODS + 1
S(1,:) = StartState(1);
for s=2:length(Times) % =NPERIODS+1
    S(s,:) = S(s-1,:).*exp((OBJ.drift-0.5*OBJ.sigma^2)*dt +OBJ.sigma*dBt(s-1,:));
end

%% Store return values
varargout{1} = S;
varargout{2} = Times;
varargout{3} = Z_new;

%% Function end - simByRiskcare
end