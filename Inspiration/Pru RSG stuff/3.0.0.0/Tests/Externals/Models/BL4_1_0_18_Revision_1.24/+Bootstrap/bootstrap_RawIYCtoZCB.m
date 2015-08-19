%% RAW MARKET INFLATION YIELD CURVE TO INFLATION ZERO COUPON BOND YIELD CURVE
% 
% *This class extrapolates and interpolates raw market inflation yield curve data
% to produce an inflation Zero Coupon Bond (ZCB) yield curve*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_RawIYCtoZCB < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method extrapolates and interpolates raw market inflation yield curve data
% to produce an inflation Zero Coupon Bond (ZCB) yield curve
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
% *|[stfwdInf]|* - short term forward inflation assumption
%
% _Data Type_: double 
%
% *|[ltfwdInf]|* - long term forward inflation assumption
%
% _Data Type_: double 
%
% *|[ShortInflationDuration]|* - duration of the short term forward inflation assumption
%
% _Data Type_: double 
%
% *|[newDataSeriesObject]|* - initial set-up of the bootstrap object
%
% _Data Type_: data series 
%
% *|[Methods]|* - Used to store multiple methods contain with method
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
		       
        stfwdInf
        ltfwdInf       
        ShortInflationDuration
        
        newDataSeriesObject
        Methods % Used to store multiple methods contain with method
        % local object validation parameters
        minValidRate = -0.05;
        MaxValidRate = 5;
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap ()]|* - Function extrapolates and interpolates raw market inflation 
% yield curve data to produce an inflation Zero Coupon Bond (ZCB) yield curve 
%
% *|[Calibrate ()]|* - calibrates parameters which are then used in
% bootstrap methods. We have not created a calibrate method.
%    
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    function obj = bootstrap_RawIYCtoZCB ()
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
% *|[DataSeriesIn]|* -  two Data Series, one is the raw inflation data,
% the other is optional and contains short inflation rates
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
% STEP 0: Take a Clone of the original data and sort
%
% STEP 1: Apply method 'shortinflation', which is used to control the short 
% end of the inflation curve.
%
% This step essentially add the short inflation assumption as a row to the 
% raw inflation yield curve
%
% STEP 2: Interpolates and extrapolates the raw data using "wilson smith"
%
% This step is exactly the same as the one in class |[bootstrap_RawtoZCB]|.
% Except here the raw data may have been supplemented by the short inflation
% assumption.
% We first fit Wilson Smith parameters by calling function |[FitWilsonSmithParameters]|.
% Then derive fitted ZCB prices for the required maturities by calling function 
% |[WilsonsSmithZCBPrices]|.
% See class |[BsWilsoSmith]| for function details.
% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 function results = Bootstrap(obj,DataSeriesIn)

 %%%% STEP 0: Take a Clone of the original data and sort %%%%
    numOfDataSeries = size(DataSeriesIn,2);
    inumberOfDates =  size(DataSeriesIn(1).dates,1);

    newSortDataSeries=Bootstrap.BsSort();

    obj.newDataSeriesObject = newSortDataSeries.SortDataSeries ...
        (DataSeriesIn(1).Clone);
    for i =2 : numOfDataSeries
        obj.newDataSeriesObject = [obj.newDataSeriesObject ...
            newSortDataSeries.SortDataSeries(DataSeriesIn(i).Clone)];
    end

 %%%% STEP 1: Apply First Method %%%%
  
    % Extract Method Names
    Methodindices = find(obj.method == '_');
    obj.Methods = { obj.method(1 : Methodindices(1) -1) , ...
        obj.method( (Methodindices(1)+1) : end)};

    switch lower( obj.Methods{1})
        case  'shortinflation'
        % This method is used to control the short end of the inflation curve
          obj.newDataSeriesObject(1).axes(1).values = [ ...
              {obj.ShortInflationDuration} ...
              obj.newDataSeriesObject(1).axes(1).values];

          % Insert a new axis value for the short maturity security
          obj.newDataSeriesObject

          for i =1 : inumberOfDates

            if strcmp(obj.newDataSeriesObject(1).units, 'percent')
                obj.stfwdInf = obj.stfwdInf * 100;
            end

            if  numOfDataSeries  == 2;
                % Use Historic Data-Series of short-term inflation
                % rates
                if strcmp(obj.newDataSeriesObject(2).units, 'absolute')
                   shortinflation = obj.newDataSeriesObject(2). ...
                       values{i,1}*100;
                end
            else
                shortinflation =  obj.stfwdInf;
            end

            switch lower( obj.newDataSeriesObject(1).ratetype)
                % Note we will assume that ShortInflationDuration is
                % sufficiently short such that the rates definitions
                % differences are trivial
                case 'spot'
                    newDatSeriesValue = shortinflation;
                case 'fwd'
                    newDatSeriesValue = shortinflation;
                case 'par'
                    newDatSeriesValue = shortinflation;
                case 'zcb'
                    newDatSeriesValue = exp( - shortinflation * ...
                        obj.ShortInflationDuration/100)*100;
            end

            % Append new data element to the raw inflation data
            obj.newDataSeriesObject(1).values{i} = [ newDatSeriesValue ...
                obj.newDataSeriesObject(1).values{i}];

          end
    end

 %%%% STEP 2: Interpolates and extrapolates %%%%

    switch lower(obj.Methods{2}) % Change strings to lower case
        case 'wilsonsmith'
            ParametersIn{1} = obj.outputfreq;
            ParametersIn = [ParametersIn obj.ltfwdInf obj.llp ...
                obj.decayrate obj.startterm obj.endterm obj.method];
            % Create a new Wilson Smith Bootstap Object
            newWilsoSmith = Bootstrap.BsWilsonSmith ...
                (obj.newDataSeriesObject(1), ParametersIn);
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