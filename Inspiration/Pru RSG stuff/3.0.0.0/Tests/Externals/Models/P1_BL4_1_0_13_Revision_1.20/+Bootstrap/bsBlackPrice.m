classdef bsBlackPrice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description :: 
    % Created on 13/10/2011 by Graeme Lawson 
    % function calculates either the black price or the black implied
    % volatility
    
    properties
    end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
        function  obj = bsBlackPrice()
        
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods   
        
    function  y=BlackPrice(obj, Forward , Strike , Maturity , Volatility , ...
            DiscountFactor, OptionType )
        
        
        D1 = (log(Forward / Strike) + Volatility ^ 2 * Maturity / 2) / (Volatility * Maturity ^ 0.5);
        D2 = D1 - Volatility * Maturity ^ 0.5;
        
        switch lower(OptionType)        
            case  'put'        
            ND1 = normcdf(-D1);
            ND2 = normcdf(-D2);
            PayOff = Strike * ND2 - Forward * ND1;
            case 'call'
            ND1 = normcdf(D1);
            ND2 = normcdf(D2);
            PayOff = Forward * ND1 - Strike * ND2;
        end
        
        y = DiscountFactor * PayOff;
        
        return
    end   
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate Black's LogNormal parameter using a root finding excercise
    
    function  y = BlackImpVol(obj, OptionPrice,Forward , Strike , Maturity , ...
            DiscountFactor, OptionType )
        
        
        
        Impvol_min = 0;
        Impvol_max = 3;
        
        Impvol = 0.2;
        Toler = 0.00001 ;
        LambdaMin = 0.0001;
        MaxNumberOfNRIterations = 100;
        MaxNumberOfBSIterations = 100;
        
        % Check that price is within feasible range
        switch lower(OptionType)
            case  'put'
                Price_min = 0;
                Price_max = DiscountFactor * Strike;
            case 'call'
                Price_min = DiscountFactor * max(Forward - Strike, 0); % Intrinsic Value of a Call Option
                Price_max = DiscountFactor * Forward;
        end
        
        Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
            DiscountFactor, OptionType )  ;
        
        % Estimate Implied Volatility
        if (OptionPrice >= Price_min && OptionPrice <= Price_max) && (OptionPrice > 0)
            
            Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor, OptionType )  ;
            Lambda =obj.BlackLambda(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor );
            IterationCount = 0;
            
            while (abs(Val - OptionPrice) > Toler) && (IterationCount <= MaxNumberOfNRIterations) ...
                    && (Impvol > 0) && (Impvol < Impvol_max)
                Lambda = max(LambdaMin, Lambda);
                Impvol = Impvol - (Val - OptionPrice) / Lambda;
                Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                    DiscountFactor, OptionType )  ;
                Lambda =obj.BlackLambda(Forward , Strike , Maturity , Impvol , ...
                    DiscountFactor );
                IterationCount = IterationCount + 1;
            end
            
            if (abs(Val - OptionPrice) < Toler)
                y = Impvol;
                return
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Try Bisection Method
            
            IterationCount = 0;
            Impvol_a = Impvol_min;
            Impvol_b = Impvol_max;
            Impvol = (Impvol_a + Impvol_b) / 2;
            Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor, OptionType )  ;
            
            while (abs(Val - OptionPrice) > Toler) && (IterationCount <= MaxNumberOfBSIterations)
                
                if (Val - OptionPrice) > 0
                    % Decrease the upper bound of our search interval
                    Impvol_b = Impvol;
                else
                    % Increase the Lower bound of our search interval
                    Impvol_a = Impvol;
                end
                
                Impvol = (Impvol_a + Impvol_b) / 2;
                Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                    DiscountFactor, OptionType )  ;
                IterationCount = IterationCount + 1;
            end
            
        end
        
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (abs(Val - OptionPrice) < Toler)
            y = Impvol;
            return
        else
            y = 0;
            return
        end
        
        
        
    end
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Calculate the derivative of the black formula with respect to
     % volatility
    
     function  y=BlackLambda(obj, Forward , Strike , Maturity , Volatility , ...
                                                 DiscountFactor )
         
         
         D1 = (log(Forward / Strike) + Volatility ^ 2 * Maturity / 2) / (Volatility * Maturity ^ 0.5);
         
         y = DiscountFactor * (Forward * sqrt(Maturity) * (1 / (sqrt(2 * pi))) * exp((-1 * D1 ^ 2) / 2));
         
     end
    
    
    end
    
end

