
function [Price, stdError, finalPayments] = MCPrice(Instrument, StockSimPaths, AsOfDate)
    %% MCPrice Function - Monte Carlo price for an instrument given simulations
    %
    % MCPrice SYNTAX:
    %   P = MCPrice(Instrument, StockSimPaths, AsOfDate)
    %
    % MCPrice DESCRIPTION:
    %   Returns Monte Carlo price for the Instrument passed in, using the
    %   StockSimPaths provided, and at date AsOfDate
    %
    % MCPrice INPUTS:
    %   1. Instrument - As an Instrument object
    %   2. StockSimPaths - As a TimeSeries object with #rows=#steps and #columns=#sims
    %   3. AsOfDate - Date of valuation
    %
    % MCPrice OPTIONAL INPUTS:
    %   [None]
    %
    % MCPrice OUTPUTS:
    %   1. Price - Monte Carlo price for the instrument at date AsOfDate
    %   2. stdError - Standard error of the price calculated
    %   3. finalPayments [OPTIONAL] - Vector with final Payments for all
    %   simulation paths (can be used for VaR for example)
    %
    %% Function MCPrice
    % Copyright 1994-2016 Riskcare Ltd.
    %

%
%% Extract simulation paths
Sims = StockSimPaths.Data;
nSims = size(Sims,2); % Assumption that StockSimPaths has (#rows=#steps, #columns=#sims) - TODO - change to be flexible
%
%% Compute discount factor from Maturity
% All of this should be removed once the storage map for curves is ready:
cf = engine.factories.CurveFactory;
% TODO - These 3 lines will be removed once the storage map for curves is ready
% We would simply retrieve the previously created curve (as opposed to creating one)
r=0.04;
Dates = daysadd(AsOfDate,360*[0 1],1); % 1 for 30/360 convention
discCurve = cf.get('Flat_IRCurve', AsOfDate, Dates, r,'Compounding', -1, 'Basis', 0); % 0 for Act/Act

if datenum(AsOfDate) < datenum(discCurve.Settle)
    error(message('+quant.methods:MCPrice:CurveSettleDateBeforeAsOfDate'));
end
% Discount factor from AsOfDate to discCurve.Settle
DF_AsOfDate = discCurve.getDiscountFactors(AsOfDate); % Would be 1 if AsOfDate == discCurve.Settle
DF_Maturity = discCurve.getDiscountFactors(Instrument.MaturityDate);

%
%% Calculate price and standard error
finalPayments = Instrument.EvaluatePayoff(Sims);
avgPayoff = sum(finalPayments)./nSims;

Price = (DF_Maturity/DF_AsOfDate).*(avgPayoff);
stdError = (sqrt(sum(finalPayments.^2)./nSims) - avgPayoff.^2)./sqrt(nSims); %std(finalPayments)./sqrt(n_sim)

%
%% End Function
end