classdef BsWilsonSmith_RiskCare < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Description
    % 05/10/2011 Graeme Lawson :: Method interpolates and extrapolates 
    % par (swap) rates and zero coupon bond prices
    
    
    properties   
        
        % Parameters used to control interpolation/extrapolation method
        outputfreq
        longTermFwdRate
        lastLiquidPoint
        decayrate
        outputStartTerm
        outputEndTerm 
        
        % Raw Data related Parameters & Arrays
        ratetype
        compounding
        compoundingfrequency
        daycount
        units
        
        % Data Processe Items
        ValidRawDataSeries
        CashflowprofileSeries = [];
        ouputfrequencyprofile
        
        % Solution of Wilson Smith Linear System
        WilsonSmithParameters = [] ;
        
        % local object validation parameters
        minValidRate = -0.05;
        MaxValidRate = 5;
        
        % Set-Up data series object to store results
        newDataSeriesObject
        
     end
        
    methods
        
        
        function obj = BsWilsonSmith_RiskCare(DataSeriesIn, ParametersIn)
            % Constructor
            obj.outputfreq = ParametersIn{1};
            obj.longTermFwdRate = log(1+ParametersIn{2}); % Inputted long term forward rate is assumed to be annually copounded, thererfore we transform to a continuously compounded version.
            obj.lastLiquidPoint = ParametersIn{3};
            obj.decayrate = ParametersIn{4};
            obj.outputStartTerm = ParametersIn{5};
            obj.outputEndTerm = ParametersIn{6};
            obj.ValidRawDataSeries = obj.Valid_RawDataSeries(DataSeriesIn);
            %obj.ouputfrequencyprofile = prursg.Bootstrap.Bsfrequencyprofile(obj.outputfreq, obj.outputEndTerm).AdjustedIntervalArray;
            obj.ouputfrequencyprofile = Bootstrap.Bsfrequencyprofile(obj.outputfreq, obj.outputEndTerm).AdjustedIntervalArray;
            
            obj.ratetype = DataSeriesIn.ratetype;
            obj.compounding=DataSeriesIn.compounding ;
            obj.compoundingfrequency =DataSeriesIn.compoundingfrequency ;
            obj.daycount= DataSeriesIn.daycount ;
            obj.units = DataSeriesIn.units; 
            % WilsonSmithParameters Stores the parameters of each  Wilson-Smith fit
            obj.WilsonSmithParameters = cell(size(obj.ValidRawDataSeries,1),1);  % Allocate storage space
            % CashflowprofileSeries  stores the asset values, cash flow  maturity times, & cash flow values           
            obj.CashflowprofileSeries = cell(size(obj.ValidRawDataSeries,1),3);  % Allocate storage space 
            
            
            % Set-Up data series object to store results :: use existing
            % raw data series object to achieve this
           %obj.newDataSeriesObject = DataSeriesIn;  
		   obj.newDataSeriesObject = DataSeriesIn.Clone();
           
           %obj.newDataSeriesObject.axes(1).values= obj.ouputfrequencyprofile';
           obj.newDataSeriesObject.axes.values= num2cell(obj.ouputfrequencyprofile)';
           %inumberOfDates =  size(obj.newDataSeriesObject,1); 
           inumberOfDates =  size(obj.newDataSeriesObject.dates,1); 
          
               for i= 1 : inumberOfDates
                   obj.newDataSeriesObject.values{i,1} = zeros(size(obj.ouputfrequencyprofile'));
               end 
           
           obj.newDataSeriesObject.description = {'derived zcb prices using wilson-smith method'};
           obj.newDataSeriesObject.ratetype = {'zcb'};
           obj.newDataSeriesObject.compounding ={'na'};
           obj.newDataSeriesObject.compoundingfrequency = { 'na'};
           obj.newDataSeriesObject.daycount ={ 'na'};
           obj.newDataSeriesObject.units ={'absolute'};
            
        end
           
        
         function  y = WilsonsSmithZCBPrices(obj)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Description :: Created by Graeme Lawson 07/10/11
               % Step 0 Initilise parameters and vectors 
                inumberOfDates =  size(obj.ValidRawDataSeries,1);  
                inumberOfZCBs = size( obj.ouputfrequencyprofile ,1) ;   
               
                fittedZCBs = cell ( inumberOfDates, 1) ;
                Maturities = obj.ouputfrequencyprofile;                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Step 1 Calculate bond prices for each date               
                
                for i = 1 : inumberOfDates
                    FittedParameters = obj.WilsonSmithParameters {i,1};
                    dblCashflowMaturities = obj.CashflowprofileSeries {i,2} ;
                    dblCashflows = obj.CashflowprofileSeries {i,3};
                    fittedZCBs{i,1} =  WilsonsSmithZCBPriceFunction(obj,Maturities,  FittedParameters, dblCashflowMaturities, ...
                        dblCashflows, obj.decayrate, obj.longTermFwdRate);
                     obj.newDataSeriesObject.values{i,1} = fittedZCBs{i,1}'; %'
                end     
                      
                 y =obj.newDataSeriesObject ;           
         end
         
         function  ZCBPrice = WilsonsSmithZCBPriceFunction(obj,MaturityTime,  FittedParameters, dblCashflowMaturities, ...
                                                          dblCashflows, decayrate, longTermFwdRate)
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             % Description :: Created by Graeme Lawson 06/10/11
             % Constructs the Response and Design Array Matrices of the
             % Wilson Smith linear Kernal (basis) function method
                 
                iNumberofMaturities =size(MaturityTime ,1) ;
                iNumberOfAssets= size(dblCashflowMaturities ,1); % This is equal to the number of kernal functions due to the dsepcification of the problem
                ZCBPrice = zeros(iNumberofMaturities,1);
                
                 
                 for j =1 : iNumberofMaturities   
                     sum = 0 ;
                     for i =1 : iNumberOfAssets                    
                          KernalFunctionValue = obj.WilsonsKernalFunction(MaturityTime(j,1), dblCashflowMaturities{i,1}, dblCashflows{i,1}, decayrate, longTermFwdRate);
                         sum = sum + FittedParameters(i, 1) *KernalFunctionValue ;
                     end
                       ZCBPrice(j,1)= exp(-longTermFwdRate*MaturityTime(j,1)) + sum ;                     
                      
                 end 
                              
         end
        
        function y = FitWilsonSmithParameters(obj)            
                      
            %longTermFwdRate long forward rate
            %decayRate the reversion param
            %InputRawDataSeries a single simulated spot curve up to LLP
            %lastLiquidPoint is assumed to be annual
            %outputfrequency is the number time points per annum
            %output len is the length of the extrapolated yield curve
          
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
           % Step 0 :: Initialise problem
            
           y  = []; 
           iNumberofDates = size(obj.ValidRawDataSeries,1);                  
           
           
           
           for ii = 1 :  iNumberofDates
            
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             % Step 1 :: for a given date calculate the asset price and cashflows for
             % a given yield type
             
               iNumberofAssetPrices =size(obj.ValidRawDataSeries{ii,1}, 2) ;  
               dblRawAssetValuesOrRates =obj.ValidRawDataSeries{ii,2}' ;
               %dblRawAssetMaturities = obj.ValidRawDataSeries{ii,1}';
               dblRawAssetMaturities = cell2mat(obj.ValidRawDataSeries{ii,1})';
               
               % The function assetcashflowprofiles expects to receive
               % arrays for obj.ratetype, obj.compounding & obj.compoundingfrequency 
               % This set-up is in keeping with a more flexible XML schema
               % and multi different types of input assets to be developed
               % in later iterations
               
               %size( obj.ratetype{1, 1} ,1) == 1
               if   size( obj.ratetype ,1) == 1
                   %ratetype = repmat ( obj.ratetype{1, 1} ,iNumberofAssetPrices,1 );
                   ratetype1 = repmat ( obj.ratetype(1,:) ,iNumberofAssetPrices,1 );
                   %compounding = repmat ( obj.compounding{1, 1} ,iNumberofAssetPrices,1 );
                   compounding1 = repmat ( obj.compounding(1,:) ,iNumberofAssetPrices,1 );
                   %compoundingfrequency = repmat ( obj.compoundingfrequency{1, 1} ,iNumberofAssetPrices,1 );
                   compoundingfrequency1 = repmat ( obj.compoundingfrequency(1,:) ,iNumberofAssetPrices,1 );
                   %units = repmat ( obj.units{1, 1} ,iNumberofAssetPrices,1 );
                   units1 = repmat ( obj.units(1,:) ,iNumberofAssetPrices,1 );
                else
                   %ratetype =  obj.ratetype{1, 1};
                   ratetype1 =  obj.ratetype;
                   %compounding = obj.compounding{1, 1};
                   compounding1 = obj.compounding;
                   %compoundingfrequency = obj.compoundingfrequency{1, 1};
                   compoundingfrequency1 = obj.compoundingfrequency;
                   %units = obj.units{1, 1};
                   units1 = obj.units;
                end 
               
               %Cashflowprofile = prursg.Bootstrap.bsAssetCashflowProfile();
               Cashflowprofile = Bootstrap.bsAssetCashflowProfile();
               [dblAssetPrices,dblCashflowMaturities, dblCashflows] =  Cashflowprofile.assetcashflowprofiles(dblRawAssetValuesOrRates, dblRawAssetMaturities, ratetype1 ,....
                    compounding1, compoundingfrequency1, units1) ;               
               %[dblAssetPrices,dblCashflowMaturities, dblCashflows] =  Cashflowprofile.assetcashflowprofiles(dblRawAssetValuesOrRates, str2double(dblRawAssetMaturities), ratetype1 ,....
               %     compounding1, compoundingfrequency1, units1);
                
               obj.CashflowprofileSeries {ii,1} = dblAssetPrices;
               obj.CashflowprofileSeries {ii,2} = dblCashflowMaturities;
               obj.CashflowprofileSeries {ii,3} = dblCashflows;
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2a ::  We now proceed to solve the linear system of equations which is 
            % of the standard form y = Ax such that we find the solution
            % vector x satisfying the equation x = A^(-1)y
            % Using standard terminlogy from probability and statitics A
            % in the above equation with be referreed to as the design
            % matrix. y will be referred to as the responsevector and x the
            % parameter vector                       
            
            [DesignMatrix,responsevector] = obj.WilsonsMatrixFunction (dblAssetPrices, dblCashflowMaturities, ... 
                                                                         dblCashflows, obj.decayrate, obj.longTermFwdRate);
             
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Step 2b Solve the linear system to obtian the parameters of the
            % kernal (basis) functions
            % Store Parameters for each date in the data series object
            obj.WilsonSmithParameters{ii,1} = (DesignMatrix^-1) *responsevector;   
                
           end
        
        end
        
       
        
        function [DesignMatrix, responsevector]  = WilsonsMatrixFunction(obj,dblAssetPrices, dblCashflowMaturities, ...
                                                                                 dblCashflows, decayrate, longTermFwdRate)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Description :: Created by Graeme Lawson 06/10/11
               % Constructs the Response and Design Array Matrices of the
               % Wilson Smith linear Kernal (basis) function method
                              
              iNumberOfAssets= size(dblCashflowMaturities ,1);  
                
               DesignMatrix = zeros( iNumberOfAssets , iNumberOfAssets); 
               responsevector = zeros( iNumberOfAssets , 1); 
               
               for k =1 : iNumberOfAssets   
                   
                   iNumberOfCashflows = size(dblCashflowMaturities{k,1},2); 
                   % for i =1 : iNumberOfAssets 
                   for i =k : iNumberOfAssets    
                       sum = 0;
                         for j = 1 : iNumberOfCashflows                                
                          assetcashflow = dblCashflows{k, 1}(j);
                          assetCashflowTime = dblCashflowMaturities{k,1}(j) ;
                         sum =sum +  assetcashflow * obj.WilsonsKernalFunction(assetCashflowTime, dblCashflowMaturities{i,1}, dblCashflows{i,1}, decayrate, longTermFwdRate) ;
                         end 
                         DesignMatrix(k, i) = sum;
                         DesignMatrix(i, k) = DesignMatrix(k, i) ;
                   end
               end              
                        
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Calculate response Matrix               
               for k =1 : iNumberOfAssets 
                    iNumberOfCashflows = size(dblCashflowMaturities{k,1},2); 
                    sum = 0;
                    for j = 1 : iNumberOfCashflows                                
                          assetcashflow = dblCashflows{k,1}(j);
                          assetCashflowTime = dblCashflowMaturities{k,1}(j) ;               
                       sum  = sum +assetcashflow* exp( - longTermFwdRate * assetCashflowTime);     
                    end
                    responsevector(k, 1) = dblAssetPrices(k,1) - sum;
               end
                              
           end
           
            function wk = WilsonsKernalFunction(obj,MaturityTime, dblCashflowMaturities, dblCashflows, decayrate, longTermFwdRate)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Description :: Created by Graeme Lawson 06/10/11
               
               iNumberOfCashflows = size( dblCashflowMaturities,2);
               sum = 0 ;
               
               for j =1 : iNumberOfCashflows
                                   cashflow = dblCashflows(1, j);
                                   CashflowTime = dblCashflowMaturities(1,j) ;
                                   sum = sum +  cashflow * obj.WilsonsFunction(MaturityTime, CashflowTime, decayrate, longTermFwdRate);
                end
                
                wk =  sum ;
                    
           end
          
           
           function w = WilsonsFunction(obj,MaturityTime1, MaturityTime2, decayrate, longTermFwdRate)
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Description :: Created by Graeme Lawson 06/10/11
               % This is function is referred to as the wilson function in the
               % Deliotte Technical Literature and has been designed to
               % minimize a standard smoothing functional subject to the
               % constrainst that it reproduces the market prices
               % Note that wilson function is symmetric in the time arguments AssetMaturityTime, AssetCashflowMaturityTime
               % which implies that these two order in which they are
               % inputted does not matter
                    w = exp(-longTermFwdRate* (MaturityTime1+ MaturityTime2)) * (decayrate * min(MaturityTime1, MaturityTime2) ...
                        - exp(-decayrate * max(MaturityTime1,MaturityTime2)) * sinh(decayrate * min(MaturityTime1,MaturityTime2)));
           end
           
           
           function y = Valid_RawDataSeries(obj, DataSeriesIn)
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
				% Description :: Function collects the valid data fo object to
				% contain only points that are valid for the purposes of
				% interpolation and extrapolation
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				% Step 1 Create a cell array of valid matrurities and rate values
				% for each date 
				y = cell(size(DataSeriesIn.dates, 1), 2);
				for j = 1 : size(DataSeriesIn.dates, 1)
					k =0;
					for i =1 : size(DataSeriesIn.axes(1,1).values, 2)
						if DataSeriesIn.axes(1).values{i} <= obj.lastLiquidPoint
							if isnumeric(DataSeriesIn.values{j,1}(i)) && (DataSeriesIn.values{j,1}(i) >=obj.minValidRate) ... 
								&& (DataSeriesIn.values{j,1}(i) <= obj.MaxValidRate)
									k= k+1;
									Maturities(k) =DataSeriesIn.axes(1).values(i);
									Rates(k) =DataSeriesIn.values{j,1}(1,i);                          
							end
						end
					end       
					y{j, 1}  = Maturities;
					y{j, 2}  = Rates;
				end
			end
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % End Of Methods
    end
end  