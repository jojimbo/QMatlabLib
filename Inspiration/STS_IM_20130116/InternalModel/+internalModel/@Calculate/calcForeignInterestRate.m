function [obj, instrument] = calcForeignInterestRate(obj, instrument)
%% calcInterestRate
% |obj = calcForeignInterestRate(obj, instrument)|
%
% Interest Rates depend on a tenor and a risk-driver (optional).
% Therefore, Interest Rates are calculated per instrument.
%
%
% Calculate Total Interest Rate:
%
% $r_{tot} = (r_{base} + r_{cs}) \cdot r_{shocked}$
%
% with:
%
% $r_{base}$
% = Base Interest Rate as function of tenor
%
% $r_{cs}$
% = Credit Spread Interest Component as function of riskDriver
%
% $r_{shocked}   = \exp(\sum_{i=1}^4 PCA_i * EV_i(tenor))$
%
% The 'shocked interest' component may be readily available for
% particular tenors. This library is implemented for performance
% purposes: 'Rshocked' is the most demanding interest component,
% re-using is deemed beneficial for large EC Calculations.

if isempty(obj.instCol) || isempty(obj.instCol.Instruments)
    error('ing:Noobjs', 'No objs to calculate interest rate for');
end

if isempty(obj.scenCol)
    error('ing:NoScenarios', 'No scenarios to calculate interest rate for');
end

% NOTE: hard-coded for now...
nrPrincipalComponents = 4;

instclass = class(instrument);
switch instclass
    case 'internalModel.Instruments.ZeroCouponBond'
        return % No Foreign Interest Rate to be calculated
    case 'internalModel.Instruments.FXForward'
        targets = instrument.TimeToMaturity;
    case 'internalModel.Instruments.FXSwap'
        targets = instrument.TimeToMaturity;
    case 'internalModel.Instruments.FXIRSwap'
        targets = instrument.ForeignPaymentTimes;
    case 'internalModel.Instruments.FXOption'
        targets = instrument.TimeToMaturity;
    case 'internalModel.Instruments.EQIndex'
        return;
end


% 1. Skip 'NonMarketRisk' objs
if isa(instrument, 'internalModel.NonMarketRisk')
    % No need to calculate Foreign Interest Rate
    return;
end

% _________________________________________________________
% 2. Determine Base Interest Component
curve = obj.scenCol.Curves.findCurveByName(instrument.ForeignCurve);

if isempty(curve)
    instrument = [];
    error('STS_CM:CalcDomesticInterestRate', ...
        ['Domestic curve not found for obj ', instrument.Name]);
    return
end

% Generic Interpolation method
rBase = internalModel.Util.Interpolation(targets, ...
    curve.Data, {curve.Tenor}, 'linear');

% _________________________________________________________
% 3. Determine Shocked Interest Component
%    Check whether Name - Tenor combination is already in shockedInterestLib.
%    If so, re-use 'shocked' interest component
%
for iTenor = 1:numel(targets)
    % Collect library index for Shocked Interest, if available
    if ~isempty(obj.shockedInterestLib)
        idxInLib = strcmp(obj.shockedInterestLib(:, 1), instrument.ForeignCurve) ...
                    & strcmp(obj.shockedInterestLib(:, 2), targets(iTenor));
    else
        idxInLib = 0;
    end
    
    
    if any(idxInLib)
        % Already calculated, so reuse it
        rShocks = obj.shockedInterestLib{idxInLib, 3};
        
    else
        % New Name - Tenor (Base - Tenor) combination
        idxPca = strcmp(instrument.ForeignCurrency, {obj.scenCol.PcaValues.currency});
        
        if ~any(idxPca)
            error('Calculate:IdxNotFound', ['Currency ' instrument.ForeignCurrency ...
                ' not found']);
        end
        
        %Interpolate PCA Eigen Vector
        PcaEigenVec = internalModel.Util.Interpolation(...
            {targets}, ...
            obj.scenCol.PcaValues(idxPca).EV, ...
            {obj.scenCol.PcaValues(idxPca).Term}, ...
            'linear' ...
            );
        %obj.scenCol.PcaValues(idxPca), ...
        %                obj.Tenor);
        %
        
        nrScen      = size(obj.scenCol.ScenarioMatrix, 1);
        PcaPerScen  = zeros(nrScen, nrPrincipalComponents);
        
        for iPca = 1:nrPrincipalComponents
            riskFactor  = strcat('IR_', instrument.ForeignCurrency, 'PC', num2str(iPca));
            idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
            if ~any(idxInMatrix)
                disp(['No shocks found for ' riskFactor ...
                    ', shocks set to 0.0']);
                PcaPerScen(:, iPca) = zeros(size(obj.scenCol.ScenarioMatrix(:, idxInMatrix), 1),1);
            else
                PcaPerScen(:, iPca) = obj.scenCol.ScenarioMatrix(:, idxInMatrix);
            end
        end
        
        % Calculate 'shocked' interest component
        rShocks = exp(PcaPerScen * PcaEigenVec');
%         for iScen = 1:nrScen
%             for iTarget = 1:numel(targets)
%                 % One column of shocks per target
%                 rShocks(iScen, iTarget) = exp(sum(PcaPerScen(iScen, :) + PcaEigenVec(iTarget, :)));
%             end
%         end
        % We transpose to column if it's not like that yet
        if isrow(rShocks)&& ~isscalar(rShocks); rShocks = rShocks'; end
        
        % Store new interest rates in library for future reuse
        obj.shockedInterestLib{end + 1, 1} = instrument.ForeignCurve;
        obj.shockedInterestLib{end, 2}     = targets;
        obj.shockedInterestLib{end, 3}     = rShocks;
    end
end

% _________________________________________________________
% 4. Determine Credit Spread Interest Component
%    (NOTE: optional component!)
rCS = 0;

if ~isempty(obj.creditSpread)
    % Define interest-rate credit-spread for this obj:
    % +. Collect obj CSID and RiskDriver
    instrCS    = instrument.CreditSpread;
    csidInd    = strcmpi(obj.creditSpread(:, 1), instrCS);
    riskDriver = obj.creditSpread(csidInd, 4);
    
    % +. Validate Risk Driver and calculate rCS
    % Only one driver is allowed
    if ~isempty(riskDriver) && eq(numel(riskDriver), 1)
        % Find scenario CS Risk Drivers
        idxInMatrix = strcmp(obj.scenCol.Headers, riskDriver);
        csrd = obj.scenCol.ScenarioMatrix(:, idxInMatrix);
        
        % Only one Scenario Risk Driver is allowed.
        % Number of elements must match 'rShocks'
        if eq(find(numel(idxInMatrix)), 1) && ...
                eq(numel(rShocks), numel(csrd))
            
            % Collect Credit Spread 'mean' and 'volatility'
            mean = obj.creditSpread{csidInd, 2};
            vol  = obj.creditSpread{csidInd, 3};
            
            % Calculate rCS
            rCS  = mean + csrd .* vol;
        end
    end
end

% _________________________________________________________
% 5. Calculate Total Interest
rTot = zeros(size(rShocks, 1), numel(rBase));

for iBase = 1:numel(rBase)
    rTot(:, iBase) = (rBase(iBase) + rCS) .* rShocks(:, iBase);
end
% We revert the Base rate to the one without any shock
rTot(1,:) = rBase;

% Propagate total interest rate to obj object member
switch instclass
    case 'internalModel.Instruments.ZeroCouponBond'
        error('STS_CM:ImplementationError', ...
            'Should have not reached this for ZeroCouponBond');
        return % Should not reach here
    case 'internalModel.Instruments.FXForward'
        instrument.foreignInterestRate = rTot;
    case 'internalModel.Instruments.FXSwap'
        instrument.foreignInterestRate = rTot;
    case 'internalModel.Instruments.FXIRSwap'
        instrument.foreignInterestRate = rTot;
    case 'internalModel.Instruments.FXOption'
        instrument.foreignInterestRate = rTot;
end


end
