%% Black Price and Black Implied Volatility
%
% *The class returns the Black price and the Black implied volatility of
% swap options.*
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bsBlackPrice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% How to Use the Class
% There are three ways to use this class:
%
% # To calculate the Black price of a European option, using 
% *|[bsBlackPrice()]|*.
% # To calculate the implied volatility with the
% Black model using *|[BlackImpVol()]|*.
% # To calculate the first derivative of the Black price with respect
% to the volatility using *|[BlackLambda()]|*.
%
%
%% Properties
%
% 

%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    properties
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% List of Methods
% The class introduces three methods:
%
% *|1)[bsBlackPrice()]|* - Function returns the option price, $C_{Black}(t)$
% or $P_{Black}(t)$, which expires at time, $T$, using the Black pricing 
% model. 
%
% *|2)[BlackImpVol()]|* - Function returns a Black implied volatility,
% $\sigma_{IV}$, for a given market option price.
%
% *|3)[BlackLambda()]|* - Function returns the first derivative of an option 
% price, $C_{Black}$ or $P_{Black}$, with respect to the volatility,
% $\frac{\partial C_{Black}}{\partial\sigma}$.
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    methods

    
    % Constructor
        function  obj = bsBlackPrice()
        
        end
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% 
% *1) |[bsBlackPrice()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns the price of a European option, expiring at time, $T$, 
% using the Black pricing model. The type of option i.e "put" or "call" is
% specified by *|[OptionType]|*.
%
% *_Inputs_*
%
% *|[Forward]|* - $F(t)$, delivery price in a forward contract that causes the
% contract to be worth zero at the current time, $t$.
%
%  Data Type : double
%
% *|[Strike]|* - $K$, price at which the asset may be bought or sold in the
% option contract.
%
%  Data Type : double
%
% *|[Maturity]|* - $T$, time at which the option expires.
%
%  Data Type : double
%
% *|[Volatility]|* - $\sigma$, volatility of the asset underlying the
% option.
%
%  Data Type : double
%
% *|[DiscountFactor]|* - $D= e^{-r\tau}$, where $r$ is the risk free interest
% rate and $\tau=T-t$ is the time to maturity.
%
%  Data Type : double
%
% *|[OptionType]|* - Specifies the type of option i.e. "put or "call".
%
%  Data Type : string
% 
% *_Outputs_*
%
% Black price of a put or call option.
%
%  Data type : double
%
% *_Calculations_*
%
% The Black price is calculated using the following for Call and Put
% options:
%
% i) Call
%
% $$ C_{Black}(t) = D\big[F(t)N(d_1)-KN(d_2)\big] $$
%
% ii) Put
%
% $$ P_{Black}(t) = D\big[KN(-d_2)-F(t)N(-d_1)\big] $$
%
% $$ d_1=\frac{ln\left(\frac{F(t)}{K}\right)+\frac{\sigma^2\tau}{2}}{\sigma\sqrt{\tau}} $$
% 
% $$ d_2=\frac{ln\left(\frac{F(t)}{K}\right)-\frac{\sigma^2\tau}{2}}{\sigma\sqrt{\tau}}=d_1-\sigma\sqrt{\tau} $$
%
% Where,
%
% $C_{Black}(t)$ : Call option price.
%
% $P_{Black}(t)$ : Put option price.
%
% $F(t)$ : Forward Price at current time, $t$.
%
% $T$ : Maturity of the option.
%
% $\tau$ : Time until maturity, $\tau= T-t$.
%
% $D=e^{-r\tau}$ : Discount factor, with the risk free interest rate, $r$
% and the time to maturity, $\tau=T-t$.
%
% $K$ : Strike Price.
%
% $\sigma$ : Volatility of the underlying asset.
%
% $N\left(x\right)$ : Cumulative probability distribution function for a 
% standardised normal distribution.
%

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other Methods   
        
    function  y=BlackPrice(obj, Forward , Strike , Maturity , ...
            Volatility , DiscountFactor, OptionType )
        
        
        D1 = (log(Forward / Strike) + Volatility ^ 2 * Maturity / 2) /...
            (Volatility * Maturity ^ 0.5);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%
% *2) |[BlackImpVol()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns a Black implied volatility, $\sigma_{IV}$, for a given
% market option price, using a root finding method.
%
% Initially the Newton Raphson method is used. This method converges
% quadratically but cannot guarantee convergence.
%
% If the Newton-Raphson method fails we use the more robust Bisection
% method which is slower but guaranteed to converge.
% 
% *_Inputs_*
%
% *|[Forward]|* - $F(t)$, delivery price in a forward contract that causes the
% contract to be worth zero at the current time, $t$.
%
%  Data Type : double
%
% *|[Strike]|* - $K$, price at which the asset may be bought or sold in the
% option contract.
%
%  Data Type : double
%
% *|[Maturity]|* - $T$, time at which the option expires.
%
%  Data Type : double
%
% *|[DiscountFactor]|* - $D= e^{-r\tau}$, where $r$ is the risk free interest
% rate and $\tau=T-t$ is the time to maturity.
%
%  Data Type : double
%
% *|[OptionType]|* - Specifies the type of option i.e. "put or "call".
%
%  Data Type : string
%
% *|[OptionPrice]|* - $C_{Market}$ or $P_{Market}$, empirical, 'market' price of the 
% call or put option, respectively.
%
%  Data Type : double
%
% *_Outputs_*
%
% Implied volatilty which gives the market option price when inserted into
% *|[bsBlackPrice()]|*.
%
%  Data type : double
%
% *_Calculations_*
%
% *i)* In order for our root finding methods to converge, to approximate the
% implied volatility, $\sigma_{IV}$, our starting value of $\sigma_{IV}$
% should give Black prices within feasible ranges. For put and call options
% these ranges are:
%
% $$K>P_{Black}>0)$$
%
% &
%
% $$F(t)>C_{Black}<Max(0,F(t)-K)$$
%
% If our initial values are not within the feasible ranges then an implied
% volatility of zero is returned.
%
% *ii)* If we have inital values that are feasible, then we take the given 
% empirical 'market' option price and calculate the implied volatility, 
% $\sigma_{IV}$, by approximating the root of:
% 
% $C_{Market}-C_{Black}$
%
% or 
%
% $P_{Market}-P_{Black}$ 
%
% using the Newton-Raphson method.
%
% To do this we repeat the iterative equation:
%
% $$ \sigma_{IV,\,n+1} =\sigma_{IV,\,n} - \frac{C_{Black}(\sigma_{IV,\,n})-C_{Market}}{\lambda(\sigma_{IV,\,n})} $$
%
% $$ \sigma_{IV,\,n+1} =\sigma_{IV,\,n} - \frac{P_{Black}(\sigma_{IV,\,n})-P_{Market}}{\lambda(\sigma_{IV,\,n})} $$
%
% Where,
%
% $\sigma_{IV,\,n}$ : approximation to the implied volatility from the
% $n$ th iteration of the equation above.
%
% $C(\sigma_{IV,\,n})$ : option price derived using the approximation to 
% the implied volatility from the $n$ th iteration.
%
% $C_{Market}$ : empirical option price.
%
% $\lambda(\sigma_{IV,\,n})$ : first derivative of the option price derived using 
% the approximation to the implied volatility from the $n$ th iteration.
% This is calculated using *|[BlackLambda()]|* 
%
% The Newton-Raphson converges quadratically but is not guaranteed to converge.
% If we do not achieve an implied volatility which reproduces the market 
% value of the option to within a given tolerance we try the Bisection method 
% which is slower but guarantees convergence.
%
% *iii)* If the Newton-Raphson method did not converge we use the Bisection
% method.
%
% Again we attempt to find the root of 
% 
% $C_{Market}-C_{Black}$
%
% or 
%
% $P_{Market}-P_{Black}$ 
%
% We start with a range of $\sigma_{IV}$ s that we are confident contains
% the root of the expression above and bisect that range. Depending 
% which side of the midpoint the root lies we halve our range using the 
% midpoint as the new upper or lower bound.
% 
% We repeat this method until we know where the root lies to within a certain
% tolerance.
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  
    % Calculate Black's LogNormal parameter using a root finding excercise
    
    function  y = BlackImpVol(obj, OptionPrice,Forward , Strike ,...
            Maturity , DiscountFactor, OptionType )
        
        
        
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
        if (OptionPrice >= Price_min && OptionPrice <= Price_max) && ...
                (OptionPrice > 0)
            
            Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor, OptionType )  ;
            Lambda =obj.BlackLambda(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor );
            IterationCount = 0;
            
            while (abs(Val - OptionPrice) > Toler) && (IterationCount <= ...
                    MaxNumberOfNRIterations) ...
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
            
            
            % Try Bisection Method
            
            IterationCount = 0;
            Impvol_a = Impvol_min;
            Impvol_b = Impvol_max;
            Impvol = (Impvol_a + Impvol_b) / 2;
            Val =obj.BlackPrice(Forward , Strike , Maturity , Impvol , ...
                DiscountFactor, OptionType )  ;
            
            while (abs(Val - OptionPrice) > Toler) && (IterationCount <= ...
                    MaxNumberOfBSIterations)
                
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
        
       
        
        if (abs(Val - OptionPrice) < Toler)
            y = Impvol;
            return
        else
            y = 0;
            return
        end
        
        
        
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% *3) |[BlackLambda()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns the first derivative of an option 
% price, $C_{Black}$ or $P_{Black}$, with respect to the volatility,
% $\frac{\partial C_{Black}}{\partial\sigma}$.
%
% *_Inputs_*
% 
% *|[Forward]|* - $F(t)$, delivery price in a forward contract that causes the
% contract to be worth zero at the current time, $t$.
%
%  Data Type : double
%
% *|[Strike]|* - $K$, price at which the asset may be bought or sold in the
% option contract.
%
%  Data Type : double
%
% *|[Maturity]|* - $T$, time at which the option expires.
%
%  Data Type : double
%
% *|[Volatility]|* - $\sigma$, volatility of the asset underlying the
% option.
%
%  Data Type : double
%
% *|[DiscountFactor]|* - $D= e^{-r\tau}$, where $r$ is the risk free interest
% rate and $\tau=T-t$ is the time to maturity.
%
%  Data Type : double
%
% *_Outputs_*
%
% Function returns the first derivative of the Black price with respect to 
% volatility, $\frac{\partial C_{Black}}{\partial\sigma}$.
%
%  Data type : double
%
% *_Calculations_*
%
% To calculate the first derivative of the Black price with respect to 
% volatility we use the formula below,
%
% $$\frac{\partial C_{Black}}{\partial\sigma}
% =\frac{\partial P_{Black}}{\partial\sigma}
% =\sqrt{\frac{\tau}{2\pi}}DF(t)e^{-d_1^2/2} $$
%
% where,
%
% $$ d_1=\frac{ln\left(\frac{F(t)}{K}\right)+\frac{\sigma^2\tau}{2}}{\sigma\sqrt{\tau}} $$
%
% with, 
%
% $C_{Black}(t)$ : Call option price.
%
% $P_{Black}(t)$ : Put option price.
%
% $F(t)$ : Forward Price at current time, $t$.
%
% $\tau$ : Time until maturity, $\tau= T-t$.
%
% $D=e^{-r\tau}$ : Discount factor, with the risk free interest rate, $r$
% and the time to maturity, $\tau=T-t$.
%
% $K$ : Strike Price.
%
% $\sigma$ : Volatility of the underlying asset.
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

     % Calculate the derivative of the black formula with respect to
     % volatility
    
     function  y=BlackLambda(obj, Forward , Strike , Maturity , Volatility , ...
                                                 DiscountFactor )
         
         
         D1 = (log(Forward / Strike) + Volatility ^ 2 * Maturity / 2) / ...
             (Volatility * Maturity ^ 0.5);
         
         y = DiscountFactor * (Forward * sqrt(Maturity) * ...
             (1 / (sqrt(2 * pi))) * exp((-1 * D1 ^ 2) / 2));
         
     end
    
    
    end
    
end

