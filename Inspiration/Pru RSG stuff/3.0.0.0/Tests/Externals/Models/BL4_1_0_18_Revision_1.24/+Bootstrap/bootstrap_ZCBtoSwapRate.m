%% ZERO COUPON BOND TO SWAP RATE
% 
% *The class takes an input data series object containing a set of
% zero coupon bonds and outputs a two dimesional data series object
% of equilibrium swap (par) rates with axes corresponding to maturity
% and tenor of swap contract.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_ZCBtoSwapRate < prursg.Bootstrap.BaseBootstrapAlgorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% How to use the class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
% New properties have been defined and the default method |[Bootstrap()]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method calculates a two dimensional data series 
% object of equilibrium forward swap (par) rates with axes corresponding to 
% maturity and tenor using function |[EQFORWARDSWAPRATE()]|.
%
% Function |[createArrayfromCSVstring()]| is a supporting tool which creates 
% an array containing doubles from a CSV string.
%
% Method |[Calibrate()]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
% There are two ways to use this class:
%
%
%% Properties
%
% *|[outputfreq]|* : A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string  
%
% *|[compoundingfrequency]|* : The annual frequency, $f$, at which 
% the output yield curve is compounded e.g. "2" for semi-annually.
%
% _Data Type_: double
%
% *|[swaptenors]|* : A string that lists the length of the swap contracts, $\tau$.
% 
% _Data Type_: string
%
% *|[ZCBPRICES]|* : The price of a zero coupon bond, $B(t,T)$,
% at present time, $t$, which pays 1 at maturity, $t=T$.
%
% _Data Type_: data series, doubles
%
% *|[ZCBMaturities]|* : Times, $T$, when the zero coupon bonds mature.
%
% _Data Type_: data series, doubles
%
% *|[SwaptionMaturities]|* : Times when the swaptions expire. These are 
% also the times when the swap contracts begin, $T_{Start}$.
%
% _Data Type_: data series, doubles
%
% *|[newDataSeriesObject]|* : New data series object, setup to store results
%
% _Data Type_: data series
%
% *|[TimeTolerance]|* : Tolerance value used to help identify the time 
% indices of a swap contract.
%
% _Data Type_: double
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 properties

    outputfreq ; 
    compoundingfrequency;  
    swaptenors ;

    ZCBPRICES ;
    ZCBMaturities ;          
    SwaptionMaturities

    newDataSeriesObject 
    TimeTolerance = 1/250; % TimeTolerance within one business day

 end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%% List of Methods
%
% *|1) |[Bootstrap()]|* : Function returns a two dimensional
% data series object of equilibrium swap (par) rates with axes
% corresponding to maturity and tenor of swap contract.
%
% *|2) |[EQFORWARDSWAPRATE()]|* : Function returns a forward starting 
% annuity factor and the corresponding equilibrium forward swap rate 
% calculated from zero coupon bond (ZCB) yield curve.
%
% *|3) |[createArrayfromCSVstring()]|* : Function returns an array
% containing doubles from an input string.
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 methods  
  % Constructor
  function obj = bootstrap_ZCBtoSwapRate()
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
% Function uses |[EQFORWARDSWAPRATE()]| to return a two dimensional
% data series object of forward starting equilibrium swap (par) rates with
% axes corresponding to maturity and tenor of the swap contracts.
%
% *_Inputs_*
%
% |[DataSeriesIn]| - zero coupon bond yield curve          
% 
% _Data Type_: 1-dim array
%
% *_Outputs_*
%
% Two dimensional data series object of equilibrium forward starting swap
% (par) rates with axes corresponding to maturity and tenor or swap 
% contract.
%
% *_Calculations_*
%
% Initially the ZCB data is sorted and cloned. Then the output frequency
% profile is identified and set up, this specifies the frequency of 
% outputs e.g. monthly, quarterly or annually etc.
%
% Using *|[EQFORWARDSWAPRATE()]|*, looped over by swap start dates and
% swap tenors, the two dimensional swap rate data series objects are created
% for each date that is required.
%
% The output data series properties are then updated.
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
 function results = Bootstrap(obj,DataSeriesIn)

 %%%% STEP 1: Sort and clone ZCB data %%%%
    newSortDataSeries=Bootstrap.BsSort();
    obj.newDataSeriesObject =newSortDataSeries.SortDataSeries...
        (DataSeriesIn(1).Clone);

    inumberOfDates =  size(DataSeriesIn(1).dates,1);

    obj.ZCBPRICES = obj.newDataSeriesObject.values;
    obj.ZCBMaturities  =...
        cell2mat(obj.newDataSeriesObject.axes(1).values);

    swaptenors = obj.createArrayfromCSVstring(obj.swaptenors);

 %%%% STEP 2: Get OutPutFreqProfile %%%%
    maxTerm = obj.newDataSeriesObject.axes(1).values{1, end};
    BsfrequencyprofileObject =...
        Bootstrap.Bsfrequencyprofile(obj.outputfreq,maxTerm);
    outputfreqProfile = ...
        BsfrequencyprofileObject.AdjustedIntervalArray;
    outputfreqProfile = [ 0 ; outputfreqProfile] ;
    % The Inclusion of zero gives us the initial par rates

 %%%% STEP 3: Set-Up data series object to store %%%%
    % results :: use existing raw data series object to achieve this
    obj.newDataSeriesObject.axes(1).values= ...
        num2cell(outputfreqProfile');
    obj.newDataSeriesObject.axes(2).values = num2cell(swaptenors);

    SWAPRATETENOR = 1/ obj.compoundingfrequency;
    NumOFSwapTenors =size(obj.newDataSeriesObject.axes(2).values,2);
    NumOFSwaptionMaturity =...
        size(obj.newDataSeriesObject.axes(1).values,2);
    Results = zeros(NumOFSwapTenors,NumOFSwaptionMaturity );
    % allocate storage space

    for i= 1 : inumberOfDates
        for j = 1 : NumOFSwapTenors
            SwapTenor = obj.newDataSeriesObject.axes(2).values{j};
            for k = 1 : NumOFSwaptionMaturity
                SwaptionMaturity = ...
                    obj.newDataSeriesObject.axes(1).values{k};
                [SwapRate AnnuityFactor] = ...
                    obj.EQFORWARDSWAPRATE(obj.ZCBPRICES{i},...
                    obj.ZCBMaturities, SwaptionMaturity, ...
                    SwapTenor, SWAPRATETENOR);
                Results(j,k) = SwapRate;
            end
        end
        obj.newDataSeriesObject.values{i} =Results';
    end

 %%%% STEP 4: Return data series object %%%%
    results = obj.newDataSeriesObject;

 %%%% STEP 5: Update Data-Series Properties %%%%
    obj.newDataSeriesObject.axes(1).title = 'Swaption Maturity';
    obj.newDataSeriesObject.axes(2).title =  'Swap Tenor';
    obj.newDataSeriesObject.description = ...
      'derived (equilibrium) swap rates using bootstrap_ZCBtoSwapRate';
    obj.newDataSeriesObject.source = 'iMDP';
    obj.newDataSeriesObject.ratetype = 'swap';
    obj.newDataSeriesObject.compounding ='ann';
    obj.newDataSeriesObject.compoundingfrequency = ...
        num2str(obj.compoundingfrequency);
    obj.newDataSeriesObject.daycount ='na';
    obj.newDataSeriesObject.units ='absolute';

 end         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |2) [EQFORWARDSWAPRATE()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% The function returns equilibrium foward swap rates and an annuity factor
% based on a set of ZCB Prices, . It assumes that the ZCB maturity values
% are evenly spaced and that swap payments coincide with a ZCB maturity.
%
% *_Inputs_*
%
% *|[ZCBPRICES]|* : The price of a zero coupon bond, $B(t,T)$,
% at present time, $t$, which pays 1 at maturity, $t=T$.
%
% _Data Type_: data series, doubles
%
% *|[ZCBMaturities]|* : Times, $T$, when the zero coupon bonds mature.
%
% _Data Type_: data series, doubles
%
% *|[SWAPSTART]|* : Time at which the swap contract begins, $T_{Start}$.
%
% _Data Type_: double
%
% *|[SWAPTENOR]|* : Duration of the swap contract, in years.
%
% _Data Type_: double
%
% *|[SWAPRATETENOR]|* : Time period between swap payments, in years.
%
% _Data Type_: double
%
% *_Outputs_*
%
% *|[SwapRate]|* : Equilibrium forward swap rate, $R(t)$, at present time $t$.
%
% _Data Type_: double
%
% *|[AnnuityFactor]|* : Annuity factor.
%
% _Data Type_: double 
%
% *_Calculations_*
%
% *Calculation of Annuity Factor*
%
% To calculate the annuity factor the following formula is used:
%
% $$ A(t,T_{Start},T_{End})=\frac{1}{f}\sum_{i=1}^{f\tau}
% B\left(t, T_{Start}+\frac{i}{f}\right) $$
%
% where,
%
% $A(t,T_{Start},T_{End})$ : The value of an annuity factor at time, $t$,
% for an annuity starting at $T_{Start}$ and finishing at $T_{End}$.
%
% $f$ : Compounding frequency; the reciprocal of the time between swap
% payments.
%
% $T_{Start}$ : Start time of the swap
%
% $\tau=T_{End}-T_{Start}$ : Swap tenor
%
% *Calculation of Swap Rate*
%
% To calculate the swap rate we use:
%
% a) If $,\,T_{Start}=0$,
%
% $$ R(t)=\frac{1-B(t,T_{End})}{A(t,T_{Start},T_{End})} $$
%
% b) Otherwise,
%
% $$ R(t)=\frac{B(t,T_{Start}+\frac{1}{f})-B(t,T_{End})}{A(t,T_{Start},T_{End})} $$
%
% where,
%
% $R(t)$ : Present value, at $t$, of $\tau$ -year swap starting at time,
% $T_{Start}$.
%
% $B(t,T)$ : Price of zero coupon bond with maturity, $T$.
%
%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
  function [SwapRate AnnuityFactor]=...
        EQFORWARDSWAPRATE(obj,ZCBPRICES,ZCBMaturities, SWAPSTART, ...
        SWAPTENOR, SWAPRATETENOR)
    
    NumberOfBonds=size(ZCBPRICES,2);
    TenorMaturityRatio = floor(SWAPRATETENOR/ZCBMaturities(1,1));
    
    if ZCBMaturities( 1, end) < (SWAPSTART + SWAPTENOR)
        SwapRate =0;
        AnnuityFactor=0;
        return
    end
  
    % Find Position of the first Bond required to Calculate the Forward
    % Starting annuity factor
    for i = 1:1:NumberOfBonds
        if  (abs(SWAPSTART) < obj.TimeTolerance)
            SWAPSTARTINDEX = 0;
        elseif    (abs(ZCBMaturities(1,i) - SWAPSTART)<...
                obj.TimeTolerance)
            SWAPSTARTINDEX = i;
        end
        
        if abs(ZCBMaturities(1,i) -( SWAPSTART +SWAPTENOR)) < ...
                obj.TimeTolerance
            SWAPSENDINDEX = i;
            break % Exit the For Loop
        end
    end
    
    % Calculate Annuity Factor
    AnnuityFactor = 0;
    for i = (SWAPSTARTINDEX +...
            TenorMaturityRatio):TenorMaturityRatio:SWAPSENDINDEX
        AnnuityFactor =AnnuityFactor +SWAPRATETENOR*ZCBPRICES(1,i);
    end
    
    % Calculate the equilibrium spot rate  
    if SWAPSTART == 0
        SwapRate = (1 - ZCBPRICES(SWAPSENDINDEX))/AnnuityFactor;
    else
        SwapRate = (ZCBPRICES(SWAPSTARTINDEX) - ...
            ZCBPRICES(SWAPSENDINDEX))/AnnuityFactor;
    end
    return
    
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |3) [createArrayfromCSVstring()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function returns an array of doubles from an input csv string. 
%
% *_Inputs_*
%
% *|[stringParameter]|* : A series of numbers separated by commas,
% expressed as a csv string.
%
% _Data type_: String
%
% *_Outputs_*
%
% An array whose elements are the numbers previously recorded in the input 
% csv string.
%
% _Data type_: Data series
%
% *_Calculations_*
%
% Function identifies the position of commas within the input string.
% Using these positions the numbers between the commas are allocated to
% elements of an array.
%
%
%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  function y = createArrayfromCSVstring(obj, stringParameter)
     pos = findstr( stringParameter, ',');

     if length(pos) == 0
         y = str2num(stringParameter);
     else
         y = zeros ( 1, length(pos)+1); % Allocate storage space
             y(1, 1) = str2num(stringParameter(1 :pos(1) -1));
         for i = 2 : length( pos)
             y(1, i) = str2num(stringParameter(pos(i-1)+1 :pos(i) -1));
         end    
             y(1, length(pos)+1) = ...
                 str2num(stringParameter(pos(length(pos))+1 :end));
     end
  end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 end
    
end

