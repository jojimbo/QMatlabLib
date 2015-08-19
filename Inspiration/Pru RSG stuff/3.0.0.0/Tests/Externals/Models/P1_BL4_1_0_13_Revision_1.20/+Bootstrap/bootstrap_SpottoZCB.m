%% Spot Rate to Zero Coupon Bond
% 
% *The class returns zero coupon bond prices from spot rates.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_SpottoZCB < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% Given an input spot rate data series we calculate a zero coupon bond 
% series with the output frequency given by *|[outputfreq]|*.

%% Properties
% *Input Data Series*
%
% *|[InputSpotRates]|* - $S_{t,T}$, spot rates at time, $t$, paying at 
% maturity, $t=T$.
% 
%  Data Type: data series
%
% *Input Parameters*
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
  
      % Data Series         
        InputSpotRates = [];    
  
      % Parameters 
        outputfreq = []; 
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
%
% The class introduces one method:
%
% *|bootstrap_SpottoZCB ()|* - Function returns a data series of zero
% coupon bond (ZCB) prices, $P_{t,T}$, with a given output frequency profile. 
% The ZCB prices are derived from an input of spot rates, $S_{t,T}$, with 
% compounding frequency, $f$.
%

%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    methods
        
    % Constructor
    
       function obj = bootstrap_SpottoZCB ()
           obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm(); 
       end            
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function returns a data series of zero coupon bond (ZCB) prices, $P_{t,T}$, 
% with a given output frequency profile, *|[outputfreq]|*. 
% The ZCB prices are derived from an input of spot rates, *|[InputSpotRates]|*, 
% with compounding frequency, $f$.
%
% *_Inputs_*
%
% *|[InputSpotRates]|* - $S_{t,T}$, spot rates at time, $t$, paying at 
% maturity, $t=T$.
% 
%  Data Type: data series
% 
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
% 
%
% *_Outputs_*
%
% A yield curve of zero coupon bond prices in accordance with the output
% frequency profile.
%
% *_Calculations_* 
%
% Sort and clone the input data.
%
% The next step is to identify and set up the output frequency profile 
% which specifies the frequency of outputs e.g. annually or monthly etc.
%
% Depending whether we have continuous or annual compounding the 
% zero coupon bond prices are calculated using:
%%
% i) Continuous Compounding 
%
% $$ P_{t,T} = e^{(t-T).S_{t,T}} $$
%
% where
%
% $S_{t,T}$ : Spot rate at time, $t$, paying at 
% maturity, $t=T$.
%
% $P_{t,T}$ : The price of a zero coupon bond at time, $t$, which pays 1 
% at maturity, $t=T$.
%
% or
%
% ii) Annual Compounding
%
% $$ P_{t,T} = (1+\frac{S_{t,T}}{f})^{(t-T).f} $$    
%
% with
%
% $f$ : Compounding annual frequency.   
%
% Finally the data series properties are updated.
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
    % Methods

        function results = Bootstrap(obj, DataSeriesIn)
             
            
            newSortDataSeries=Bootstrap.BsSort(); 
            
            obj.InputSpotRates =newSortDataSeries.SortDataSeries ...
                (DataSeriesIn(1).Clone);  

                  
            
             maxTerm = obj.InputSpotRates.axes(1).values{1, end}; 
             BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                 (obj.outputfreq,maxTerm);
             outputfreqProfile = ...
                 BsfrequencyprofileObject.AdjustedIntervalArray;
           
            
             SpotRates_Temp = ...
                 BsfrequencyprofileObject.SmallerDataSeriesObject...
                 (outputfreqProfile,obj.InputSpotRates);

            
                          
               results = SpotRates_Temp ;
               
               for i = 1: size(results.dates, 1)                   
                   
                    Maturity =cell2mat(SpotRates_Temp.axes(1).values);

                   if strcmp(obj.InputSpotRates.compounding, 'cont')
                        results.values{i} = exp(-Maturity.*...
                            results.values{i});
                    elseif strcmp(obj.InputSpotRates.compounding, 'ann')
                        results.values{i} = (1 + results.values{i}).^...
                            ( -obj.InputSpotRates.compoundingfrequency.*...
                            Maturity ); 
                   end   

               end
               
            
               
               results.Name = '';
               results.source ='iMDP';
               results.ticker= 'na';
               
               results.description = 'derived ZCBtoSpotmethod';
               results.ratetype = 'zcb';
               results.compounding ='na';
               results.compoundingfrequency=  'na';
               results.daycount ='na';
               results.units ='absolute';  
               
        end
        
    end
    
end

