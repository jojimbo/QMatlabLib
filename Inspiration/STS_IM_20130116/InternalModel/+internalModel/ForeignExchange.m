%% ForeignExchange
% Reads a foreign exchange data file containing FX rates

classdef ForeignExchange

    properties
        %% Properties
        % 
        % * |sourceFile|        _char_
        % * |rates|             _double_
        % * |startCurrencies|   _cell_
        % * |targetCurrencies|  _cell_
        sourceFile
        rates
        startCurrencies
        targetCurrencies

    end % #Properties


    methods
        %% Methods
        %
        % * |obj = ForeignExchange(calcObj)|                        _constructor_
        % * |rate = getRate(obj, startCurrency, targetCurrency)|

        function obj = ForeignExchange(calcObj)
            %% ForeignExchange _constructor_
            % |obj = ForeignExchange(calcObj)|
            % 
            % Inputs:
            % 
            % * |calcObj|    _Calculate_

            % Collect exchange rates from Configuration object
            forex = calcObj.configuration.csvFileContents.('forexFile');

            % Fill Foreign Exchange Object
            obj.startCurrencies  = forex.startCurrencies;
            obj.targetCurrencies = forex.targetCurrencies;
            obj.rates            = forex.rates;
            obj.sourceFile       = forex.csvFileName;

        end % #Constructor


        function rate = getRate(obj, startCurrency, targetCurrency)
            %% getRate
            % |rate = getRate(obj, startCurrency, targetCurrency)|
            % 
            % Derive rate between 'start' and 'target' currency
            % 
            % Inputs:
            % 
            % * |startCurrency|     _char_
            % * |targetCurrency|    _char_
            % 
            % Outputs:
            % 
            % * |rate|              _double_

            % Find bench- and target FX Rates in Forex Object
            benchRateIdx  = strcmp(obj.targetCurrencies, startCurrency);
            targetRateIdx = strcmp(obj.targetCurrencies, targetCurrency);

            % Check FX Rate availability
            if ~any(benchRateIdx)
                error('ing:NoRateFound', ['No exchange rate found for: ' startCurrency])
            end
            if ~any(targetRateIdx)
                error('ing:NoRateFound', ['No exchange rate found for: ' targetCurrency])
            end

            % Validate 'targetRateIdx'
            if sum(targetRateIdx) > 1
                error('ing:DuplicateRatesFound', 'Multiple exchange rates found for this combination')
            end

            % Collect bench- and target rates
            benchFxRate  = obj.rates{benchRateIdx};
            targetFxRate = obj.rates{targetRateIdx};

            % Wrap in try-catch to prevent 'devide by zero' errors
            try
                % Calculate conversion rate: first convert to EUR, from
                % StartCurrency, then convert to TargetCurrency
                rate = benchFxRate / targetFxRate;

            catch ME
                % Rate calculation not succesful, revert to ratio '1'
                rate = 1;
                warning('ing:InvalidInput', ME.message);
            end

        end % #getRate

    end % #Methods

end % #ForeignExchange
