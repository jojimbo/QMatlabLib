function EC_GID = calculateMarketEC(obj, portfolio, scenarios, confidence, forex, reportCurrency, varargin)
%% calculateMarketEC
% |EC_GID = calculateMarketEC(obj, portfolio, scenarios, confidence,
% forex, reportCurrency, varargin)|
% 
% This method calculates the Market Economic Capital for a particular
% portfolio. The user may specify which GID's to included.
% 
% Inputs:
% 
% * |portfolio|         _Portfolio_
% * |scenarios|         _ScenarioCollection_
% * |confidence|        _double_
% * |forex|             _ForeignExchange_
% * |reportCurrency|    _char_
% * |varargin|          _cell_
EC_GID  = [];

% 1. Determine Analysis GID's. In case the user does not specify
%    a subset of GID's, the method automatically includes all
%    available GID's in the portfolio.
findGID = @(x)(x.GID);
gidAll  = cellfun(findGID, portfolio.groups);

% Process user input
if ~isempty(varargin)
    % User specified subset of GID's
    gidSelect   = varargin{1};
    gidAnalysis = intersect(gidSelect, gidAll);

else
    % No guidance, just include all GID's
    gidAnalysis = gidAll;
end

% Return in case no valid subset is available. This could be due to
% either invalid user input, or an inviable/corrupted portfolio
if isempty(gidAnalysis)
    error('ing:IncorrectLoading', 'Invalid GID selection');
end

% 2. Calculate Market EC
%    Initialize EC_GID. The structure contains both the GID ID's
%    and EC's (for referencing purposes).
EC_GID.val = zeros(numel(gidAnalysis), 1);
EC_GID.ids = gidAnalysis';
EC_GID.PnL = {};

% Loop over each analysis GID and calculate EC
for GIDindex = 1:numel(gidAnalysis)
    % 1. Try to identify unique Instrument ID's and WeightFactors
    %    for this particular GID
    try
        % Identify instruments
        [unInstrIDs, uninstrWeight] = portfolio.aggregateElements(gidAnalysis{GIDindex}, false);

    catch ME %#ok<NASGU>
        % Identification failed, continue with next portfolio GID entry
        %warning('ing:InvalidInput', ME.message);
    end

    % Check whether unInstrIDs is empty, if not, return
    if isempty(unInstrIDs)
        return
    end

    % 2. Convert Cube to reporting currency
    cubeCurrency = obj.currency;
    fxRateBase   = 1;

    % 2.1. Find Base Fx Rate
    if ~strcmpi(cubeCurrency, reportCurrency)
        % Rate Conversion call:
        fxRateBase = forex.getRate(reportCurrency, cubeCurrency);
    end

    % 2.2. Find and apply Shock Fx Rate
    fxrdReport    = zeros(size(scenarios.ScenarioMatrix, 1), 1);
    fxrdReportIdx = strcmp(scenarios.Headers, ['FX_' reportCurrency]);

    if any(fxrdReportIdx)
        % FX Risk Driver found for Reporting Currency
        fxrdReport = scenarios.ScenarioMatrix(:, fxrdReportIdx);
    end

    % 2.3. Calculate and apply Shocked FX Rate to 'cubeData'
    fxRateTot = 1 ./ (fxRateBase .* exp(fxrdReport(:)));
    fxRateTot = repmat(fxRateTot', size(obj.data, 1), 1);
    cubeData  = obj.data .* fxRateTot;

    % 3. Map GID's instruments to the instrument arrangement in the Cube
    [~, selectIdxCube, selectIdxPF] = intersect(obj.instrumentIDs, unInstrIDs);
    selInstrWeight = uninstrWeight(selectIdxPF);
    selection      = diag(selInstrWeight) * cubeData(selectIdxCube, :);

    % Select base and shocked scenarios
    base    = selection(:, 1);
    shocked = selection(:, 2:end);

    % 4. Calculate EC Value by picking specific confidence level / quantile
    EC_dist = sum(((base * ones(1, size(shocked, 2))) - shocked), 1);

    % Store this GID EC
    if isempty(EC_dist)
        % Prevent 'quantile' operation on an empty array
        EC_GID.val(GIDindex) = 0;

    else
        % Succes scenarion, calculate quantile
        EC_GID.val(GIDindex) = quantile(EC_dist, confidence);
        % Store EC_dist vector as well
        EC_GID.PnL(GIDindex) = {EC_dist};
    end
end

EC_GID.PnL = EC_GID.PnL'; % we want it in column format
EC_GID.PnL = cell2mat(EC_GID.PnL); % transform into a double array, more convenient for output in csv format, though it works with cell array as well

end
