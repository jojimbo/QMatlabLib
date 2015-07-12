function [obj, instrument] = calcShockedFXIV(obj, instrument)
%% calcShockedFXIV
% |[obj, instrument] = calcShockedFXRates(obj, instrument)|

% We get the Base FXIV (the one in the fx implied vol market data file)

fxVolNames = obj.scenCol.forexIVSurfaces.CurveNames';
% Gets the FX pair to be shocked
instclass = class(instrument);
switch instclass
    case 'internalModel.Instruments.ZeroCouponBond'
        return; % No FXIV to be shocked
    case 'internalModel.Instruments.FXForward'
        return; % No FXIV to be shocked
    case 'internalModel.Instruments.FXSwap'
        return; % No FXIV to be shocked
    case 'internalModel.Instruments.FXIRSwap'
        return; % No FXIV to be shocked
    case 'internalModel.Instruments.FXOption'
        fxVolInst = strcat(instrument.DomesticCurrency, '/', instrument.ForeignCurrency, '_Volatility_Surface');
        fxVolFactorInst = strcat(instrument.DomesticCurrency, '/', instrument.ForeignCurrency, '-Vol-Factor');
        % instrument.Moneyness: we assume the spotPrices have been
        % calculated before in the calcShockedFXRates method
        instrument.Moneyness = instrument.StrikePrice./instrument.spotPrice;
        targets1 = instrument.TimeToMaturity;
        targets2 = instrument.Moneyness;
    case 'internalModel.Instruments.EQIndex'
        return;
end
% Not needed:
[~, ~, idxFXIVCol]=intersect(fxVolInst, fxVolNames);
indirectFlag = 0;
% If it is empty we try to get the indirect rate (reciprocal)
% E.g. If USD/EUR is not present, we try to retreive EUR/USD and later inverse it
if isempty(idxFXIVCol)
    switch instclass
        case 'internalModel.Instruments.ZeroCouponBond'
            return; % No FXIV to be shocked
        case 'internalModel.Instruments.FXForward'
            return; % No FXIV to be shocked
        case 'internalModel.Instruments.FXSwap'
            return; % No FXIV to be shocked
        case 'internalModel.Instruments.FXIRSwap'
            return; % No FXIV to be shocked
        case 'internalModel.Instruments.FXOption'
            fxVolInst2 = strcat(instrument.ForeignCurrency, '/', instrument.DomesticCurrency, '_Volatility_Surface');
            fxVolFactorInst2 = strcat(instrument.DomesticCurrency, '/', instrument.ForeignCurrency, '-Vol-Factor');
    end
    %[~, ~, idxFXIVCol]=intersect(fxVolInst2, fxVolNames); % Not used
    try
        indirectFlag = 1;
        baseFXIV = obj.scenCol.forexIVSurfaces.findCurveByName(fxVolInst2);
        volFactors = obj.scenCol.fxVolFactors.findCurveByName(fxVolFactorInst2);
    catch ME
        error('STS_CM:calcShockedFXIV', ...
            ['FXIV for ', fxRateInst, ' not found in the fx implied vol market data file']),
    end
    
else
    try
        indirectFlag = 0;
        %baseFXRate = obj.forexCol.rates{idxFXCol};
        baseFXIV = obj.scenCol.forexIVSurfaces.findCurveByName(fxVolInst);
        volFactors = obj.scenCol.fxVolFactors.findCurveByName(fxVolFactorInst);
    catch ME
        error('STS_CM:calcShockedFXIV', ...
            ['FXIV for ', fxRateInst, ' not found in the fx implied vol market data file']),
    end
end

% Interpolate baseFXIV for relevant moneyness and term
try
    instrumentFXIV = internalModel.Util.Interpolation(...
        {targets1 targets2}, ...
        baseFXIV.Data, ...
        {baseFXIV.Term, baseFXIV.Moneyness}, ...
        'linear' ...
        );
catch ME
    error('STS_CM:calcShockedFXIV', ...
        ['Failed interpolation for Base FX IV for ' fxVolInst])
end

% Interpolate FX Vol factors for relevant moneyness and term
try
    if numel(volFactors.Moneyness) == 1
        % Only one Moneyness available for the Vol Factors,
        % we can call interpolation just as if it was 1D (bit faster)
        instrumentFXVolFactors = internalModel.Util.Interpolation(...
            {targets1}, ...
            volFactors.Data, ...
            {volFactors.Term}, ...
            'linear' ...
            );
    else
        instrumentFXVolFactors = internalModel.Util.Interpolation(...
            {targets1 targets2}, ...
            volFactors.Data, ...
            {volFactors.Term, volFactors.Moneyness}, ...
            'linear' ...
            );
    end
catch ME
    error('STS_CM:calcShockedFXIV', ...
        ['Failed interpolation for FX Vol Factors for ' fxVolInst])
end

% Get shocks to apply
if indirectFlag
    riskFactor  = ['FXIV_', instrument.DomesticCurrency];
else
    riskFactor  = ['FXIV_', instrument.ForeignCurrency];
end
idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
shocksToApply = obj.scenCol.ScenarioMatrix(:, idxInMatrix);

% If No Shocks (Base scenario) set all of them to 0
if isempty(shocksToApply)
    disp(['No shocks found for ' fxVolInst ', all the shocks set to 1.0']);
    shocksToApply = ones(size(shocksToApply,1),1);
end

% We transpose everything to column vectors
if isrow(instrumentFXIV)&& ~isscalar(instrumentFXIV); instrumentFXIV = instrumentFXIV'; end
if isrow(instrumentFXVolFactors)&& ~isscalar(instrumentFXVolFactors); instrumentFXVolFactors = instrumentFXVolFactors'; end
if isrow(shocksToApply)&& ~isscalar(shocksToApply); shocksToApply = shocksToApply'; end

% Calculate shocked FX Implied Vols ------ NOTE RELATIVE SHOCKS ARE ALWAYS APPLIED 
if indirectFlag
    shockedFXIV = instrumentFXIV.*(1+instrumentFXVolFactors.*(shocksToApply-1)); % Same behaviour as direct one, since we are shocking volatility
else % STANDARD BEHAVIOUR
    shockedFXIV = instrumentFXIV.*(1+instrumentFXVolFactors.*(shocksToApply-1));
end

% Propagate shocked properties
switch instclass
    case 'internalModel.Instruments.FXOption'
        instrument.volatility = shockedFXIV;
end


end
