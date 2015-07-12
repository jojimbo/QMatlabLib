
function varargout = simByRiskcare(OBJ, nPeriods, dt, nTrials, Z, nSteps, startState)
    %% simByRiskcare - Perform simulation(s) of the Heston_RC_01 model
    %
    % simByRiskcare SYNTAX:
    %   [Paths, Times, Z] = simulate(OBJ, ...)
    %
    % simByRiskcare DESCRIPTION:
    % Performs a simulation(s) for a Heston_RC_01 model
    %
    % simByRiskcare INPUTS:
    %   1. OBJ: Object of type Heston_RC_01
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
    %   7. startState
    %   8. StorePaths
    %   9. Method
    %   10.
    %
    % simByRiskcare OUTPUTS:
    %   1. Paths - (nPeriods + 1) x NVARS x NTRIALS 3-D time series array of simulated
    %     paths of correlated state variables. Each row of Paths is the transpose
    %     of the state vector "X(t)" at time "t" for a given trial.
    %     Includes:
    %       - Vol_Sim: Simulated path of the volatility
    %       - S_Sim: Simulated path of the underlying
    %     #rows     = nPeriods + 1
    %     #columns  = 2 (NBROWNS)
    %     #3Dcols   = NTRIALS = NSims
    %
    %   2. Times - (nPeriods + 1) x 1 column vector of observation times associated
    %     with the simulated paths. Each element of Times is associated with the
    %     corresponding row of Paths (see above).
    %
    %   3. Z - nPeriods x NBROWNS x NTRIALS 3-D time series array of dependent random
    %     variates used to generate the Brownian motion vector (i.e., Wiener
    %     processes) that drove the simulated results found in Paths. NTIMES is
    %     the number time steps at which the state vector is sampled, including
    %     any intermediate times designed to improve accuracy but not necessarily
    %     reported in the Paths output time series.
    %
    % simByRiskcare VARIABLES:
    %   1. T: Time horizon for the simulation
    %
    %% Function simByRiskcare for Heston_RC_01 model
    % Copyright 1994-2016 Riskcare Ltd.
    %


%% Simulation variables
%dt = T/NPERIODS;
T = ceil(dt.*nPeriods);
Times = (0:dt:T)';

%% Random number generation
% Generate (correlated) random numbers if they haven't been provided externally
if isempty(Z)
    C = finchol([1 OBJ.rho; OBJ.rho 1]); % Same as: C = finchol(OBJ.Correlation);
    Z_new = quant.math.GenerateRN(OBJ, nTrials, nPeriods*nSteps, C);
else
    Z_new = Z;
end
Z1 = squeeze(Z_new(:, 1, :));
Z2 = squeeze(Z_new(:, 2, :));

%% Simulation
Paths = zeros(length(Times), 2, nTrials); % length(Times) = nPeriods + 1
for i = 1:nTrials
    S = zeros(length(Times), 1);
    S(1) = startState(1);
    CIR = zeros(length(Times), 1);
    CIR(1) = startState(2).^2;
    for s=2:length(Times) % = nPeriods+1
        CIR(s) = abs(CIR(s-1) + (OBJ.kappa.*(OBJ.eta-CIR(s-1)) - (OBJ.theta.^2)/4).*dt + ...
            OBJ.theta.*sqrt(CIR(s-1)).*sqrt(dt).*Z1(s-1,i) + OBJ.theta.^2.*dt.*(Z1(s-1,i).^2)/4);
        S(s) = S(s-1).*(1 + OBJ.drift.*dt + sqrt(CIR(s-1)).*Z2(s-1,i).*sqrt(dt));
    end
    %% Store return values
    Paths(:, 1, i) = S;
    Paths(:, 2, i) = CIR.^(0.5);
end

varargout{1} = Paths;
varargout{2} = Times;
varargout{3} = Z_new;

%% Function end - simByRiskcare
end