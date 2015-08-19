classdef bootstrap_SwaptionPrice < handle
    % 12/10/11 Created by Graeme Lawson 
    % the class takes as input a data series object containinga set of
    % Zeroc copon Bonds and ouputs a two dimesional data series object
    % of equilibrium swap (par) rates with axes corresponding to maturity
    % and tenor of swap contract
    
    properties
        
        ZCBPRICES ;
        ZCBMaturities ; 
        outputfreq ;  
        
        SwapTenors ;
        SwaptionMaturities ;
        SwaptionStrikes ; % These are currently defined as the difference from the ATM swap rate suject to  a lower bound of zero
        CompoundingFrequency; 
        
        volatilityType;
        
        OptionType
        OutputType
                
         % Set-Up data series object to store results
        newDataSeriesObject
        
    end
    
    methods
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
        function obj = bootstrap_SwaptionPrice()

        end
    
       function results = bs(obj,DataSeriesIn, ParametersIn)
           
           %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 1 :: enter comma seperated data into arrays       
            newobject = prursg.Bootstrap.bootstrap_ZCBtoSwapRate;
            
            obj.SwapTenors = newobject.createArrayfromCSVstring(ParametersIn{1});        
            obj.SwaptionMaturities = newobject.createArrayfromCSVstring(ParametersIn{2}); 
            obj.SwaptionStrikes = newobject.createArrayfromCSVstring(ParametersIn{3});
            obj.CompoundingFrequency = ParametersIn{4}; 
            obj.volatilityType =  DataSeriesIn(2).volatilityType;
            
            obj.OutputType = ParametersIn{5}; % Output: Price, LogNormal Vol, or Normal Vol    
            obj.OptionType = ParametersIn{6};                      
                      
            obj.ZCBPRICES = DataSeriesIn(1).values;
            obj.ZCBMaturities = DataSeriesIn(1).axes(1).values;    
            %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2 :: Set-Up data series object to store results :: use existing
            % raw data series object to achieve this
            
            inumberOfDates =  size(DataSeriesIn(1),1); 
                        
           obj.newDataSeriesObject = prursg.Engine.DataSeries_DynamicV3();        
           obj.newDataSeriesObject.dates = DataSeriesIn(1).dates;   
           obj.newDataSeriesObject.values = cell( inumberOfDates, 1);
           obj.newDataSeriesObject.axes(1).values = obj.SwapTenors;
           obj.newDataSeriesObject.axes(2).values= obj.SwaptionMaturities;
           obj.newDataSeriesObject.axes(3).values= obj.SwaptionStrikes;
           obj.newDataSeriesObject.axes(1).title = 'Swap Tenor';
           obj.newDataSeriesObject.axes(2).title = 'Swaption Maturity';
           obj.newDataSeriesObject.axes(3).title = 'Swaption Strikes';           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Add Dynamic properties  
           obj.newDataSeriesObject.addprop('description');
           obj.newDataSeriesObject.addprop('ratetype');
           obj.newDataSeriesObject.addprop('compounding');
           obj.newDataSeriesObject.addprop( 'compoundingfrequency');
           obj.newDataSeriesObject.addprop('daycount') ;
           obj.newDataSeriesObject.addprop('units') ;           
           obj.newDataSeriesObject.addprop('optiontype');          
           obj.newDataSeriesObject.addprop('volatilityType');
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Set property values
           obj.newDataSeriesObject.description = {'derived swaption prices'};
           obj.newDataSeriesObject.ratetype = {'swap'};
           obj.newDataSeriesObject.compounding ={'ann'};
           obj.newDataSeriesObject.compoundingfrequency = {obj.CompoundingFrequency};
           obj.newDataSeriesObject.daycount ={'na'};
           obj.newDataSeriesObject.units ={'absolute'};
           obj.newDataSeriesObject.optiontype ={obj.OptionType};           
           obj.newDataSeriesObject.volatilityType = {obj.OutputType};
                                 
           SWAPRATETENOR = 1/ obj.CompoundingFrequency;
        %%   
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 3 :: Calcualte Data Series Values
           
           newblackpriceObject = prursg.Bootstrap.bsBlackPrice;
                     
               
           if strcmp( lower(obj.OutputType) , lower(obj.volatilityType) )
               % Simply return inputed volatility values values
               obj.newDataSeriesObject.values = DataSeriesIn(2).values ;
           else
               for i= 1 : inumberOfDates
                   obj.newDataSeriesObject.values{i,1} = zeros(size(obj.newDataSeriesObject.axes(1).values,2),size(obj.newDataSeriesObject.axes(2).values,2)); % allocate storage space
                   for j = 1 : size(obj.newDataSeriesObject.axes(1).values,2)
                       SwapTenor = obj.newDataSeriesObject.axes(1).values(j);
                       for k = 1 : size(obj.newDataSeriesObject.axes(2).values,2)
                           SwaptionMaturity = obj.newDataSeriesObject.axes(2).values(k);
                           [swapRate annuityValue]= newobject.EQFORWARDSWAPRATE(obj.ZCBPRICES{1,i},obj.ZCBMaturities, SwaptionMaturity, SwapTenor, SWAPRATETENOR);
                           for l = 1 : size(obj.newDataSeriesObject.axes(3).values,2)
                               SwaptionStrike = max(0,swapRate + obj.newDataSeriesObject.axes(3).values(l));
                               % Get swaption implied volatility :: W expect
                               % a perfect match can be found in the input swaption volatility matrix
                               
                               impliedVolatility =  DataSeriesIn(2).getDataByName(SwapTenor,SwaptionMaturity, (SwaptionStrike -swapRate));
                               
                               switch lower(obj.OutputType)
                                   
                                   case 'normal vol'
                                       value = impliedVolatility*swapRate;
                                   case 'lognormal vol'
                                       value = impliedVolatility/swapRate;
                                   case 'price'
                                       SwaptionStrike = max(0,swapRate + obj.newDataSeriesObject.axes(3).values(l));
                                       
                                       switch lower(obj.volatilityType)
                                           
                                           case 'lognormal vol'
                                               value = newblackpriceObject.BlackPrice( swapRate , SwaptionStrike , SwaptionMaturity , impliedVolatility , ...
                                                   annuityValue, obj.OptionType );
                                           case 'normal vol'
                                               % placeholder for the
                                               % gaussian pricing formulae
                                       end
                                       
                               end
                               
                               obj.newDataSeriesObject.values{i,1}(j,k, l) = value ;
                           end
                       end
                   end
               end
           end
       %%     
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Step4. Return data series object
           results = obj.newDataSeriesObject;
           
       end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods and functions
    
   
    end
    
end

