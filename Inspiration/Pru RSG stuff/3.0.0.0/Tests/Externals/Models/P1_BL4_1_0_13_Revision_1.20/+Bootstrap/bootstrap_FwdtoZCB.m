%% Forward Rate to Zero Coupon Bond
% 
% The class returns zero coupon bond prices from forward rates.
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_FwdtoZCB < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
% For a data series of forward rates we calculate zero coupon bond prices
% with a specific output frequency profile.
%

%% Properties
% *Input Data Series*
%
% *|[InputFwdRates]|* - Forward rates, $F_{TT'}$, between time, $T$
% and $T'$, with term, $T'-T$.
%
%  Data Type: data series
%
% *Input Parameters*
% 
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
      
      % Data Series         
        InputFwdRates = [];    
  
      % Parameters 
        outputfreq = []; 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
%
% The class introduces one method:
%
% *|bootstrap_FwdtoZCB ()|* - Function returns zero coupon bond prices from
% an input of forward rates to a given output frequency profile.
%

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
    
    % Constructor
    
       function obj = bootstrap_FwdtoZCB ()
           obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
       end              
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
% 
% *_Inputs_*
%
% *|[InputFwdRates]|* - Forward rates, $F_{TT'}$, between time, $T$
% and $T'$, with term, $T'-T$.
%
%  Data Type: data series
% 
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
%
% *_Outputs_*
% 
% Zero coupon bonds in accordance with the output frequency profile.
%
% *_Calculations_* 
%
% Sort and clone the input data.
%
% Depending whether we have continuous or discrete compounding the 
% zero coupon bond prices are calculated using:
%%
% i) Continuous Compounding 
%
% $$ P_{t,T} = \prod^T_{i-1}exp\Big[\big(T_{i-1}-T_{i}\big)F_{T_{i-1}T_i}\Big] $$
%
% where
%
% $P_{t,T}$ : The price of a zero coupon bond at time, $t$, which pays 1 
% at maturity, $t=T$.
%
% $F_{T_{i-1}T_i}$ : Forward rate between time, $T_{i-1}$ and $T_i$.  
%
% or
%
% ii) Annual Compounding
%
% $$ P_{t,T} = \prod_{i=1}^T\Big(1+\frac{F_{T_{i-1}T_i}}{f}\Big)^{(T_{i-1}-T_i)f} $$ 
%
% with
%
% $f$ : Compounding annual frequency.   
%
% The next step is to identify and set up the output frequency profile which specifies the
% frequency of outputs e.g. annually or monthly etc.
%
% Finally the data series properties are updated.
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function results = Bootstrap(obj, DataSeriesIn)            
            
              
            
            newSortDataSeries=Bootstrap.BsSort(); 
            
            obj.InputFwdRates =newSortDataSeries.SortDataSeries...
                (DataSeriesIn(1).Clone);  
           
            freq = obj.InputFwdRates.compoundingfrequency;
            
            
             results = obj.InputFwdRates ;        
             
             for i = 1: size(results.dates, 1)
                 numberofpoints = size(results.values{i},2);
                 Maturity =cell2mat(obj.InputFwdRates.axes(1).values);
                 
                 if strcmp(obj.InputFwdRates.compounding, 'cont')
                     results.values{i}(1) = ...
                         exp (- obj.InputFwdRates.values{i}(1) .*...
                         Maturity(1));
                     for j = 2:numberofpoints
                         results.values{i}(j) = ...
                             results.values{i}(j-1) .* exp ...
                             (obj.InputFwdRates.values{i}(j-1) .*...
                             (Maturity(j-1) - Maturity(j)));
                     end
                 elseif strcmp(obj.InputFwdRates.compounding , 'ann')
                     results.values{i}(1) = (1 + ...
                         obj.InputFwdRates.values{i}(1)/freq).^...
                         (-Maturity(1)*freq);
                     for j = 2:numberofpoints
                         results.values{i}(j) = results.values{i}(j-1).*...
                             (1 + obj.InputFwdRates.values{i}(j)/freq).^...
                             ((Maturity(j-1) - Maturity(j))*freq);
                     end
                 end
                 
                 
             end
            
                 
             maxTerm = obj.InputFwdRates(1).axes(1).values{1, end}; 
             BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                 (obj.outputfreq,maxTerm);
             outputfreqProfile =...
                 BsfrequencyprofileObject.AdjustedIntervalArray;
           
            
             results = BsfrequencyprofileObject.SmallerDataSeriesObject...
                 (outputfreqProfile,results);
            
             
             
               results.Name = '';
               results.source ='iMDP';
               results.ticker= 'na';
               
               results.description = 'derived ZCBtoZCB method';
               results.ratetype = 'zcb';
               results.compounding ='na';
               results.compoundingfrequency=  'na';
               results.daycount ='na';
               results.units ='absolute'; 
                        
               
        end
                  
        

    end
    
end
