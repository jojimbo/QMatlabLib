%% RAW MARKET YIELD CURVE TO ZERO COUPON BOND YIELD CURVE
% 
% *This class extrapolates and interpolates raw market yield curve data
% to produce a Zero Coupon Bond (ZCB) yield curve*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_RawtoZCB < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method extrapolates and interpolates raw market yield curve data
% to produce a Zero Coupon Bond (ZCB) yield curve
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *Input Parameters*
%
% *|[method]|* - iterpolation/extrapolation method, e.g. "wilson smith"
%
% _Data Type_: string
%
% *|[outputfreq]|* - a string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string 
%
% *|[ltfwd]|* - the value that forward rates converge to in the
% long term.
% Note that the input long term forward rate is assumed to be annually compounded, 
% thererfore it is first transformed to a continuously compounded rate
%
% _Data Type_: double
%
% *|[llp]|* - $T_{LLP}$ maximum maturity at which swaps/bonds are liquid
%
% _Data Type_: double
%
% *|[decayrate]|* - $\alpha$, represents the speed with which the standard deviation 
% of returns reverts to its long term level. It controls the exponential decay 
% from the last liquid point to the long-term target
%
% _Data Type_: double
%
% *|[startterm]|* - defines the start term of the ouput yield curve
%
% _Data Type_: double
% 
% *|[endterm]|* - defines the end term of the ouput yield curve
%
% _Data Type_: double 
%
% *|[minValidRate]|* - validation parameter, $-0.05$, the minimum valid rate
%
% _Data Type_: double
%
% *|[MaxValidRate]|* - validation parameter, $5$, the maximum valid rate
%
% _Data Type_: double
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  properties
        method
		% Parameters used to control interpolation/extrapolation method
        outputfreq
        ltfwd 
        llp 
        decayrate
        startterm 
        endterm 

		% local object validation parameters
        minValidRate = -0.05;
        MaxValidRate = 5;
				
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap ()]|* - Function extrapolates and interpolates raw 
% market yield curve data to produce a Zero Coupon Bond (ZCB) yield curve 
%
% *|[Calibrate ()]|* - calibrates parameters which are then used in
% bootstrap methods. We have not created a calibrate method.
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 methods
    % Constructor
    function obj = bootstrap_RawtoZCB ()
		obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
    end                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________________________
%
%% |1) [Bootstrap()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function extrapolates and interpolates raw market yield curve data to produce 
% a Zero Coupon Bond (ZCB) yield curve using two functions |[FitWilsonSmithParameters]| 
% and |[WilsonsSmithZCBPrices]| from class |[BsWilsoSmith]|
%
% *_Inputs_*
%
% *|[DataSeriesIn]|* - raw market yield curve
% 
% _Data Type_: 1-dim array 
% 
% *_Outputs_*
%
% Zero Coupon Bond (ZCB) yield curve
%
% _Data Type_: 1-dim array
%
% *_Calculation_* 
%
% Given raw market yield curve, depending on the |[method]| the user chooses, 
% different interpolation/extrapolation approach is applied.
%
% Currently only method "wilson smith" is available. Other methods, e.g. "cubic
% spline", can be developed in the future.
%
% Under "wilson smith", calculation steps are as following:
% 
% STEP 1: Fit Wilson Smith parameters
%
% This is done by calling function |[FitWilsonSmithParameters]|.
% See class |[BsWilsoSmith]| for details.
%
% STEP 2: Returns fitted ZCB prices for the required maturities
%
% This is done by calling function |[WilsonsSmithZCBPrices]|.
% See class |[BsWilsoSmith]| for details.
%
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   function results = Bootstrap(obj,DataSeriesIn)
		
		% import prursg.Bootstrap.*;
        switch lower(obj.method) % Change strings to lower case 
            case 'wilson smith'
				ParametersIn{1} = obj.outputfreq;
				ParametersIn = [ParametersIn obj.ltfwd obj.llp ...
                    obj.decayrate obj.startterm obj.endterm obj.method];
                % Create a new Wilson Smith Bootstap Object 
                newWilsoSmith = Bootstrap.BsWilsonSmith(DataSeriesIn, ...
                    ParametersIn);
                % Fit Wilson Smith to our Raw Data
                fprintf('RawtoZCB - Fitting Wilson Smith Parameters \n');   
                newWilsoSmith.FitWilsonSmithParameters
                fprintf('RawtoZCB - Calculating ZCB Prices \n');  
                results= newWilsoSmith.WilsonsSmithZCBPrices;
                fprintf('RawtoZCB - Algorithm Complete \n'); 
            case 'cubic spline'
			
            otherwise
                disp('Unknown method.')
        end
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |2) [Calibrate()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function calibrates parameters which are then used in bootstrap methods 
%
% See class |[BaseBootstrapAlgorithm]| for details
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
   function Calibrate(obj, inDataSeries)
		
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	   
 end
    
end