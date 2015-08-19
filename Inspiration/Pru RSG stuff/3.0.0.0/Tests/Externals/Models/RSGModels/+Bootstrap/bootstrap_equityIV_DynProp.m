classdef bootstrap_equityIV_DynProp < prursg.Bootstrap.BaseBootstrapAlgorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 25/11/2011 Graeme Lawson :: Substantial Rewrite 10/02/2012
    % This class extrapolates and interpolates a raw market equity 
    % volatility surface    
    
    properties
        
        newDataSeriesObject = []; 
        Methods
        
        outputfreq
        ouputfrequencyprofile
        % Strike Moneyness Levels
        Moneyness
         % Equity Return Parameters
        LTEquityAMean
        LTEquityAStdDev
        ExpDecayFactor
        % Liquidity Points
        llpMaturity
        llpminStrike
        llpmaxStrike
         % Interet Rate Parameters
        IRMeanReversionSpeed
        IRVolatility        
        Equity_IR_Correlation
        % Equity IV method
        EquityIVMethod
        StrikeMethod
       % Proxy Methods
        ProxyMethod
        ProxyCurrency        
        ProxyParam1
        ProxyParam2
        % Start & End Points
        startterm
        endterm                                        
    end
    
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_equityIV_DynProp()
         obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
       end                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Other Methods
    
      function results = Bootstrap(obj,DataSeriesIn)                    
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %% Step 0  :: Set-Up Problem 
          % First Data Series is assumed to be the volatility surface and the second is assumed to be the forward index prices         
          % Dataseries objects are reference type objects, therefore we
          % will take a local copy 
          
           numOfDataSeries = size(DataSeriesIn,2);
           inumberOfDates =  size(DataSeriesIn(1).dates,1);

           obj.ouputfrequencyprofile = Bootstrap.Bsfrequencyprofile(obj.outputfreq, obj.endterm).AdjustedIntervalArray';     
           newSortDataSeries=Bootstrap.BsSort();  
           
            obj.newDataSeriesObject = newSortDataSeries.SortDataSeries(DataSeriesIn(1).Clone);
            for i =2 : numOfDataSeries
                 obj.newDataSeriesObject = [obj.newDataSeriesObject newSortDataSeries.SortDataSeries(DataSeriesIn(i).Clone)];                
            end
                    
           
         %% Step 1 :: Updating Properties  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              
                   
                 % Note we are anticpating that
                 % obj.newDataSeriesObject(1).units = 'percent' as we expect DataSeriesIn(1).units = 'percent'
                  
                 if strcmp(obj.newDataSeriesObject(1).units , DataSeriesIn(1).units)
                 else
                     err = MException('Opps:OhDear' ,'Dynm Property value is not as expected');
                     throw(err)
                 end    
                 
                 
                 obj.newDataSeriesObject(1).units ='absolute';               
                 
                  
          %% Step 9 :: Asign DataSeries Object to Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
                  results =obj.newDataSeriesObject(1);
                
    
      end
      
      function Calibrate(obj, DataSeriesIn, ParametersIn)
		
      end
    end

end

