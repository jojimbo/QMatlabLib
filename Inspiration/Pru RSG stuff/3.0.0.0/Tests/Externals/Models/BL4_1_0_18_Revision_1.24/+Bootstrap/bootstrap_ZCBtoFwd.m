%% Zero Coupon Bond to Forward Rate
% 
% *The class converts zero coupon bond prices to forward rates.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_ZCBtoFwd < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% Given  an input zero coupon bond data series we calculate a forward rate
% series with the output frequency given by *|[outputfreq]|*.

%% Properties
% *Input Data Series*  
%
% *|[ZeroCouponBondPrices]|* - The price of a zero coupon bond, $B(t,T)$,
% at time, $t=0$, which pays 1 at maturity, $t=T$.
%
%  Data Type: data series 
%
% *Input Parameters* 
%
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
%
% *|[compounding]|* - Defines the way that the output yield curve is 
% compounded, e.g. "annually" or "continuously".
%
%  Data Type: string
%
% *|[compoundingfrequency]|* - Defines the annual frequency, $f$, at which 
% the output yield curve is compounded e.g. "2" for semi-annually.
%
%  Data Type: double
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
       
      % Data Series         
        ZeroCouponBondPrices = [];    

      % Parameters 
       
        outputfreq = []; 
        compounding = []; 
        compoundingfrequency= []; 
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% The class introduces one method:
% 
% *|bootstrap_ZCBtoFwd ()|* - Function returns forward rates to a given output frequency profile from input
% zero coupon bond prices using a specified compounding frequency.
%

%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
    % Constructor
    
       function obj = bootstrap_ZCBtoFwd ()
          obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
       end
                  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function returns forward rates to a given output frequency profile, *|[outputfreq]|*,  from input
% zero coupon bond prices, *|[ZeroCouponBondPrices]|*,  using a specified 
% compounding frequency, *|[compoundingfrequency]|*.
% 
% *_Inputs_*
%
% *|[ZeroCouponBondPrices]|* - The price of a zero coupon bond, $B(t,T)$,
% at time, $t=0$, which pays 1 at maturity, $t=T$.
%
%  Data Type: data series  
%
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
%
% *|[compounding]|* - Defines the way that the output yield curve is 
% compounded, e.g. "annually" or "continuously".
%
%  Data Type: string
%
% *|[compoundingfrequency]|* - Defines the annual frequency, $f$ at which 
% the output yield curve is compounded e.g. "2" for semi-annually.
%
%  Data Type: double
%
% *_Outputs_*
%
% A yield curve of forward rates in accordance with the output frequency
% profile.
%
% *_Calculations_*
%
% Firstly we sort and clone data.
%
% The next step is to identify and set up the output frequency profile which specifies the
% frequency of outputs e.g. annually or monthly etc.
% The zero coupon bond input is then matched to the output frequency profile.
%
% Depending whether we have continuous or annual compounding the forward rates
% are calculated using: 
% 
%%
% i) Continuous Compounding 
%
% $$ F(m, n) = \frac{ln\left(\frac{B(t,m)}{B(t,n)}\right)}{n-m} $$
%
% where
%
% $F(m, n)$ : Forward rate between time, $m$ and $n$ where $m<n$.
%
% $B(t,T)$ : The price of a zero coupon bond at time, $t$, which pays 1 
% at maturity, $t=m$.
%
% or
%
% ii) Discrete Compounding
%
% $$ F(m, n) = \left[\left(\frac{B(t,m)}{B(t,n)}\right)^{1/(n-m).f}-1\right].f $$    
%
% with
%
% $f$ : Annual compounding frequency.   
%
% Finally data series properties are updated.
%
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Methods

        function results = Bootstrap(obj, DataSeriesIn)
            
                        
            newSortDataSeries=Bootstrap.BsSort(); 
            
            obj.ZeroCouponBondPrices =newSortDataSeries.SortDataSeries...
                (DataSeriesIn(1).Clone);
               
                      
             maxTerm = obj.ZeroCouponBondPrices(1).axes(1).values{1, end}; 
             BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                 (obj.outputfreq,maxTerm);
             outputfreqProfile = ...
                 BsfrequencyprofileObject.AdjustedIntervalArray;
           
            
             ZCBPrices_Temp = ...
                 BsfrequencyprofileObject.SmallerDataSeriesObject...
                 (outputfreqProfile,obj.ZeroCouponBondPrices);
            
                            
               results = ZCBPrices_Temp ;        
                                          
               for i = 1: size(results.dates, 1)
                   
                  
                   
                   BondPrice1 = ...
                       [1 ,ZCBPrices_Temp.values{i}(1, 1 :end -1)];
                   BondPrice2 = ZCBPrices_Temp.values{i}   ;
                   Maturity2 =cell2mat(ZCBPrices_Temp.axes(1).values);
                   Maturity1 =[0 ,Maturity2(1,  1 :end -1)];
                   
                   if strcmp(obj.compounding, 'cont')
                       results.values{i} =log(BondPrice1 ./BondPrice2)./...
                           (Maturity2-Maturity1) ;
                   elseif strcmp(obj.compounding , 'ann')
                       results.values{i} =((BondPrice1 ./BondPrice2).^...
                           (1./ (obj.compoundingfrequency.*...
                           (Maturity2-Maturity1))) -1).*...
                           obj.compoundingfrequency;
                   end
                
               end
               
              
               
               results.Name = '';
               results.source ='iMDP';
               results.ticker= 'na';
               results.description = 'derived ZCBtoFwd method';
               results.ratetype = 'fwd';
               results.compounding =obj.compounding;
               results.compoundingfrequency=  num2str...
                   (obj.compoundingfrequency);
               results.daycount ='na';
               results.units ='absolute';
             
        end
                  
        

    end
    
end

