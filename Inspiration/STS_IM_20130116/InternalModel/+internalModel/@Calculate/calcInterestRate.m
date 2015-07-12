function obj = calcInterestRate(obj)
%% calcInterestRate
% |obj = calcInterestRate(obj)|
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
    error('ing:NoInstruments', 'No instruments to calculate interest rate for');
end

if isempty(obj.scenCol)
    error('ing:NoScenarios', 'No scenarios to calculate interest rate for');
end

% NOTE: hard-coded for now...
nrPrincipalComponents = 4;

% Loop over instruments
for iInst = 1:numel(obj.instCol.Instruments)

    % 1. Skip 'NonMarketRisk' instruments
    if isa(obj.instCol.Instruments{iInst}, 'internalModel.NonMarketRisk')
        % No need to calculate interestRate
        continue;
    end

    % _________________________________________________________
    % 2. Determine Base Interest Component
    curve = obj.scenCol.Curves.findCurveByName(obj.instCol.Instruments{iInst}.DomesticCurve);

    if isempty(curve)
        obj.instCol.Instruments{iInst} = [];
        continue
    end
    
    % We remove this and call the generic Interpolation method
%     rBase = curve.interp(obj.instCol.Instruments{iInst}.Tenor);
    rBase = internalModel.Util.Interpolation({obj.instCol.Instruments{iInst}.Tenor}, curve.Data, {curve.Tenor});

    % _________________________________________________________
    % 3. Determine Shocked Interest Component
    %    Check whether Name - Tenor combination is already in shockedInterestLib.
    %    If so, re-use 'shocked' interest component
    % 
    for iTenor = 1:numel(obj.instCol.Instruments{iInst}.Tenor)
        % Collect library index for Shocked Interest, if available
        if ~isempty(obj.shockedInterestLib)
            idxInLib = strcmp(obj.shockedInterestLib(:, 1), obj.instCol.Instruments{iInst}.DomesticCurve) ...
                        & strcmp(obj.shockedInterestLib(:, 2), obj.instCol.Instruments{iInst}.Tenor(iTenor));
        else
            idxInLib = 0;
        end


        if any(idxInLib)
            % Already calculated, so reuse it
            rShocks = obj.shockedInterestLib{idxInLib, 3};

        else
            % New Name - Tenor (Base - Tenor) combination
            idxPca = strcmp(obj.instCol.Instruments{iInst}.Currency, {obj.scenCol.PcaValues.currency});

            if ~any(idxPca)
                error('Calculate:IdxNotFound', ['Currency ' obj.instCol.Instruments{iInst}.Currency ...
                    ' not found']);
            end

            % Interpolate PCA Eigen Vector
            % We remove this and call the generic Interpolation method
%             PcaEigenVec = obj.scenCol.interpPCA(obj.scenCol.PcaValues(idxPca), ...
%                             obj.instCol.Instruments{iInst}.Tenor);
            PcaEigenVec = internalModel.Util.Interpolation(...
                {obj.instCol.Instruments{iInst}.Tenor}, ...
                obj.scenCol.PcaValues(idxPca).EV, ...
                {obj.scenCol.PcaValues(idxPca).Term}...
                );
            %obj.scenCol.PcaValues(idxPca), ...
            %                obj.instCol.Instruments{iInst}.Tenor);            
            %
            
            nrScen      = size(obj.scenCol.ScenarioMatrix, 1);
            PcaPerScen  = zeros(nrScen, nrPrincipalComponents);

            for iPca = 1:nrPrincipalComponents
                riskFactor  = strcat('IR_', obj.instCol.Instruments{iInst}.Currency, 'PC', num2str(iPca));
                idxInMatrix = strcmp(obj.scenCol.Headers, riskFactor);

                PcaPerScen(:, iPca) = obj.scenCol.ScenarioMatrix(:, idxInMatrix);
            end

            % Calculate 'shocked' interest component
            rShocks = exp(PcaPerScen * PcaEigenVec');

            % Store new interest rates in library for future reuse
            obj.shockedInterestLib{end + 1, 1} = obj.instCol.Instruments{iInst}.DomesticCurve;
            obj.shockedInterestLib{end, 2}     = obj.instCol.Instruments{iInst}.Tenor;
            obj.shockedInterestLib{end, 3}     = rShocks;
        end
    end

    % _________________________________________________________
    % 4. Determine Credit Spread Interest Component
    %    (NOTE: optional component!)
    rCS = 0;

    if ~isempty(obj.creditSpread)
        % Define interest-rate credit-spread for this instrument:
        % +. Collect Instrument CSID and RiskDriver
        instrCS    = obj.instCol.Instruments{iInst}.CreditSpread;
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

    % Propagate total interest rate to instrument object member
    obj.instCol.Instruments{iInst}.interestRate = rTot;

end

end
