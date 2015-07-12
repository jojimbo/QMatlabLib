%% FXForward
% subclass of internalModel.Instrument
% 
%%

classdef FXForward < internalModel.Instrument

    %% Properties
    % 
    % * |Notional|      _double_
    % * |DomesticCurrency| _char_
    % * |ForeignCurrency| _char_
    % * |DomesticCurve| _char_
    % * |ForeignCurve| _char_
    % * |MaturityDate| _char_
    % * |SpotPriceVAL| _double_
    % * |StrikePrice| _double_
    % * |TimeToMaturity| _double_
    % 
    

    properties
        DomesticCurrency
        ForeignCurrency
        DomesticCurve
        ForeignCurve
        MaturityDate
        SpotPriceVAL % not clear what this represents in the input file, market price?
        StrikePrice
        Notional
        
        TimeToMaturity
        % The following 2 properties should ideally not be part of the
        % FXForward object, but they are here for now to quickly price
        % FXForwards within the current architecture
        domesticInterestRate
        foreignInterestRate
        spotPrice

    end % #Properties


    %% Methods
    % 
    % * |obj = FXForward(obj) = FXForward(instrID,instName, DomesticCurrency, ForeignCurrency, DomesticDiscountCurve, ForeignDiscountCurve, timeToMaturity, ForwardSpotPrice,StrikePrice)|
    % * |val = value(this, scenarioCollection)|

    methods
        function obj = FXForward(name, instrID, currency, ...
                domesticCurrency, foreignCurrency, ...
                domesticCurve, foreignCurve, ...
                maturityDate, valuationDate,...
                SpotPriceVAL, strikePrice)
            %% FXForward _constructor_
            % |obj = FXForward(instrID,instName, DomesticCurrency, ForeignCurrency, DomesticDiscountCurve, ForeignDiscountCurve, timeToMaturity, ForwardSpotPrice, StrikePrice)|
           
            % Inputs:
            
            % * |instrID|               _char_
            % * |instName|              _char_
            % * |DomesticCurrency|      _char_
            % * |ForeignCurrency|       _char_
            % * |DomesticCurve| _char_
            % * |ForeignCurve|  _char_
            % * |MaturityDate|          _double_
            % * |ForwardSpotPrice|      _double_
            % * |StrikePrice|           _double_
            
            obj.Name                    = name;
            obj.ID                      = instrID;
            obj.Currency                = currency;
            obj.MarketRisk              = true;
            obj.ValuationDate           = valuationDate;
            
            obj.DomesticCurrency        = domesticCurrency;
            obj.ForeignCurrency         = foreignCurrency;
            obj.DomesticCurve           = domesticCurve;
            obj.ForeignCurve            = foreignCurve;
            obj.MaturityDate            = maturityDate;
            obj.SpotPriceVAL            = SpotPriceVAL;
            obj.StrikePrice             = strikePrice;
            
            obj.Notional                = 1; % Hardcoded as per design decision
            
            obj.TimeToMaturity          = (datenum(obj.MaturityDate,'mm/dd/yyyy')-datenum(valuationDate,'mm/dd/yyyy'));
            
            % Clean-up on the Domestic and Foreign Curves - Support
            % EUR-SWAP as well as EUR-SWAP-SIM
            if strcmpi(obj.DomesticCurve(end-3:end), '-SIM')
                obj.DomesticCurve = obj.DomesticCurve(1:end-4);
            end
            if strcmpi(obj.ForeignCurve(end-3:end), '-SIM')
                obj.ForeignCurve = obj.ForeignCurve(1:end-4);
            end
            
        end


        function val = value(obj)
            %% value
            % |val = value(obj)|
            % 
            % Outputs:
            % 
            % * |val|
            %
            % The value of an FXForward is given by
            %
            % $N\cdot(Se^{-r_F T}- K e^{-r_DT})$
            %
            % where $N =$ Notional, $S =$ SpotPrice, $K=$ StrikePrice and
            % $T = TimeToMaturity/365$, whereas $r_D, r_F$ are the domestic
            % and foreign interest rate.
            %
            
            
            if obj.TimeToMaturity <=0
                disp(['Instrument ' obj.Name ', ID: ' obj.ID ' excluded. Matured Instrument. Price = 0.0']);
                val = 0.0;
                return;
            end
            val = obj.Notional .* ((obj.spotPrice.* exp(-obj.foreignInterestRate.* obj.TimeToMaturity./365))- ...
                obj.StrikePrice.*exp(-obj.domesticInterestRate.* (obj.TimeToMaturity/365)));
        end

    end % #Methods

end
