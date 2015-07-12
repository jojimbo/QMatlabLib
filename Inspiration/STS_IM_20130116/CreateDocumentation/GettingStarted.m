%% Getting started
% Read how to invoke miniECAPSCL and what it exaclty does step-by-step.
%
% *[weights,theComparison, theResults] = miniECAPSCL('ConfigFile.txt')*

%% Read the configuration file
% The configuration file is a textfile, with a set of attributes.
% For example, the config file can have the fields listed below.
%
% Please notice that there should be no space between the property and the
% equal sign. The path is absolute with respect to the positions where to
% find the data. 
%
% * DIR=C:\demos\CustomersCases\ING\miniECAPS2\trunk\Code
% * REQUEST_ID=126524
% * SCENARIO_SET=RN_R_Set_1_EUR_201108.xls
% * CURRENCY=EUR
% * SESSION_DATE=2011/08/31
% * OPTIM_BUCKETS=[0;20]
% * INTEREST_RATES_FLOORED_AT_ZERO=1
% * TRADE_PENALTY=0

configFile = 'ConfigFile.txt';
parameters = loadParamsFromConfigFile(configFile);
% Override the root directory from the config file so it works for wherever
% we are installed.
parameters.parameters.dir = fileparts(pwd);

%% Define replication settings
% Not all settings are exposed to the user in the configuration file. 
% Some settings are not visible to the end user, and defined inside the 
% function miniECAPSCL. 
% These parameters are required to specify how the replication is performed.

% Optimization boundaries
lowerBoundsPlus = 0;
lowerBoundsMinus = 0;
upperBoundsPlus = 1.e12;
upperBoundsMinus = 1.e12;
OptimBounds= [lowerBoundsPlus; ...
    lowerBoundsMinus; ...
    upperBoundsPlus; ...
    upperBoundsMinus];

% Maximum term to maturity to exclude Instruments
maxTermToMaturity = 100;

% Scenario interpolation
scenarioInput = parameters.parameters;
scenarioInput.interpolation = 'constant';

%% Setup the replication portfolio
% Create the replication portfolio object:
%
% * Read the scenarios
% * Read the cashflows liabilities and discount them 
% * Create the instruments and exclude those that exceed maturity

rp = ing.ReplicationPortfolio(parameters.inputFiles.cashflow, ...
    parameters.inputFiles.scenario, ...
    scenarioInput, parameters.inputFiles.instruments, ...
    parameters.inputFiles.indexcurve, parameters.parameters.bucketing, ...
    maxTermToMaturity);

%% Bucketing
% Verify that the bucketing settings are correct. You need to specify the
% buckets with the suitable notation in the configuration file.

if ~isempty(scenarioInput.bucketing)
    rp.Buckets = scenarioInput.bucketing;
    if numel(rp.Buckets)<2
        error('miniECAPSCL:BadConfig', ...
            'OPTIM_BUCKETS must be a vector of at least 2 elements')
    end
    if any(rp.Buckets(1:end-1)>rp.Buckets(2:end))
        error('miniECAPSCL:BadConfig', ...
            'OPTIM_BUCKETS must be a vector of increasing years')
    end
end

%% Replicate the portfolio
% Run the actual optimization, currently it is using a linear optimization.
% First compute the present value of the discounted cashflows.
[weights, relError, rp] = rp.runOptimization(OptimBounds);

%% Verify the results
% Verify that miniECAPS replication portfolio is in agreement with the 
% results of the ECAPS engine.

if ~isempty(parameters.inputFiles.result)
    % compare the results:
    % root folder for data structure
    base = scenarioInput.dir;
    % Add the Data folder base, and select the right scenario by adding the date:
    base = fullfile(base, 'Data', datestr(scenarioInput.sessionDate, 'yyyymm'));
    if isempty(strfind(parameters.inputFiles.result,filesep))
        resfilename = [base,filesep,'Scenario',filesep,parameters.inputFiles.result];
    else
        resfilename = parameters.inputFiles.result;
    end
    xpath = XPath(resfilename);
    if isempty(strfind(parameters.inputFiles.indexcurve,filesep))
        eqfilename = [base,filesep,'Scenario',filesep,parameters.inputFiles.indexcurve];
    else
        eqfilename = parameters.inputFiles.indexcurve;
    end
    eqList = get_equities(eqfilename);
    [theComparison, theResults] = ...
        compareResults(rp, weights, xpath, eqList, ...
        scenarioInput.tradePenalty);
end

% End of demo
