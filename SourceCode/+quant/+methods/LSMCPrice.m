
function [Price, stdError, finalPayments] = LSMCPrice(Instrument, StockSimPaths, AsOfDate, BasisFunctionsInput)
    %% LSMCPrice Function - Least Squares Monte Carlo price for an instrument with early exercise given simulations
    %                       Uses Longstaff Schwartz algorithm
    %
    % LSMCPrice SYNTAX:
    %   [Price, stdError] = MCPrice(Instrument, StockSimPaths, AsOfDate)
    %
    % LSMCPrice DESCRIPTION:
    %   Returns Least Squares Monte Carlo price for the Instrument passed in, using the
    %   StockSimPaths provided, and at date AsOfDate
    %
    % LSMCPrice INPUTS:
    %   1. Instrument - As an Instrument object
    %   2. StockSimPaths - As a TimeSeries object
    %       StockSimPaths.Data has #rows = #steps; #cols = #sims
    %   3. AsOfDate - Date of valuation
    %
    % LSMCPrice OPTIONAL INPUTS:
    %   1. BasisFunctionsInput - Cell array of (handle) Basis Functions to use
    %
    % LSMCPrice OUTPUTS:
    %   1. Price - Monte Carlo price for the instrument at date AsOfDate
    %   2. stdError - Standard error of the price calculated
    %   3. finalPayments [OPTIONAL] - Vector with final Payments for all
    %   simulation paths (can be used for VaR for example)
    %
    %% Function LSMCPrice
    % Copyright 1994-2016 Riskcare Ltd.
    %

if nargin == 3
    % Set this as Default
    BasisFunctions = {@(y)y, @(y)y.^2, @(y)y.^3}; 
elseif nargin == 4
    BasisFunctions = BasisFunctionsInput;
end
    
%% Extract simulation paths
Sims = StockSimPaths.Data';    
% Sims now are then the simulations with: #rows = sims; #cols = steps

nSims = size(Sims,1); % Number of simulations
nPeriods = size(Sims, 2); %Number of periods to simulate the price of the stock = size(SSit, 2);
% NOTE: First column is always the state of the stock at t=0, so S0 (e.g. 100)

%% Get discount curve to use
cf = engine.factories.CurveFactory;
% TODO - These 3 lines will be removed once the storage map for curves is ready
% We would simply retrieve the previously created curve (as opposed to creating one)
r = 0.04; % TODO - Incorporate discouting framework
Dates = daysadd(AsOfDate,360*[0 1],1); % 1 for 30/360 convention
discCurve = cf.get('Flat_IRCurve', AsOfDate, Dates, r,'Compounding', -1, 'Basis', 0); % 0 for Act/Act

if datenum(AsOfDate) < datenum(discCurve.Settle)
    error(message('+quant.methods:LSMCPrice:CurveSettleDateBeforeAsOfDate'));
end
% Discount factor from AsOfDate to discCurve.Settle
DF_AsOfDate = discCurve.getDiscountFactors(AsOfDate); % Would be 1 if AsOfDate == discCurve.Settle

T = yearfrac(AsOfDate, Instrument.MaturityDate, 0); % in years
%T = 1;
dt = T/(nPeriods-1); %Lenght of the time interval used in the simulations provided


%% Initialize CashFlow Matrix
CFMatrix = NaN*ones(nSims,nPeriods);
CFMatrix(:,nPeriods)= Instrument.Payoff(Sims(:,end)); % Payoffs if the instrument was european style
%Instrument.EvaluatePayoff(Sims); % TODO - FOR NOT ONLY EUROPEANS

XX2 = zeros(nSims, length(BasisFunctions)+1); %XX2*BB is the evaluation of the fitted conditional expectation over the prices on the step before the current (t-1)

DFs = discCurve.getDiscountFactors(daysadd(AsOfDate, (0:nPeriods-1), 0))'; % All Discount Factors for all steps back to discCurve.Settle

for t=nPeriods:-1:3;
    %% Step 1: Get the In-The-Money paths at time t-1
    idxITM_t_1 = find(Instrument.Payoff(Sims(:,t-1)) > 0); %In-The-Money paths at t-1
    %Instrument.EvaluatePayoff(Sims(:,1:t-1)); % TODO - FOR NOT ONLY EUROPEANS
    nITMPaths_t_1 = length(idxITM_t_1); % #of In-The-Money paths at t-1
    %idxOTM = setdiff(1:nSims,idxITM);
    
    CFtoDiscount = CFMatrix(idxITM_t_1,t:nPeriods);
    
    %% Step 2: Project CashFlows at time t onto basis function at time t-1
    % We discount back to t-1 the cashflows at t if the option were not to be exercised at t-1 (for the ITM paths only):
    discountFactors2 = DFs./DFs(t-1); % discount factors to discount all CFs one step back (to t-1)
    tobesummed = bsxfun(@times, discountFactors2(t:nPeriods), CFtoDiscount);
    discountedCFs = sum(tobesummed,2);
    
    S_ITM = Sims(idxITM_t_1, t-1); % only includes in-the-money path prices at t-1 (one step before the current t)
    XX = zeros(nITMPaths_t_1, length(BasisFunctions)+1); % vector to be used for regression
    XX(:,1) = 1;
    for i=1:length(BasisFunctions)
        XX(:,i+1) = BasisFunctions{i}(S_ITM);
    end
        
    %% Step 3: Perform regression:
    BB=(XX'*XX)\XX'*discountedCFs; % BB = XX\discountedCFs - TODO- Why not simply this?
    S2=Sims(:,t-1); % includes all the prices one step before the current
    XX2(:,1) = 1; % First Basis Function is always a constant
    for i=1:length(BasisFunctions)
        XX2(:,i+1) = BasisFunctions{i}(S2);
    end
    
    %% Find when the option is exercised:
    execValue = Instrument.Payoff(Sims(:,t-1)); % Cashflow from executing the option at time t-1
    %Instrument.EvaluatePayoff(Sims(:,1:t-1)); % TODO - FOR NOT ONLY EUROPEANS
    condExpectContinue = max(XX2*BB,0); % Conditional expectation of not exercising (evaluating the regressed function)
    
    idxExercise = find(execValue>max(condExpectContinue,0));
    idxContinue = find(~(execValue>max(condExpectContinue,0)));
    
    check = (sum(idxExercise) + sum(idxContinue) == sum(1:nSims));
    if check~=1
        error(message('+quant.methods:LSM:UnknownError')); % [' instrument payoff might be not supported: at step t ', num2str(t),...
            %    ' is not decided whether instrument is exercised or not for all paths']
    end
    
    %% Replace the payoff function with the value of the option (zeros when not exercised and values when exercised):
    CFMatrix(idxExercise, t-1) = Instrument.Payoff(Sims(idxExercise, t-1)); %Instrument.EvaluatePayoff(Sims(idxExercise, 1:t-1)); % TODO - FOR NOT ONLY EUROPEANS
    CFMatrix(idxExercise, t:nPeriods) = 0; % set to 0 all cashflows for later times if Exercise ocurres at t-1
    CFMatrix(idxContinue, t-1) = zeros(length(idxContinue), 1); % set to 0 all cashflows if Exercise doesn't occur
end 
%repmat(exp(-r*(1:nPeriods-1)*dt), nSims,1) faster than (ones(nSims,1)*exp(-r*(1:nPeriods-1)*dt))
discountedCFs = sum(repmat(exp(-r*(1:nPeriods-1)*dt), nSims,1).*CFMatrix(:,2:nPeriods), 2); %discounts all the cashflows (except the first one, t = 0) to AsOfDate

Price = mean(discountedCFs)*DF_AsOfDate;
stdError = std(discountedCFs)./sqrt(nSims);
finalPayments = discountedCFs*exp(r*nPeriods*dt);

end
