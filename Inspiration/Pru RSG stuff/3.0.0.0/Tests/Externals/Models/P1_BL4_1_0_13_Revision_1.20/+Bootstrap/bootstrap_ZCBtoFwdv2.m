classdef bootstrap_ZCBtoFwdv2 < handle
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     % Enter Description
    properties
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % Data Series         
        ZeroCouponBondPrices = [];    

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % Parameters 
       
        OutputFrequency = []; % string representing frequency profile
        OutputCompounding = []; % Simple, Annualized, Continuous
        OutputCompoundingFrequency = []; % Spot, Forward, Swap
        
    end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_ZCBtoFwdv2 ()
           
       end
                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
        function results = bs(obj, DataSeriesIn, ParametersIn)
            
            obj.ZeroCouponBondPrices = DataSeriesIn;
                        
            obj.OutputFrequency=  ParametersIn{1};
            obj.OutputCompounding = ParametersIn{2}; % Simple, Annualized, Continuous
            obj.OutputCompoundingFrequency = str2num(ParametersIn{3}); % Spot, Forward, Swap
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 1. Get OutPutFreqProfile            
             maxTerm = obj.ZeroCouponBondPrices.axes.values(end);
             BsfrequencyprofileObject =prursg.Bootstrap.Bsfrequencyprofile(obj.OutputFrequency,maxTerm);
             OutputFrequencyProfile = BsfrequencyprofileObject.AdjustedIntervalArray;
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2. Match ZCB to the outputfrequencyprofile 
             ZCBPrices_Temp = BsfrequencyprofileObject.SmallerDataSeriesObject(OutputFrequencyProfile,obj.ZeroCouponBondPrices);
            
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             % Step 3. Calculate Forward Rates
               
               results = ZCBPrices_Temp ;        % Set-up structure for the results            
                                          
               for i = 1: size(results.dates, 1)
                   
                   numberofpoints = size(results.values{i},2);
                   
                   BondPrice1 = [1 ,ZCBPrices_Temp.values{i}(1, 1 :numberofpoints -1)];
                   BondPrice2 = ZCBPrices_Temp.values{i}   ;
                   Maturity1 =[0 ,ZCBPrices_Temp.axes(1).values( 1 :numberofpoints -1, 1)'];
                   Maturity2 =ZCBPrices_Temp.axes(1).values';
                   
                   if strcmp(obj.OutputCompounding, 'cont')
                       results.values{i} =log(BondPrice1 ./BondPrice2)./ (Maturity2-Maturity1) ;
                   elseif strcmp(obj.OutputCompounding , 'ann')
                       results.values{i} =((BondPrice1 ./BondPrice2).^(1./ (obj.OutputCompoundingFrequency.*(Maturity2-Maturity1))) -1).*obj.OutputCompoundingFrequency;
                   end
  
              
               end
             
        end
                  
        

    end
    
end

