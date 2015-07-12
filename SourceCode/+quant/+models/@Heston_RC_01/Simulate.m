
function varargout = Simulate(OBJ, NPERIODS, varargin)
    %% Simulate - Perform simulation(s) of the Heston_RC_01 model
    %
    % Simulate SYNTAX:
    %   [Paths, Times, Z] = simulate(OBJ, ...)
    %
    % Simulate DESCRIPTION:
    % Performs a simulation(s) for a Heston_RC_01 model
    %
    % Simulate INPUTS:
    %   1. OBJ: Object of type Heston_RC_01
    %   2. NPERIODS - Positive scalar integer number of simulation periods. NPERIODS
    %     determines the number of rows of the simulated output series Paths
    %
    % Simulate OPTIONAL INPUTS:
    %   1. nTrials
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
    % Simulate OUTPUTS:
    %   1. Paths - (NPERIODS + 1) x NVARS x NTRIALS 3-D time series array of simulated
    %     paths of correlated state variables. Each row of Paths is the transpose
    %     of the state vector "X(t)" at time "t" for a given trial.
    %     Includes:
    %       - Vol_Sim: Simulated path of the volatility
    %       - S_Sim: Simulated path of the underlying
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
    % Simulate VARIABLES:
    %   1. T: Time horizon for the simulation
    %
    %% Function Simulate for Heston_RC_01 model
    % Copyright 1994-2016 Riskcare Ltd.
    %


%
%% Pre checks on the number of inputs
if nargin < 2
    error(message('+quant.models:Heston_RC_01:Simulate:TooFewInputs'));
end

if nargout > 3
    error(message('+quant.models:Heston_RC_01:Simulate:TooManyOutputs'));
end

%
%% Parse & validate the optional parameter name/value pairs and assign defaults.
try
    % Notice that the default 'METHOD' is the Matlab native simulation method.
    %
    %               Name     Default      Name     Default       Name      Default
    %          ------------  -------  -----------  -------  -------------  -------
    pairs = {   'nTrials'        1     'DeltaTime'     1      'Processes'     { }               ...
        'Z'            [ ]    'nSteps'        1      'Antithetic'   false              ...
        'StartState'  [1; 0.2]                                                          ... %1 for the stock level; 0.2 for the vol level
        'StorePaths'    true   'Method'    'Matlab'                                     ...
        };
    
    [nTrials    , dt        , processes   ,             ...
        Z          , nSteps    , isAntithetic,          ...
        StartState,                                     ...
        isStorePaths           , method,                ...
        ...
        ] =             ...
        quant.util.validateInputs(pairs(1:2:end), pairs(2:2:end), varargin{:});
    
    %     ADD??????
    %     pairs = {'nPeriods'   nPeriods     'nSteps'     nSteps       'nTrials'    nTrials ...
    %         'DeltaTime'  dt           'Processes'  processes    'Z'          Z       ...
    %         'Antithetic' isAntithetic 'StorePaths' isStorePaths 'StartState' Xo      ...
    %         'nVariables' nVariables   'nBrownians' nBrownians   'StartTime'  To};
    %
    %     [nPeriods    , nSteps      , nTrials, ...
    %         dt          , processes   , Z      , ...
    %         isAntithetic, isStorePaths, Xo] = checkSDEinputs(pairs(1:2:end), pairs(2:2:end));
    
catch exception
    exception.throwAsCaller();
end

%
%% Call Matlab native method if 'Matlab' is the method used to simulate
if useMatlabMethod(method)
    % Create Matlab heston sde to use for the simulation
    heston_obj = heston(OBJ.drift, OBJ.kappa, OBJ.eta, OBJ.theta, 'Correlation', OBJ.rho, 'StartState', StartState);
    [Paths, Times, Z_new] = ...
        simulate(heston_obj, NPERIODS, 'DeltaTime', dt, 'NTRIALS', nTrials, 'Z', Z, 'Antithetic', isAntithetic);
elseif ~useMatlabMethod(method)
    % Own method
    [Paths, Times, Z_new] = simByRiskcare(OBJ, NPERIODS, dt, nTrials, Z, nSteps, StartState);
else
    % Other methods...
    %end if
end

%
%% Return results
try
    switch nargout
        case 0
            return
        case 1
            varargout{1} = Paths;
            return
        case 2
            varargout{1} = Paths;
            varargout{2} = Times;
            return
        case 3
            varargout{1} = Paths;
            varargout{2} = Times;
            varargout{3} = Z_new;
            return
    end
catch exception
    exception.throwAsCaller();
end
%
%% Function end - Simulate
end







%
%% useMatlabMethod - Utility function to say if the method to be used is the native Matlab one
function bool = useMatlabMethod(method)
if strcmp(method, 'Matlab')
    bool = true;
else
    bool = false;
end
end

