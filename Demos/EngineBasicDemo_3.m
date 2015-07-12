%% Engine basic demo
% 
% Example execution of the engine for Amer Option with LSM

%
%% Model properties 
% To be calibrated in a real situation or imported from a file
r= 0.04;
D=0;

n_sim = 1000;

sigma0 = 0.4; %Initial Volatility
S0 = 80; %Initial price for the Stock

Today = datestr(today, 'dd-mmm-yyyy');
Maturity = datestr(daysadd(today,360, 1), 'dd-mmm-yyyy'); %1 for 30/360 so that adding 360 is exactly 1 full year

% Daily steps:
n_steps = daysdif(Today, Maturity, 0); % 0 for Act/Act
T = yearfrac(Today, Maturity, 0); % 0 for Act/Act
%yeardays(year(Today), 0) % #days in the year using 0:Act/Act

% This should be cached and used from other places:
cf = engine.factories.CurveFactory;
Dates = daysadd(today,360*[0 1 2],1); % 1 for 30/360 convention
discountCurve = cf.get('Flat_IRCurve', today, Dates, r,'Compounding', -1, 'Basis', 0);
DFs = discountCurve.getDiscountFactors(daysadd(discountCurve.Settle,(1:n_steps+2), 0));

%
%% Instrument to be priced
%
Strike = 100;
TEF = quant.riskFactors.EquityStock('TEF'); %Underlying of the Option

EURCall = quant.instruments.Euro_Option('Call', TEF, Maturity, Strike);
EURPut = quant.instruments.Euro_Option('Put', TEF, Maturity, Strike);

AMECall = quant.instruments.Amer_Option('Call', TEF, Maturity, Strike);
AMEPut = quant.instruments.Amer_Option('Put', TEF, Maturity, Strike);

%
%% Using Riskcare's method through new class
%
riskcare_gbm = quant.models.Gbm_RC_01(r, sigma0);

rng default %reset rng generator
tStart = tic;
[Paths2, Times2, Z2] = Simulate(riskcare_gbm, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
    'Method', 'Riskcare', 'StartState', S0);
timeSimGBM_RCwithRNG = toc(tStart);

rng default %reset rng generator
tStart = tic;
[Paths3, Times3, Z3] = Simulate(riskcare_gbm, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
    'Method', 'Riskcare', 'Z', Z2, 'StartState', S0);
timeSimGBM_RC = toc(tStart);

%
%% Using Matlab's native through new class
%
rng default %reset rng generator
tStart = tic;
[Paths1, Times1, Z1] = Simulate(riskcare_gbm, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
    'Method', 'Matlab', 'Z', reshape(Z2,[n_steps, 1, n_sim]), 'StartState', S0);
timeSimGBM_Matlab = toc(tStart);

RCSim_Speedup = timeSimGBM_Matlab/timeSimGBM_RC

%
%% Calculate prices of the instruments using different methods
%
stockprices = quant.TimeSeries(squeeze(Paths2), 'days', datenum(Maturity)-n_steps, 'Name', 'stockprices');

priceEURPut_ClosedForm = riskcare_gbm.Euro_Option(EURPut, S0, Today)

tStart = tic;
[priceEURPut_MC, stdError, finalPayments] = quant.methods.MCPrice(EURPut, stockprices, Today);
priceEURPut_MC
timeMCPrice = toc(tStart);

tStart = tic;
priceAMEPut_LSMC = quant.methods.LSMCPrice(AMEPut, stockprices, Today)
timeLSM = toc(tStart);



% MATLAB's SDE simulation:
%F = @(t,X) r * X;
%G = @(t,X) sigma0 * X;
%obj = sde(F, G, 'StartState', S0)
%[Sobj,Tobj] = simulate(obj, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, 'Z', reshape(Z2,[n_steps, 1, n_sim]));
%Sobj = squeeze(Sobj);
%Sobj-squeeze(Paths1); % Compares paths generated this way (not performant) with Matlab's slightly optimized routine

%Same method called using Model_SDE model wrapper:
%own = quant.models.Model_SDE(F, G);
%[Sown, Town, Zown] = Simulate(own, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, 'Method', 'Matlab', 'Z', reshape(Z2,[n_steps, 1, n_sim]), 'StartState', S0);
%squeeze(Sown)-squeeze(Sobj);


% M = rand(5)
% X.FOO('ROW1')
% X = dataset({M 'FOO','BAR','BAZ','BUZZ','FUZZ'}, 'obsnames', {'ROW1','ROW2','ROW3','ROW4','ROW5'})
% X.Properties


% 1,000 sims:
%timeLSM = 0.2085
%timeMatlab = 0.0180
%timeMCPrice =0.0016
%timeRC = 0.0101

% 10,000 sims:
%timeLSM =1.3233
%timeMatlab = 0.1435
%timeMCPrice = 0.0016
%timeRC = 0.0436

% 80,000 sims:
%timeLSM = 10.1184
%timeMatlab = 1.0880
%timeMCPrice = 0.0058
%timeRC = 0.4314

% 200,000 sims:
%timeLSM =  25.9898
%timeMatlab =  2.7202
%timeMCPrice =  0.0104
%timeRC =  1.2556
