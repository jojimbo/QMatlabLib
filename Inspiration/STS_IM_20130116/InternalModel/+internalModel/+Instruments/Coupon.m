%% Coupon
% subclass of internalModel.Instrument
%
%% 

classdef Coupon < internalModel.Instrument
    
    %% Properties
    %
    % * |Notional|      _double_
    % * |Payment|      _double_
    % * |Spread|       _double_
    % * |TimeToMaturity| _double_
    % * |InterestRate| _double_
    % * |DiscountCurve| _char_
    
    
    properties
        Payment
        
        Spread
        TimeToMaturity
        
        InterestRate
        
        %not used in FXIRSwap
        DiscontCurve
        
    end % # Properties
    
    methods
        
         function obj = Coupon(payment,...
                 currency, interestRate,...
                 valuationDate,...
                 timeToMaturity ...
                 )
            
            obj.Payment                    = payment;
            obj.Currency                   = currency;
            obj.InterestRate               = interestRate;
            obj.ValuationDate              = valuationDate;
            obj.TimeToMaturity             = timeToMaturity; %will change
         end
        
         function val = value(obj)
            %% value
            % |val = value(obj)|
            % 
            % Outputs:
            %  
            % * |val|
            % 
            % The value of a Coupon is 
            %
            % $\displaystyle N\cdot e^{-r T}$
            % 
            % where $N$= Payment, $r$ = InterestRate and $T$ = TimeToMaturity/365
            
            
            if obj.TimeToMaturity<0
                val =0;
            else
            val = obj.Payment.*exp(-obj.InterestRate.*obj.TimeToMaturity/365);
            end
            
            
         end
        
    end %# Methods
end