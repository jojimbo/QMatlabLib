%% FXSwap
% subclass of internalModel.Instrument
% 
%%

classdef FXSwap < internalModel.Instrument

    %% Properties
    % 
    % * |Notional|      _double_
    % * |DomesticCurrency| _char_
    % * |ForeignCurrency| _char_
    % * |DomesticCurve| _char_
    % * |ForeignCurve| _char_
    % * |EffectiveDate| _char_
    % * |MaturityDate| _char_
    % * |SpotPriceVAL| _double_
    % * |StrikePrice| _double_
    % * |SwapType| _char_
    % * |SettlementType| _char_
    % * |ContractSize| _double_
    %
    

    properties
        DomesticCurrency
        ForeignCurrency
        DomesticCurve
        ForeignCurve
        EffectiveDate
        MaturityDate   
        SpotPriceVAL % It's not clear what this represents in the input file (it's not the spotRate)
        StrikePrice
        SwapType
        SettlementType
        ContractSize
        
        Notional
        TimeToMaturity
        
        % The following 2 properties should ideally not be part of the
        % FXSwap object, but they are here for now to quickly price
        % FXSwap within the current architecture
        domesticInterestRate
        foreignInterestRate
        spotPrice
    end % #Properties


    %% Methods
    % 
    % * |obj = FXSwap(obj) = FXSwap(Name, instrID, Currency, DomesticCurrency, ForeignCurrency, DomesticDiscountCurve, ForeignDiscountCurve, MaturityDate,
    % ContractSize, SwapType, SettlementType, SpotRate, ForwardSpotPrice, StrikePrice, EvaluationDate)|
    % * |val = value(this, scenarioCollection)|

    methods
        function obj = FXSwap(name, instrID, currency, ...
                domesticCurrency, foreignCurrency, ...
                domesticCurve, foreignCurve, ...,
                effectiveDate,...
                maturityDate, ...
                contractSize, ...
                swapType, ...
                settlementType, ...
                spotRate, spotPriceVAL, strikePrice, ...
                valuationDate ...
               )
            %% FXSwap _constructor_
            % |obj = FXSwap(Name, instrID, Currency, DomesticCurrency, ForeignCurrency, DomesticDiscountCurve, ForeignDiscountCurve, MaturityDate,
            % ContractSize, SwapType, SettlementType, SpotRate, ForwardSpotPrice, StrikePrice, EvaluationDate)|
           
            % Inputs:
            
            obj.Name                    = name;
            obj.ID                      = instrID;
            obj.Currency                = currency;
            obj.MarketRisk              = true;
            obj.ValuationDate           = valuationDate;
            
            obj.DomesticCurrency        = domesticCurrency;
            obj.ForeignCurrency         = foreignCurrency;
            obj.DomesticCurve           = domesticCurve;
            obj.ForeignCurve            = foreignCurve;
            
            obj.EffectiveDate           = effectiveDate;
            obj.MaturityDate            = maturityDate;
            
            obj.ContractSize            = contractSize;
            obj.SwapType                = swapType; 
            obj.SettlementType          = settlementType;
            
            obj.spotPrice               = spotRate;
            
            obj.SpotPriceVAL            = spotPriceVAL;
            obj.StrikePrice             = strikePrice;
            
            obj.Notional                = 1; % Hardcoded as per design decision
            obj.TimeToMaturity          = (datenum(maturityDate,'mm/dd/yyyy')-datenum(effectiveDate,'mm/dd/yyyy')); %expressed in days
            
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
            % The value of a Swap is given by 
            %
            % $N\cdot (S-Se^{-r_FT}-Ke^{-r_DT})\cdot sign$ 
            %
            % where $N =$ Notional, $S =$ SpotPrice, $K=$ StrikePrice and
            % $T= TimeToMaturity/365$, whereas $r_D, r_F$ are the domestic
            % and foreign interest rate. The value of 
            % $sign$ is 1 if SwapType = 'Buy/Sell', -1 otherwise.
            %
            S=obj.spotPrice;
                        
            val= obj.Notional.*(S - S.*exp(-obj.foreignInterestRate.*obj.TimeToMaturity./365) - ...
                obj.StrikePrice.*exp(-obj.domesticInterestRate.*obj.TimeToMaturity./365));
          
           if strcmp(obj.SwapType, 'Sell/Buy')
               val = -val;
           end
        end

    end % #Methods

end
