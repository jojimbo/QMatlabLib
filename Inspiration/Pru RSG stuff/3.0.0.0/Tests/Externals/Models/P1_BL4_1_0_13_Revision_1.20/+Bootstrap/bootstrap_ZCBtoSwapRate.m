classdef bootstrap_ZCBtoSwapRate < prursg.Bootstrap.BaseBootstrapAlgorithm
    % 12/10/11 Created by Graeme Lawson 
    % the class takes as input a data series object containinga set of
    % Zeroc copon Bonds and ouputs a two dimesional data series object
    % of equilibrium swap (par) rates with axes corresponding to maturity
    % and tenor of swap contract
    
    properties
        
        outputfreq ; 
        compoundingfrequency;  
        swaptenors ;
        
        ZCBPRICES ;
        ZCBMaturities ;          
        SwaptionMaturities
              
         % Set-Up data series object to store results
        newDataSeriesObject
        % TimeTolerance within one businss day
        TimeTolerance = 1/250; 
        
    end
    
    methods
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
        function obj = bootstrap_ZCBtoSwapRate()
                 obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm(); 
        end
    
       function results = Bootstrap(obj,DataSeriesIn)
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 1. Sort and clone ZCB data     
            
            newSortDataSeries=Bootstrap.BsSort(); 
            
            obj.newDataSeriesObject =newSortDataSeries.SortDataSeries(DataSeriesIn(1).Clone);  
              
             inumberOfDates =  size(DataSeriesIn(1).dates,1);             
             
            obj.ZCBPRICES = obj.newDataSeriesObject.values;
            
            obj.ZCBMaturities  =cell2mat(obj.newDataSeriesObject.axes(1).values);
            
            swaptenors = obj.createArrayfromCSVstring(obj.swaptenors);        
            % obj.SwaptionMaturities = obj.createArrayfromCSVstring(obj.SwaptionMaturities); 
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2. Get OutPutFreqProfile            
            
             maxTerm = obj.newDataSeriesObject.axes(1).values{1, end}; 
             BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile(obj.outputfreq,maxTerm);
             outputfreqProfile = BsfrequencyprofileObject.AdjustedIntervalArray;            
             outputfreqProfile = [ 0 ; outputfreqProfile] ; % The Inclusion of zero gives us the initial par rates
             
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 3 :: Set-Up data series object to store results :: use existing
            % raw data series object to achieve this
            
            obj.newDataSeriesObject.axes(1).values= num2cell(outputfreqProfile');
            obj.newDataSeriesObject.axes(2).values = num2cell(swaptenors);
            
            SWAPRATETENOR = 1/ obj.compoundingfrequency;
            NumOFSwapTenors =size(obj.newDataSeriesObject.axes(2).values,2);
            NumOFSwaptionMaturity =size(obj.newDataSeriesObject.axes(1).values,2);
            Results = zeros(NumOFSwapTenors,NumOFSwaptionMaturity );  % allocate storage space
          
               for i= 1 : inumberOfDates                  
                   for j = 1 : NumOFSwapTenors
                       SwapTenor = obj.newDataSeriesObject.axes(2).values{j};
                       for k = 1 : NumOFSwaptionMaturity 
                           SwaptionMaturity = obj.newDataSeriesObject.axes(1).values{k};
                           [SwapRate AnnuityFactor] = obj.EQFORWARDSWAPRATE(obj.ZCBPRICES{i},obj.ZCBMaturities, SwaptionMaturity, SwapTenor, SWAPRATETENOR);
                           Results(j,k) = SwapRate;
                       end
                   end  
                    
                   obj.newDataSeriesObject.values{i} =Results';
               end 
            
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Step4. Return data series object
           results = obj.newDataSeriesObject;
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
           % Step 5. Update Data-Series Properties
           
           
           obj.newDataSeriesObject.axes(1).title = 'Swaption Maturity';
           obj.newDataSeriesObject.axes(2).title =  'Swap Tenor';
           obj.newDataSeriesObject.description = 'derived (equilibrium) swap rates using bootstrap_ZCBtoSwapRate';
           obj.newDataSeriesObject.source = 'iMDP';
           obj.newDataSeriesObject.ratetype = 'swap';
           obj.newDataSeriesObject.compounding ='ann';
           obj.newDataSeriesObject.compoundingfrequency = num2str(obj.compoundingfrequency);
           obj.newDataSeriesObject.daycount ='na';
           obj.newDataSeriesObject.units ='absolute';
           
       end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods and functions
    
    function y = SwapRateDataSeries(obj)
        
    end     
    
       
    function [SwapRate AnnuityFactor]=EQFORWARDSWAPRATE(obj,ZCBPRICES,ZCBMaturities, SWAPSTART, SWAPDURATION, SWAPRATETENOR)
        % The Funtion Calculates the Equilibrium Foward Swap Rate Based on a set of
        % ZCB Prices
        % The function assumes that ZCB Maturity Values are evenly spaced and
        % further are an integer muliple of the SWAPTENOR
        
        
        
        NumberOfBonds=size(ZCBPRICES,2);
        TenorMaturityRatio = floor(SWAPRATETENOR/ZCBMaturities(1,1));
        
        
       %  assert ( ZCBMaturities( 1, end) > (SWAPSTART + SWAPDURATION), 'Swaption terms are greator than the length of the yield curve')
       
       if ZCBMaturities( 1, end) < (SWAPSTART + SWAPDURATION)
            SwapRate =0;
            AnnuityFactor=0;
            return
        end    
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find Position of the first Bond required to Calculate the Forward
        % Starting annuity factor
        for i = 1:1:NumberOfBonds
            if  (abs(SWAPSTART) < obj.TimeTolerance)
                SWAPSTARTINDEX = 0;
            elseif    (abs(ZCBMaturities(1,i) - SWAPSTART)< obj.TimeTolerance)
                SWAPSTARTINDEX = i;
            end
            
            if abs(ZCBMaturities(1,i) -( SWAPSTART +SWAPDURATION)) < obj.TimeTolerance
                SWAPSENDINDEX = i;
                break % Exit the For Loop
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculate Annuity Factor
        AnnuityFactor = 0;
        for i = SWAPSTARTINDEX +TenorMaturityRatio:TenorMaturityRatio:SWAPSENDINDEX
            AnnuityFactor =AnnuityFactor +SWAPRATETENOR*ZCBPRICES(1,i);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Calculate the equilibrium spot rate
        
        if SWAPSTART == 0
            SwapRate = (1 - ZCBPRICES(SWAPSENDINDEX))/AnnuityFactor;
        else
            SwapRate = (ZCBPRICES(SWAPSTARTINDEX) - ZCBPRICES(SWAPSENDINDEX))/AnnuityFactor;
        end
        %y = [SwapRate AnnuityFactor];
        return
        
        
    end
    
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
                 y(1, length(pos)+1) = str2num(stringParameter(pos(length(pos))+1 :end));
         end
    end    
    
    function [axis1values, axis2values] = createaxisdata (obj, array1, array2)
        
         len1 = size(array1, 2);
         len2 = size(array2, 2);
        
         axis1values = repmat(array1, 1, len2);
         axis2values = zeros(size(axis1values));
       
         for i= 1 : len2
            axis2values((i-1)*len1 +1 : i*len1) = repmat( array2(1,i) ,1, len1);
            
        end     
    
    end
    end
    
end

