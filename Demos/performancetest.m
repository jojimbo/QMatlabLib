function timeSimHeston_RCwithRNG = performancetest(n_sim)

%% Engine basic demo
% 
% Example execution of the engine defining and pricing an instrument under
% Heston model

%
%% Heston Model properties 
% To be calibrated in a real situation or imported from a file
r= 0.04;
kappa = 1.5768; %Speed of reversion
eta = 0.0398; %Long run variance
theta = 0.5751; %Vol of Variance (lambda in Heston Little Trap)
rho = -0.5711; %Correlation

v0 = 0.0175; %Initial Variance
sigma0 = sqrt(v0); %Initial Volatility
S0 = 80; %Initial price for the Stock

Today = datestr(today, 'dd-mmm-yyyy');
Maturity = datestr(daysadd(today,360, 1), 'dd-mmm-yyyy'); %1 for 30/360 so that adding 360 is exactly 1 full year

% Daily steps:
n_steps = daysdif(Today, Maturity, 0); % 0 for Act/Act
T = yearfrac(Today, Maturity, 0); % 0 for Act/Act
%yeardays(year(Today), 0) % #days in the year using 0:Act/Act

%
%% Instrument to be priced
%
Strike = 100;
TEF = quant.riskFactors.EquityStock('TEF'); %Underlying of the Option
EURCall = quant.instruments.Euro_Option('Call', TEF, Maturity, Strike);
EURPut = quant.instruments.Euro_Option('Put', TEF, Maturity, Strike);


%
%% Using Matlab's native through new class
%
riskcare_heston = quant.models.Heston_RC_01(rho, theta, kappa, eta, r);

%rng default %reset rng generator
%tStart = tic;
%[Paths1, Times1, Z1] = Simulate(riskcare_heston, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
%    'Method', 'Matlab', 'StartState', [S0; sigma0]);
%timeSimHeston_Matlab = toc(tStart);

%
%% Using Riskcare's method through new class
%
%rng default %reset rng generator
%tStart = tic;
%[Paths2, Times2, Z2] = Simulate(riskcare_heston, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
%    'Method', 'Riskcare','Z', Z1, 'StartState', [S0; sigma0]);
%timeSimHeston_RC = toc(tStart);

rng default %reset rng generator
tStart = tic;
[Paths3, Times3, Z3] = Simulate(riskcare_heston, n_steps, 'DeltaTime', T/n_steps, 'NTRIALS', n_sim, ...
    'Method', 'Riskcare', 'StartState', [S0; sigma0]);
timeSimHeston_RCwithRNG = toc(tStart);

%RCSim_Speedup = timeSimHeston_Matlab/timeSimHeston_RCwithRNG


Price_EURCall_CFSol1 = riskcare_heston.Euro_Option(EURCall, r, S0, v0, Today)
Price_EURCall_CFSol2 = riskcare_heston.Euro_Options(EURCall, S0, r, v0, Today)
[Ks, Prices_EURCall_CFSol3] = riskcare_heston.Euro_Option_CM(EURCall, S0, v0, Today);

stockprices = quant.TimeSeries(squeeze(Paths3(:,1,:)), 'days', datenum(Maturity)-n_steps, 'Name', 'stockprices');
stockvols = quant.TimeSeries(squeeze(Paths3(:,2,:)), 'days', datenum(Maturity)-n_steps, 'Name', 'stockvols');
priceandvolfor1stock = tscollection({stockprices stockvols});
%plot(priceandvolfor1stock.stockprices)


[price_EURCall_MC, stdError, finalPayments] = quant.methods.MCPrice(EURCall, stockprices, Today);
price_EURCall_MC

% M = rand(5)
% X.FOO('ROW1')
% X = dataset({M 'FOO','BAR','BAZ','BUZZ','FUZZ'}, 'obsnames', {'ROW1','ROW2','ROW3','ROW4','ROW5'})
% X.Properties

end
