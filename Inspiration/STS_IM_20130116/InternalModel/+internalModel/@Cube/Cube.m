%% Cube
% The cube calculates the Market EC values

classdef Cube < handle
    
    properties
        %% Properties
        %
        % * |currency|          _char_
        % * |data|              _double_
        % * |instrumentIDs|  	_cell_
        % * |instrumentNms|  	_cell_
        % * |scenarioHeaders|   _cell_
        
        currency
        data
        instrumentIDs
        instrumentNms
        scenarioHeaders
        path
        
        setName
        scenarioNames
        
    end
    
    
    methods
        %% Methods
        %
        % * |obj = Cube(instCol, scenCol, forexCol, cubeCurrency)|
        % * |EC_GID = calculateMarketEC(obj, portfolio, scenarios, confidence, forex,
        %   reportCurrency, varargin)|
        
        function obj = Cube(instCol, scenCol, forexCol, cubeCurrency)
            %% Cube _constructor_
            % |obj = Cube(instCol, scenCol, forexCol, cubeCurrency)|
            %
            % Input:
            %
            % * |instCol|       _InstrumentCollection_
            % * |scenCol|       _ScenarioCollection_
            % * |forexCol|      _ForeignExchangeCollection_
            % * |cubeCurrency|  _char_
            
            % Initialize
            if isempty(instCol) || isempty(scenCol) || isempty(forexCol)
                error('ing:IncorrectLoading', 'One of the input arguments is empty');
            end
            
            % Set Cube Currency
            obj.currency  = cubeCurrency;
            
            % Find all non-market instruments
            anomIsa       = @(x)isa(x, 'internalModel.NonMarketRisk');
            idxMarketInst = ~cellfun(anomIsa, instCol.Instruments);
            instToValue   = instCol.Instruments(idxMarketInst);
            
            obj.instrumentNms   = cellfun(@(x)(x.Name), instToValue, 'UniformOutput', false);
            obj.instrumentIDs   = cellfun(@(x)(x.ID),   instToValue, 'UniformOutput', false);
            obj.scenarioHeaders = scenCol.Headers;
            obj.setName         = scenCol.SetName;
            obj.scenarioNames   = scenCol.Names;
            
            % Initialize obj.data [n x m] (number of Instruments x number of Scenarios)
            obj.data = zeros(length(obj.instrumentNms), size(scenCol.ScenarioMatrix, 1));
            
        end
        
        function saved = SaveCube(obj, path)
            obj.path = path;
            % To get the path to the ouputFolder, just use the following
            % from Cube level:
            % fullfile(evalin('caller', 'fileparts(obj.parameters.outputFile)'))
            try
                if ~exist(fullfile(path), 'dir')
                    mkdir(fullfile(path));
                end
                save(fullfile(path, 'Cube.mat'), 'obj')
                saved = 1;
            catch ME
                saved = 0;
                fprintf(2,'%s\n', ME.message);
                error('STS:CubeNotSaved', ['Not able to save valuation Cube: ' ME.message]);
            end
            
        end

        function obj = evaluateCube(obj, instCol, scenCol, forexCol, cubeCurrency)
            % Find all non-market instruments
            anomIsa       = @(x)isa(x, 'internalModel.NonMarketRisk');
            idxMarketInst = ~cellfun(anomIsa, instCol.Instruments);
            instToValue   = instCol.Instruments(idxMarketInst);
        
            % Initialize valCube [n x m] (number of Instruments x number of Scenarios)
            valCube = zeros(length(obj.instrumentNms), size(scenCol.ScenarioMatrix, 1));
                        
            for iIns = 1:numel(instToValue)
                % Loop over instruments:
                % Fill Cube using value method of individual instruments.
                % Ensure all selected instruments are denominated in the Cube
                % Currency, use rate conversion if required. Apply FX Shock
                % if applicable
                instrCurrency = instToValue{iIns}.Currency;
                baseFxRate    = 1;
                
                if ~strcmpi(instrCurrency, cubeCurrency)
                    if strcmpi('LOCAL' ,cubeCurrency)
                        baseFxRate = 1;
                    else
                        % Instrument Currency does not match Cube Currency, convert...
                        % Rate Conversion call:
                        baseFxRate = forexCol.getRate(instrCurrency, cubeCurrency);
                    end
                end
                
                % In case this particular Instrument FX Rate is shocked, find its 'fxrd'
                fxrd = ones(size(scenCol.ScenarioMatrix, 1), 1);
                if strcmp(cubeCurrency, 'LOCAL')
                    % Do nothing
                elseif strcmp(cubeCurrency, 'EUR')
                    fxRiskDriver = ['FX_' instrCurrency];
                    idxInMatrix = strcmp(scenCol.Headers, fxRiskDriver);
                    fxrd = scenCol.ScenarioMatrix(:, idxInMatrix);
                elseif strcmp(instrCurrency, 'EUR')
                    fxRiskDriver = ['FX_' cubeCurrency];
                    idxInMatrix = strcmp(scenCol.Headers, fxRiskDriver);
                    fxrd = 1./scenCol.ScenarioMatrix(:, idxInMatrix); % We invert it
                else
                    % We need to multiply several shocks
                    fxRiskDriver(1,:) = ['FX_', instrCurrency];
                    fxRiskDriver(2,:) = ['FX_', cubeCurrency]; % All FX risk factors have 3 letters
                    idxInMatrix1 = strcmp(scenCol.Headers, fxRiskDriver(1,:));
                    idxInMatrix2 = strcmp(scenCol.Headers, fxRiskDriver(2,:));
                    idxInMatrix = idxInMatrix1 | idxInMatrix2; % We get both shocks
                    fxrd = scenCol.ScenarioMatrix(:, idxInMatrix);
                end
                
                % Calculate Shocked FX Rate
                % fxRateShock = exp(fxrd); % OLD version - Wrong --> removing
                % fxRateTot   = baseFxRate .* fxRateShock;
                
                % If No Shocks set all of them to 1
                if isempty(fxrd)
                    fxrd = ones(size(scenCol.ScenarioMatrix, 1), 1);
                end
                
                % Calculate Shocked FX Rate ------ NOTE RELATIVE SHOCKS ARE APPLIED ALWAYS
                if size(fxrd,2)==1
                    fxRateTot   = baseFxRate .* fxrd;
                elseif size(fxrd,2)==2 % We need to derived the shock
                    fxRateTot = baseFXRate.*(fxrd(:,1));
                    fxRateTot = fxRateTot./(fxrd(:,2)); %Second shock is the one for the Domestic Curve
                else
                    error(['Not available Shocks for FX rate for instrument: ', instrument.ID]);
                end
                
                % Add Instrument to Cube
                instrValue       = instToValue{iIns}.value().* fxRateTot;
                valCube(iIns, :) = instrValue;
            end
            
            % Copy valCube to the object
            obj.data = valCube; 
        end
                       
    end % #Methods
    
end % #Cube
