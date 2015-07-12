%% FXOption
% subclass of internalModel.Instrument
% 
% No additional properties
%%


classdef FXOption < internalModel.Instrument

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
    % * |ContractSize| _double_
    % * |PutCallFlag| _double_
    % * |TimeToMaturity| _char_
    % * |Moneyness| _double_
    %

    properties
        DomesticCurrency
        ForeignCurrency
        DomesticCurve
        ForeignCurve
        MaturityDate   
        SpotPriceVAL % It's not clear what this represents in the input file (it's not the spotRate)
        StrikePrice
        ContractSize
        PutCallFlag
        TimeToMaturity
        
        Notional
        Moneyness
        % The following 2 properties should ideally not be part of the
        % FXSwap object, but they are here for now to quickly price
        % FXSwap within the current architecture
        domesticInterestRate
        foreignInterestRate
        spotPrice
        volatility
    end % #Properties


    %% Methods
    % 
    % * |obj = FXOption(obj) = FXOption(Name, instrID, currency,
    %  domesticCurrency, foreignCurrency, domesticCurve, foreignCurve, 
    %   maturityDate,forwardSpotPrice, strikePrice, contractSize, putCallFlag, evaluationDate)|
    % * |val = value(this, scenarioCollection)|

    methods
        function obj = FXOption(name, instrID, currency, ...
                domesticCurrency, foreignCurrency, ...
                domesticCurve,...
                foreignCurve, ...
                maturityDate, ...
                spotPriceVAL, ...
                strikePrice, ...
                contractSize, ...
                putCallFlag, ...
                valuationDate ...
               )
            %% FXOption _constructor_
            % |obj = FXOption(Name, instrID, currency,
    %  domesticCurrency, foreignCurrency, domesticCurve, foreignCurve, 
    %   maturityDate,forwardSpotPrice, strikePrice, contractSize, putCallFlag, evaluationDate)|
           
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
                
            obj.MaturityDate            = maturityDate;
            
            obj.SpotPriceVAL            = spotPriceVAL;
                      
            obj.StrikePrice             = strikePrice;
            obj.ContractSize            = contractSize;
            obj.Notional                = 1; % Hardcoded as per design decision
            obj.TimeToMaturity          = (datenum(obj.MaturityDate,'mm/dd/yyyy')-datenum(valuationDate,'mm/dd/yyyy')); %expressed in days
            obj.PutCallFlag             = putCallFlag;
            
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
            % The value of an FX European Call Option is 
            % 
            % $S e^{-r_F T}\mathcal N(d_1) - Ke^{-r_D T}\mathcal N(d_2)$
            %
            % The value of an FX European Put Option is
            %
            % $-Se^{-r_F T}\mathcal N(-d_1) + Ke^{-r_D T}\mathcal N(-d_2)$
            %
            % where
            %
            % $\displaystyle \left\{\begin{array}{l} d_1 = \frac{\ln(S/K) + (r + \sigma^2/2) T}{\sigma\cdot \sqrt T} \\ \\
            % d_2 = d_1 - \sigma\sqrt T \end{array}\right. ,$
            %
            % and 
            %
            % $S =$ SpotPrice, $K=$ StrikePrice, $\sigma$ =
            % volatility, 
            % $\;T = TimeToMaturity/365$, whereas $r_D, r_F$ are the domestic
            % and foreign interest rate.
            %
            
            
            S = obj.spotPrice;
            K = obj.StrikePrice;
            T = obj.TimeToMaturity./365;
            
            sigma = obj.volatility; %will put the volatility here
            d1 = log(S./K) + (obj.domesticInterestRate - obj.foreignInterestRate + (sigma.^2)./2).*T;
            d2 = log(S./K) + (obj.domesticInterestRate - obj.foreignInterestRate - (sigma.^2)./2).*T;
            
            d1=d1./(sigma.*sqrt(T));
            d2=d2./(sigma.*sqrt(T));
            
            val = S.*exp(-obj.foreignInterestRate.*T).*normcdf(d1) - K.*exp(-obj.domesticInterestRate.*T).*normcdf(d2); 
            
            if strcmp(obj.PutCallFlag,'Put')
                val = -S.*exp(-obj.foreignInterestRate.*T).*normcdf(-d1) + K.*exp(-obj.domesticInterestRate.*T).*normcdf(-d2); 
            end
            
            val = obj.Notional*val;
                
        end

    end % #Methods

end
