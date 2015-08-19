classdef bootstrap_RawIYCtoZCB < prursg.Bootstrap.BaseBootstrapAlgorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 01/03/2012 Graeme Lawson	% 
    % This class extrapolates and interpolates raw market inflation yield curve data
    % to produce an inflation Zero Coupon Bond (ZCB) yield curve
    
    properties
        method
		% Parameters used to control interpolation/extrapolation method
        outputfreq
        ltfwd %longTermFwdRate
        llp % lastLiquidPoint
        decayrate
        startterm %outputStartTerm
        endterm %outputEndTerm		
		       
        stfwdInf % ShortInflation
        ltfwdInf % Long term forward inflation assumption       
        ShortInflationDuration
        
        newDataSeriesObject
        Methods % Used to store multiple methods contain with method
        % local object validation parameters
        minValidRate = -0.05;
        MaxValidRate = 5;
        
    end
    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    function obj = bootstrap_RawIYCtoZCB ()
		obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
    end                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
    function results = Bootstrap(obj,DataSeriesIn)
		 
        %% STEP 0. Take a Clone of the original data and sort
        % Data Series One is the raw inflation date
        % Data Series One is optional and contains short inflation rates
        numOfDataSeries = size(DataSeriesIn,2);
        inumberOfDates =  size(DataSeriesIn(1).dates,1);
          
        newSortDataSeries=Bootstrap.BsSort();  
           
            obj.newDataSeriesObject = newSortDataSeries.SortDataSeries(DataSeriesIn(1).Clone);
            for i =2 : numOfDataSeries
                 obj.newDataSeriesObject = [obj.newDataSeriesObject newSortDataSeries.SortDataSeries(DataSeriesIn(i).Clone)];                
            end
        
        %% STEP 2 . Apply First Method    
        % Extract Method Names        
           Methodindices = find(obj.method == '_');
           obj.Methods = { obj.method(1 : Methodindices(1) -1) , ... 
                             obj.method( (Methodindices(1)+1) : end)}; 
        
       switch   lower( obj.Methods{1})              
                         
         case  'shortinflation'
           % This method is used to control the short end of the inflation
           % curve
           obj.newDataSeriesObject(1).axes(1).values = [ {obj.ShortInflationDuration} obj.newDataSeriesObject(1).axes(1).values];
           
           % First Insert a new axis value for the short maturity security
           
           obj.newDataSeriesObject
           
             for i =1 : inumberOfDates
                
                     if strcmp(obj.newDataSeriesObject(1).units, 'percent')
                         obj.stfwdInf = obj.stfwdInf * 100;
                     end
                 
                 if  numOfDataSeries  == 2;
                     % Use Historic Data-Series of short-term inflation
                     % rates
                     if strcmp(obj.newDataSeriesObject(2).units, 'absolute')
                      shortinflation = obj.newDataSeriesObject(2).values{i,1}*100;
                     end
                 else
                      shortinflation =  obj.stfwdInf;
                 end    
                 
                 switch   lower( obj.newDataSeriesObject(1).ratetype) 
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
                      newDatSeriesValue = exp( - shortinflation*obj.ShortInflationDuration/100)*100;
                 end       
                 
                  % Append new data element to the raw inflation data
                 
                   obj.newDataSeriesObject(1).values{i} = [ newDatSeriesValue obj.newDataSeriesObject(1).values{i}];
                  
             end
             
       end     
         
       %% STEP 3 . Apply Main Bootstrapping Method :: Interpolates and extrapolates
		% 
		% the raw data which may have been supplemented by the short
		% inflation assumption
                         
        switch lower(obj.Methods{2}) % Change strings to lower case 
            case 'wilsonsmith'
				ParametersIn{1} = obj.outputfreq;
				ParametersIn = [ParametersIn obj.ltfwdInf obj.llp obj.decayrate obj.startterm obj.endterm obj.method];
                % Create a new Wilson Smith Bootstap Object 
                %newWilsoSmith = prursg.Bootstrap.BsWilsonSmith_RiskCare(DataSeriesIn, ParametersIn);
                newWilsoSmith = Bootstrap.BsWilsonSmith(DataSeriesIn, ParametersIn);
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
	
	
	function Calibrate(obj, inDataSeries)
		
    end
	
	
    
    end
    
end