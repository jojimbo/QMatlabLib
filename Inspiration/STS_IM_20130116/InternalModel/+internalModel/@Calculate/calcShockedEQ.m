function [obj, instrument] = calcShockedEQ(obj, instrument)
%% calcShockedEQ
% |[obj, instrument] = calcShockedEQ(obj, instrument)|

% Gets the EQ Indices to be shocked
instclass = class(instrument);
switch instclass
    case 'internalModel.Instruments.ZeroCouponBond'
        return;
    case 'internalModel.Instruments.FXForward'
        return;
    case 'internalModel.Instruments.FXSwap'
        return;
    case 'internalModel.Instruments.FXIRSwap'
        return;
    case 'internalModel.Instruments.FXOption'
        return;
    case 'internalModel.Instruments.EQIndex'
        instCurrency        = instrument.Currency;
end

for iUnd = 1:numel(instrument.Underlyings)
    ref =  instrument.Underlyings(iUnd).Ref(ismember(instrument.Underlyings(iUnd).Ref,['A':'Z', '_']));
    while ref(end) == '_'
        ref(end) ='';
    end
    if ismember(['.' ref '-Index Curve'], obj.equityreCol.identifiers)
        [undPrice undCCY] = ...
            obj.equityreCol.getEQPrice(['.' ref '-Index Curve']);
    elseif ismember([ref '-Index Curve'], obj.equityreCol.identifiers)
        [undPrice undCCY] = ...
            obj.equityreCol.getEQPrice([ref '-Index Curve']);
    else
        warning([ref ' not in equity market data file...']);
        [undPrice undCCY] = ...
            obj.equityreCol.getEQPrice([ref '-Index Curve']);
    end
    riskFactor  = ['EQ_', ref];
    idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
    if ~any(idxInMatrix)
        aux = (regexp(ref, '_', 'split'));
        riskFactor  = ['EQ_', aux{1}];
        idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);
    else
        % Nothing, include other possibilities for the string in riskFactor
        % if they are introduced
    end
    shocksToApply = obj.scenCol.ScenarioMatrix(:, idxInMatrix);
    % If No Shocks (Base scenario) set all of them to 1
    if isempty(shocksToApply)
        disp(['No shocks found for ' ref ...
            ', all the shocks set to 1.0']);
        shocksToApply = ones(size(shocksToApply,1),1);
    end
    shockedEQ = undPrice.*(shocksToApply);
    % Propagate shocked properties
    switch instclass
        case 'internalModel.Instruments.EQIndex'
            instrument.spotPrice(:,iUnd)    = undPrice; % we are expecting the same as the shockedEQ(1,iUnd);
            instrument.shockedEQ(:, iUnd)   = shockedEQ;
            instrument.weights(:, iUnd)     = instrument.Underlyings(iUnd).Weight;
            instrument.Underlyings(iUnd).baseEQPrice       = undPrice;
            instrument.Underlyings(iUnd).shockedEQPrice    = shockedEQ;
            
    end
end


end
