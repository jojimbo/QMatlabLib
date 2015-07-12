%% Equity
% Reads a Equity data file containing Equity prices

classdef Equity

    properties
        %% Properties
        % 
        % * |sourceFile|        _char_
        % * |prices|            _double_
        % * |names|             _cell_
        % * |identifiers|       _cell_
        % * |currencies|        _cell_
        sourceFile
        names
        identifiers
        prices
        currencies
        dates
    end % #Properties


    methods
        %% Methods
        %
        % * |obj = Equity(calcObj)|                        _constructor_
        % * |rate = getEQPrice(obj, startCurrency, targetCurrency)|

        function obj = Equity(calcObj)
            %% Equity _constructor_
            % |obj = Equity(calcObj)|
            % 
            % Inputs:
            % 
            % * |calcObj|    _Calculate_

            % Collect exchange rates from Configuration object
            eqre = calcObj.configuration.csvFileContents.('equityReFile');

            % Fill Foreign Exchange Object
            obj.names               = eqre.names;
            obj.identifiers         = eqre.identifiers;
            obj.prices              = eqre.GeneIndxSufNODE;
            obj.currencies          = eqre.curveUnits;
            obj.dates               = eqre.dates;
            obj.sourceFile          = eqre.csvFileName;

        end % #Constructor


        function [price currency]= getEQPrice(obj, identifier)
            %% getRate
            % |price = getEQPrice(obj, startCurrency, targetCurrency)|
            % 
            % Derive rate between 'start' and 'target' currency
            % 
            % Inputs:
            % 
            % * |identifier|            _char_
            % 
            % Outputs:
            % 
            % * |price|                 _double_
            % * |currency|              _char_

            % Find identifier in Equity list
            Idx  = strcmp(obj.identifiers, identifier);

            % Check availability
            if ~any(Idx)
                error('STS_CM:Equity:NoRateFound', ['No equity index found for: ' identifier])
            end

            % Validate 'Idx'
            if sum(Idx) > 1
                error(['STS_CM:Equity:DuplicateIndexFound', 'Multiple equity indices found for: ' identifier])
            end

            % Collect price and currency
            price       = obj.prices{Idx};
            currency    = obj.currencies{Idx};
            
        end % #getEQPrice

    end % #Methods

end % #Equity
