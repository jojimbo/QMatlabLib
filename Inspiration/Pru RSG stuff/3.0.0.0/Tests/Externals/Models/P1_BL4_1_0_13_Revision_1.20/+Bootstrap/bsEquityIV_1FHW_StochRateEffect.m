%% EQUITY IMPLIED VOLATILITY
% REMOVE STOCHASTIC INTEREST RATE EFFECT
%
% *The main purpose of this class is to remove the effect
% of stochastic interest rates from an equity implied volatility number
% given a calibration of the One Factor Hull-White Model or to add the effect
% of stochastic interest rates to an idiosyncratic volatility number*
%
% Supporting documentation is the following: 
% _O:\01 Pillar I Risk Measurement\05 Deliverables - RSG\03 Implementation\Industrialisation\Data
% \Market Data Pack\Equity IV extrap Equity Implied Vol One & Two Factor
% Hull White V3.docx_
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bsEquityIV_1FHW_StochRateEffect
%% How to Use the Class
% There are two ways to use the class:
% 
% # Given a spot implied volatility, we can remove the effect of stochastic interest 
% rates from the spot implied volatility to give the idiosyncratic volatility 
% using the function *|[FindEquityVol()]|*. Function *|[FindEquityVolSurface()]|* 
% returns a spot volatility surface. 
% # Given an idiosyncratic volatility, we can add the effect
% of stochastic interest rates to it to give an equity implied
% volatility using the function *|[GetEquityImpliedVol()]|*. 
% A surface can be constructed through *|[GetEquityImpliedVolSurface()]|*. 
% Function *|[GetLimitingEquityImpliedVol()]|* estimates the limiting
% volatility.

%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[dblIRMeanReversionSpeed]|* - Rate $\alpha$ at which the short rate reverts back to mean
%
% *|[dblIRVolatility]|* - Interest rate volatility $\sigma$
%
% *|[dblEquity_IR_Correlation]|* - Correlation $\rho$ between equity and
% interest rate 

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties

        dblIRMeanReversionSpeed 
        dblIRVolatility
        dblEquity_IR_Correlation

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

%% List of Methods
% This bootstrap class introduces the following methods:
%
% *|1) [GetEquityImpliedVolSurface()]|* - Function returns an equity implied volatility 
% surface with "maturity" against "moneyness". Volatility values are calculated 
% using the function |[GetEquityImpliedVol()]|
%
% *|2) [GetEquityImpliedVol()]|* - Function calculates an implied spot
% volatility given the parameters of the One Factor Hull-White Model and 
% the idiosyncratic equity volatility |[dblEquityVolatility]|
%
% *|3) [GetLimitingEquityImpliedVol()]|* - Function calculates a limiting spot
% equity volatility as time to maturity approaches infinity. The calculated value will equal to 
% the forward equity volatility as time to maturity approaches infinity
%
% *|4) [FindEquityVolSurface()]|* - Function returns an idiosyncratic volatility surface 
% with "maturity" against "moneyness". Volatility values are calculated 
% using the function |[FindEquityVol()]|
%
% *|5) [FindEquityVol()]|* - Function removes the effect of stochastic interest 
% rates from an implied spot volatility and the resulting volatility is called the idiosyncratic volatility
%
% *|6) [Integral3()]|* - Function calculates the value of $I_3$ in the "Total Variance" formula. 
% See |[GetEquityImpliedVol()]| for details of the formula
%
% *|7) [Integral4()]|* - Function calculates the value of $I_4$ in the "Total Variance" formula. 
% See |[GetEquityImpliedVol()]| for details of the formula
%
% *|8) [auxillaryFunction1]|* - Function helps to calculate $I_3$ and $I_4$
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods     
    function obj = bsEquityIV_1FHW_StochRateEffect(IRMeanReversionSpeed,... 
      IRVolatility, Equity_IR_Correlation)
  
       obj.dblIRMeanReversionSpeed  = IRMeanReversionSpeed ;
       obj.dblIRVolatility =IRVolatility;
       obj.dblEquity_IR_Correlation =Equity_IR_Correlation; 
       
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________________________
%
%% |1) [GetEquityImpliedVolSurface()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function returns an equity implied volatility surface with "maturity" against "moneyness". 
% For each maturity and each moneyness, we calculate an implied spot
% volatility value using the function |[GetEquityImpliedVol()]|. 
%
% *_Inputs_*
%
% |[dblEquityVolSurface]| - A surface of idiosyncratic volatilites with "maturity" against "moneyness"
% 
% _Data Type_: 2-dim array
% 
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% An implied volatility surface with "maturity" against "moneyness"
%
% _Data Type_: 2-dim array
%
% *_Calculation_*
%
% Set up the matrix with the same size and the same row and column titles as the |[dblEquityVolSurface]|
% 
% We then calculate the equity implied volality using
% the function |[GetEquityImpliedVol()]|.
% See |[GetEquityImpliedVol()]| for calculation details


%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function y=GetEquityImpliedVolSurface(obj, dblEquityVolSurface,...
        dblTimeToMaturity)
    
        assert(size(dblEquityVolSurface,1) == size(dblTimeToMaturity,2));

        y = zeros(size(dblEquityVolSurface));

        for i =1 : size(dblEquityVolSurface,1)
          for j =1 : size(dblEquityVolSurface,2)
             y(i,j) = obj.GetEquityImpliedVol(dblEquityVolSurface(i,j),...
                dblTimeToMaturity(1,i));
          end
        end
        
        return
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% _________________________________________________________________________________________
%
%% |2) [GetEquityImpliedVol()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function calculates the equity implied volatility given the
% parameters of the One Factor Hull-White Model and the idiosyncratic
% equity volatility |[dblEquityVolatility]|
%
% *_Inputs_*
%
% |[dblEquityVolatility]| - idiosyncratic spot volatility
%
% _Data Type_: single value
% 
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% Equity implied spot volatility
%
% _Data Type_: single value
%
% *_Calculations_*
%
% Equity implied volatility can be estimated using the formula,
%
% $IV = \sqrt{\frac{Var[ln(\frac{S(T)}{S(0)})]}{T}}$
%
% where
%
% $Var[ln(\frac{S(T)}{S(0)})] = I_4 + 2 \rho \sigma_s I_3 +
% \sigma_s ^ 2 T$ 
%
% is the measurement of "Total Variance" of the log-return from time $0$ to time $T$, namely |[dblTotalEquityVariance]| 
% 
% $I_3$ and $I_4$ are values calculated using the functions |[Integral3()]| and |[Integral4()]| 
%
% $\sigma_s$ is the idiosyncratic equity volatility |[dblEquityVolatility]|, 
% i.e. implied spot volatilities with the effect of stochastic interest rates stripped out.
%  
% See function |[FindEquityVol()]| for details of the "stripping"
% process.

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function y=GetEquityImpliedVol(obj, dblEquityVolatility,...
             dblTimeToMaturity)                             

       I3 = obj.Integral3(dblTimeToMaturity);
       I4 = obj.Integral4(dblTimeToMaturity);

       dblTotalEquityVariance = I4 + 2 * obj.dblEquity_IR_Correlation...
               * dblEquityVolatility * I3 + dblEquityVolatility ^ 2 ...
               * dblTimeToMaturity ;

       y = sqrt(dblTotalEquityVariance / dblTimeToMaturity) ;
       return

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%
% _________________________________________________________________________________________
%
%% |3) [GetLimitingEquityImpliedVol()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function calculates the limiting equity volatility when time to maturity approaches infinity 
% and it equals to the forward volatility over the future period quantity.
%
% *_Inputs_*
%
% |[dblEquityVolatility]| - idiosyncratic spot volatility
%
% _Data Type_: single value
%
% *_Outputs_*
%
% The limiting equity implied spot volatility as time to
% maturity approaches infinity
%
% _Data Type_: single value
%
% *_Calculations_*
%
% As $T \to \infty$
%
% $I_3 \to \frac{\sigma}{\alpha}$
%
% $I_4 \to (\frac{\sigma}{\alpha})^2$
%
% $IV \to \sqrt{Var[S_\infty]}$
%
% where
% 
% $Var[S_\infty] = \lim_{T \to \infty} \\I_4 + 2 \rho \sigma_s \lim_{T
% \to \infty} \\I_3 + \sigma_s^2$

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
   function y = GetLimitingEquityImpliedVol(obj, dblEquityVolatility )                        

     I3 = (obj.dblIRVolatility / obj.dblIRMeanReversionSpeed) ;
     I4 = (obj.dblIRVolatility / obj.dblIRMeanReversionSpeed) ^ 2;

     dblAnnulaisedEquityVariance = I4 + 2 * obj.dblEquity_IR_Correlation...
         * dblEquityVolatility * I3 + dblEquityVolatility ^ 2;

     y = sqrt(dblAnnulaisedEquityVariance);

   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
%%
% _________________________________________________________________________________________
%
%% |4) [FindEquityVolSurface()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Simlar to |[GetEquityImpliedVolSurface()]|, function returns a volatility
% surface with "maturity" against "moneyness". 
% However, for each maturity and each moneyness, the value is the 
% idiosyncratic volatility that is calculated using 
% the function |[FindEquityVol()]|. 
%
% *_Inputs_*
%
% |[dblEquityIVSurface]| - a surface of equity implied spot volatilites with "maturity" against "moneyness"
%
% _Data Type_: 2-dim array
% 
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% An idiosyncratic spot volatility surface with "maturity" against "moneyness"
%
% _Data Type_: 2-dim array
%
% *_Calculation_*
%
% Set up the matrix with the same size and the same row and column 
% titles as the |[dblEquityIVSurface]|
% 
% We then calculate the idiosyncratic Volatility using the function |[FindEquityVol()]|.
% See |[FindEquityVol()]| for calculation details
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function y = FindEquityVolSurface(obj, dblEquityIVSurface,...
            dblTimeToMaturity)

        assert(size(dblEquityIVSurface,1) == size(dblTimeToMaturity,2));

        y = zeros( size(dblEquityIVSurface));

        for i =1 : size(dblEquityIVSurface,1)
            for j =1 : size(dblEquityIVSurface,2)
                y(i,j) = obj.FindEquityVol(dblEquityIVSurface(i,j), ...
                    dblTimeToMaturity(1,i));
            end
        end

        return
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%%
% _________________________________________________________________________________________
%
%% |5) [FindEquityVol()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function removes the effect of stochastic interest rates from
% equity implied spot volatilities and calculates idiosyncratic volatilities.
% This is the reverse process to the function |[GetEquityImpliedVol()]|, 
% where idiosyncratic equity volalities are converted to equity implied spot volatilities.
%
% *_Inputs_*
%
% |[dblEquityIVTarget]| - $\sigma_{IV}$, equity implied spot volatility
%
% _Data Type_: single value
% 
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% An idiosyncratic volatility
%
% _Data Type_: single value
%
% *_Calculations_*
%
% We have seen in |[GetEquityImpliedVol()]|, an equity implied spot volatility
% is calculated using the formula
%
% $Var[ln(\frac{S(T)}{S(0)})] = I_4 + 2 \rho \sigma_s I_3 + \sigma_s ^ 2 T$
%
% Here
%
% $Var[ln(\frac{S(T)}{S(t)})] = \sigma_{IV} ^ 2 T$
% 
% Substituting into the previous equation and rearranging, we then have a quadratic equation of the idiosyncratic volatily $\sigma_s$
%
% $T \sigma_s ^ 2 + 2 \rho I_3 \sigma_s + (I_4 - \sigma_{IV} ^ 2 T) = 0$
%
% To find the value of $\sigma_s$, we can solve the quadratic equation
%
% To see if there exists a solution, calculate $\Delta = {b^2 - 4ac}$
%
% where
%
% $a = T$
%
% $b = 2 \rho I_3$
%
% $c = I_4 - \sigma_{IV} ^ 2 T$
%
% If $\Delta < 0$,
%
% $\sigma_s = 0$
%
% If $\Delta \geq 0$,
%
% $\sigma_s = max(\frac{-b \pm \sqrt{\Delta}}{2a})$, _subject to a minimum of zero_
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   function y = FindEquityVol(obj, dblEquityIVTarget , dblTimeToMaturity )

     % Step 0 initialise
     I3 = obj.Integral3( dblTimeToMaturity);
     I4 = obj.Integral4(dblTimeToMaturity);
     dblTotalEquityVariance = (dblEquityIVTarget ^ 2 * dblTimeToMaturity);

     % Step 1 calculate solution of the quadratic
     a = dblTimeToMaturity;
     b = 2 * (obj.dblEquity_IR_Correlation) * I3;
     c = (I4 - dblTotalEquityVariance);
     d = b ^ 2 - 4 * a * c;

     % If no real solution exist, return zero, else choose the positive
     % solution
     if d < 0
         y = 0; % Minimum (Lower Bound) equity volatility
         return
     else

         dblSolution1 = max(0, (-b + sqrt(d)) / (2 * a));
         dblSolution2 = max(0, (-b - sqrt(d)) / (2 * a));

         y = max(dblSolution1, dblSolution2);                
     end

   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
%% Auxillary Functions
% _________________________________________________________________________________________
%
%% |6) [Integral3()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function calculates $I_3$ which is substituted into the "Total
% Variance" formula of |[GetEquityImpliedVol()]|
%
% *_Inputs_*
%
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% $I_3$
%
% _Data Type_: single value
%
% *_Calculations_*
%
% Let
%
% $\Sigma(t,T)= \frac{\sigma}{\alpha} (1-e^{-\alpha T})$
%
% Integrate $\Sigma(t,T)$, we get
%
% $I_3= \int_0^T \Sigma (u,T)\,\mathrm{d}u
% = \frac{\sigma}{\alpha} [T - y(\alpha)]$
% 
% where $y(\alpha)$ is calculated using the |[auxillaryFunction1]|
% 
% See |[auxillaryFunction1]| for details

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function y =Integral3(obj,  dblTimeToMaturity )

       dblTerm1 = -obj.auxillaryFunction1(obj.dblIRMeanReversionSpeed, ...
           dblTimeToMaturity);

       y = (obj.dblIRVolatility / obj.dblIRMeanReversionSpeed ) * ...
           (dblTimeToMaturity + dblTerm1);

   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |7) [Integral4()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Similar to |[Integral3()]|, function calculates $I_4$ which is substituted into the "Total
% Variance" formula we have seen in |[GetEquityImpliedVol()]|
%
% *_Inputs_*
%
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% $I_4$
%
% _Data Type_: single value
%
% *_Calculations_*
%
% Let
%
% $\Sigma(t,T)= \frac{\sigma}{\alpha} (1-e^{-\alpha T})$
%
% Integrate $\Sigma^2 (t,T)$, we get
%
% $I_4=\int_0^T \Sigma^2 (u,T)\,\mathrm{d}u
% =\frac{\sigma^2}{\alpha^2} [T - 2 y(\alpha) + y(2 \alpha)]$
% 
% where $y(\alpha)$ and $y(2 \alpha)$ are calculated using the |[auxillaryFunction1]|
% 
% See |[auxillaryFunction1]| for details
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function y = Integral4(obj, dblTimeToMaturity)

      dblTerm1 = -obj.auxillaryFunction1(obj.dblIRMeanReversionSpeed,...
          dblTimeToMaturity);
      dblTerm2 = obj.auxillaryFunction1(2*(obj.dblIRMeanReversionSpeed),...
          dblTimeToMaturity);

      y = (obj.dblIRVolatility / obj.dblIRMeanReversionSpeed ) ^ 2 * ...
         (dblTimeToMaturity + 2 * dblTerm1 + dblTerm2);

   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |8) [auxillaryFunction1]|
%
% ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''' 
%
% *_Description_*
%
% Function helps to calculate $I_3$ and $I_4$
%
% *_Inputs_*
% 
% |[dblmeanreversionspeed]| - Rate $\alpha$ at which the short rate reverts back to mean
%
% _Data Type_: single value
%
% |[dblTimeToMaturity]| - $T$, time to maturity of the equity option
%
% _Data Type_: single value
%
% *_Outputs_*
%
% The value $y(\alpha)$ that is used in the calculation of $I_3$ and $I_4$
%
% _Data Type_: single value
%
% *_Calculations_*
%
% $y(\alpha) = \frac{1}{\alpha} (1-e^{-\alpha T})$
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function y =auxillaryFunction1(obj, dblmeanreversionspeed, ...
             dblTimeToMaturity )

         y = (1 - exp(-dblmeanreversionspeed * dblTimeToMaturity)) / ...
             dblmeanreversionspeed;

     end        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    end
    
end

