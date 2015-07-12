function [obj, instrument] = calcShockedFXRates(obj, instrument)
%% calcShockedFXRates
% |[obj, instrument] = calcShockedFXRates(obj, instrument)|

% Gets the FX pair to be shocked
instclass = class(instrument);
switch instclass
    case 'internalModel.Instruments.ZeroCouponBond'
        return; % No FX Rate to be shocked
    case 'internalModel.Instruments.FXForward'
        baseFXRate = obj.forexCol.getRate(instrument.ForeignCurrency, instrument.DomesticCurrency);
    case 'internalModel.Instruments.FXSwap'
        baseFXRate = obj.forexCol.getRate(instrument.ForeignCurrency, instrument.DomesticCurrency);
    case 'internalModel.Instruments.FXIRSwap'
        baseFXRate = obj.forexCol.getRate(instrument.ForeignCurrency, instrument.DomesticCurrency);
    case 'internalModel.Instruments.FXOption'
        baseFXRate = obj.forexCol.getRate(instrument.ForeignCurrency, instrument.DomesticCurrency);
% NOTE on baseFXRate: getRate(startCurrency ('GBP'), targetCurrency('EUR')), so 1.2361 would be GBP/EUR in market convention
    case 'internalModel.Instruments.EQIndex'
        return;
end

% Get shocks to apply
if strcmp(instrument.DomesticCurrency, 'EUR')
    riskFactor  = ['FX_', instrument.ForeignCurrency];
    idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
    shocksToApply = obj.scenCol.ScenarioMatrix(:, idxInMatrix);
else
    % In case the DomesticCurrency is not EUR (e.g. GBP), we need to get the right shock to apply
    if strcmp(instrument.ForeignCurrency, 'EUR')
        % If the foreign is EUR then we just need to shock using 1/FX_GBP(shock)
        riskFactor  = ['FX_', instrument.DomesticCurrency];
        idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
        shocksToApply = 1./obj.scenCol.ScenarioMatrix(:, idxInMatrix); % We invert it
    else
        % We need to multiply several shocks
        riskFactor(1,:) = ['FX_', instrument.ForeignCurrency];
        riskFactor(2,:) = ['FX_', instrument.DomesticCurrency]; % All FX risk factors have 3 letters
        idxInMatrix1 = strcmp(obj.scenCol.Headers, riskFactor(1,:));
        idxInMatrix2 = strcmp(obj.scenCol.Headers, riskFactor(2,:));
        %idxInMatrix = idxInMatrix1 | idxInMatrix2; % We get both shocks
        shocksToApply = obj.scenCol.ScenarioMatrix(:, idxInMatrix1);
        shocksToApply = [shocksToApply obj.scenCol.ScenarioMatrix(:, idxInMatrix2)];
    end
end

% If No Shocks (Base scenario) set all of them to 1
if isempty(shocksToApply)
    disp(['No shocks found for ' instrument.DomesticCurrency '/'...
        instrument.ForeignCurrency ', all the shocks set to 1.0']);
    shocksToApply = ones(size(shocksToApply,1),1);
end

% Calculate shocked FX Rates ------ NOTE RELATIVE SHOCKS ARE APPLIED ALWAYS
if size(shocksToApply,2)==1
    shockedFXRate = baseFXRate.*(shocksToApply);
elseif size(shocksToApply,2)==2 % We need to derived the shock
    shockedFXRate = baseFXRate./(shocksToApply(:,2));
    shockedFXRate = shockedFXRate.*(shocksToApply(:,1)); %First shock is the one for the Domestic Curve
else
    error(['Not available Shocks for FX rate for instrument: ', instrument.ID]);
end

% Propagate shocked properties
switch instclass
    case 'internalModel.Instruments.FXForward'
        instrument.spotPrice = shockedFXRate;
    case 'internalModel.Instruments.FXSwap'
        instrument.spotPrice = shockedFXRate;
    case 'internalModel.Instruments.FXIRSwap'
        instrument.spotPrice = shockedFXRate;
    case 'internalModel.Instruments.FXOption'
        instrument.spotPrice = shockedFXRate;
end


end
