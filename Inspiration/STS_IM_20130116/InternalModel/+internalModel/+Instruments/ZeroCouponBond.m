%% ZeroCouponBond
% subclass of internalModel.Instrument
% 
%%

classdef ZeroCouponBond < internalModel.Instrument

    %% Properties
    %
    % * |CreditSpread|  _double_
    % * |Notional|      _double_

    properties
        Tenor
        Notional
        DomesticCurve
        
        %Shouldn't be here, but it is for now due to design constraints
        interestRate
    end % #Properties

    %% Methods
    % 
    % * |obj = ZeroCouponBond(name, tenor, currency, creditSpread, instrID)|
    % * |val = value(this, scenarioCollection)|

    methods
        function obj = ZeroCouponBond(name, instrID, currency, ...
                domesticCurve, tenor, creditSpread, notional, ...
                valuationDate)
            %% ZeroCouponBond _constructor_
            % |obj = ZeroCouponBond(name, instrID, currency, domesticCurve, tenor, creditSpread, notional)|
            % 
            % Inputs:
            % 
            % * |name|          _char_
            % * |tenor|         _double_
            % * |currency|      _char_
            % * |CreditSpread|  _char_
            % * |instrID|       _double_
            % * |notional|      _double_

            obj.Name            = name;
            obj.ID              = instrID;
            obj.Currency        = currency;
            
            obj.DomesticCurve   = domesticCurve;
            obj.Tenor           = tenor;
            obj.CreditSpread    = creditSpread;
            obj.Notional        = notional;
            
            obj.ValuationDate   = valuationDate;
            obj.MarketRisk   = true;

            % Clean-up on the Domestic Curve - Support
            % EUR-SWAP as well as EUR-SWAP-SIM
            if strcmpi(obj.DomesticCurve(end-3:end), '-SIM')
                obj.DomesticCurve = obj.DomesticCurve(1:end-4);
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
            % The value of a ZeroCouponBond is
            %
            % $Notional \cdot e^{-InterestRate\cdot Tenor/365}$
            

            val = obj.Notional * exp(-obj.interestRate * (obj.Tenor/365));
        end

    end % #Methods

end
