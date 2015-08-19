%% SWAPTION PRICE
%
% *This class transforms a swaption implied volatility surface into the appropriate
% volatility measure ('blackIV' or 'normalIV') depending on the input volatility 
% and produces a swaption volatility (or swaption price) surface.*
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_SwaptionPrice < prursg.Bootstrap.BaseBootstrapAlgorithm  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% How to use the class  
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method transforms a swaption implied volatility 
% surface into the appropriate volatility measure ('blackIV' or 'normalIV') 
% depending on the input volatility and produce a swaption surface in the form
% of 'spotvol', 'fwdvol' or 'price', with axes corresponding to the maturity,
% tenor and strike of the underlying swaption contracts (we have no values 
% assigned to strike axis at the moment).
%
% Note a swaption price surface under the 'normalIV' volatility measure
% is not available now.
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *|[SwapTenors]|* : A string that lists the length of the swap contracts, $\tau$.
% 
% _Data Type_: string
%
% *|[SwaptionAbsDiffStrikes]|* : Swaption strike rates, which are defined as their 
% absolute difference above the initial forward swap rates.
%
% _Data Type_: string
%
% *|[compoundingfrequency]|* : The annual frequency, $f$, at which 
% the underlying swap contract is settled.
%
% _Data Type_: double
%
% *|[swappaymentfrequency]|* : frequency at which the floating leg is paid
%
% _Data Type_: double
%
% *|[volatility_measure]|* : Specifies the volatility measure, 'normalIV' or 'blackIV'
%
% _Data Type_: string
%
% *|[SwapIVOptionType]|* : Specifies whether the swaption is a 'call' or a 'put'.
% For a call swaption the buyer has the option to receive the fixed rate
% and pay the floating rate. For a put option the buyer has the option to
% receive the floating rate and pay the fixed rate.
%
% _Data Type_: string
%
% *|[SwapIVOutputType]|* : Specifies the output type, 'spotvol', 'fwdvol' or 'price'.
%
% _Data Type_: string
%
% *|[Methods]|* - Used to store multiple methods contain with method
%
% _Data Type_: string
%
% *|[newDataSeriesObject]|* : A new data series object setup to store 
% results.
%
% _Data Type_: data series
%
% *|[outputfreq]|* : A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string
%
% *|[startterm]|* - defines the start term of the ouput yield curve
%
% _Data Type_: double
% 
% *|[endterm]|* - defines the end term of the ouput yield curve
%
% _Data Type_: double 
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 properties              

    SwapTenors
    SwaptionAbsDiffStrikes
    compoundingfrequency 
    swappaymentfrequency       
    volatility_measure
    SwapIVOptionType
    SwapIVOutputType
    
    Methods 
    newDataSeriesObject

    % The properties outputfreq and endterm have been included to allow
    % us to run the class as an independent BootStrap method and not
    % simply a utlity class of bootstrap_RawSwapIVtoSwapIV
    outputfreq ;
    ouputfrequencyprofile;
    startterm;
    endterm;  

 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% List of Methods
% The class introduces one new method:
%
% *|1)[Bootstrap()]|* : Function transforms a swaption implied volatility 
% surface into the appropriate volatility measure ('blackIV' or 'normalIV')
% depending on the input volatility and produce a volatility (or price) surface
% as required.
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 methods 
    % Constructor 
    function obj = bootstrap_SwaptionPrice()
        
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
% Function transforms a swaption implied volatility surface into the appropriate
% volatility measure ('normalIV' or 'blackIV') depending on the input
% volatility, and produces a swaption surface of 'spotvol', 'fwdvol' or 'price'
% depending on the output method (currently price is only available under 
% volatility measure 'blackIV').
%
% *_Inputs_*
%
% *|[DataSeriesIn]|* -  two Data Series, one is swaption implied volatility
% surface, the other is normal yield curve
% 
% _Data Type_: one 2-dim array, one 1-dim array
% 
% *_Outputs_*
%
% A swaption surface of implied volatilities, or swaption prices, with axes 
% corresponding to the maturity, tenor and strike rates of the underlying swap contracts.
%
% *_Calculations_*
%
% STEP 0: Set-up the problem. 
% 1) Take a local copy of the data series. 
% 2) Sort data series to break reference/link problems.
% 3) Convert units to 'absolute' value.
%
% STEP 1: Convert comma separated data (e.g. CSV strings) into arrays
%
% STEP 2: Check Data axis values and modify the input data-series to contain 
% only the requested terms and tenors using linear interpolation
%
% STEP 3: Set-Up data series object to store results
% 
% STEP 4: This is the main calculation step
%
% First, equilibrium forward swap rates and annuity factors are calculated
% by calling function |[EQFORWARDSWAPRATE()]| (see class |[bootstrap_ZCBtoSwapRate]| 
% for details).
%
% Transform into the appropriate volatility measure, either 'Normal' or 'Black'
% volatility depending on the input volatility. 
% If 'normalIV', multiply implied volatility by forward swap rate; 
% If 'blackIV', divide implied volatility by the forward swap rate.
%
% If the chosen output type is 'price' then swaption prices are calculated
% by calling function |[BlackPrice()]| (see bsBlackPrice documentation for
% details).
%
% STEP 5: Return data series object
%
%%
%MATLAB Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function results = Bootstrap(obj,DataSeriesIn)
    
 %%%% STEP 0: Data Set-up - Clone, Sort, Scale %%%%  
    Methodindices = find(obj.SwapIVOutputType== '_');
    
    obj.Methods = { obj.SwapIVOutputType(1 : Methodindices(1) -1), ...
      obj.SwapIVOutputType((Methodindices(1)+1) : Methodindices(2) -1), ...
      obj.SwapIVOutputType((Methodindices(2)+1) : end)};
    
    % property swappaymentfrequency to this class
    obj.compoundingfrequency = obj.swappaymentfrequency;
    
    %%%% STEP 0.1: Count Data-Series & Dates
    inumOfDataSeries = size(DataSeriesIn,2);
    inumberOfDates =  size(DataSeriesIn(1).dates,1);
    
    %%%% STEP 0.2: Clone & Sort Data-Series to break reference/link problems
    newSortDataSeries=Bootstrap.BsSort();
    sDataSeriesIn = newSortDataSeries.SortDataSeries...
        (DataSeriesIn(1).Clone);
    for i =2 : inumOfDataSeries
        sDataSeriesIn = [sDataSeriesIn ...
            newSortDataSeries.SortDataSeries(DataSeriesIn(i).Clone)];
    end
 
    %%%% STEP 0.3: Adjust in accordance with specified units
    for j=1:inumOfDataSeries
        if strcmp(lower(sDataSeriesIn(j).units) , 'percent')
            for i=1:inumberOfDates
                sDataSeriesIn(j).values{i,1} = ...
                    sDataSeriesIn(j).values{i,1} ./ 100;
            end
            % Update data-series property
            sDataSeriesIn(j).units ='absolute';
        end
    end
    
 %%%% STEP 1: Enter comma separated data into arrays %%%%
    ZCBtoSwapRateObject = Bootstrap.bootstrap_ZCBtoSwapRate;
    
     % If we have a string then we expect to have a CSV
    if ischar(obj.SwapTenors)
        obj.SwapTenors = ZCBtoSwapRateObject.createArrayfromCSVstring...
            (obj.SwapTenors);
    end   
    
    if ischar(obj.SwaptionAbsDiffStrikes)
        obj.SwaptionAbsDiffStrikes = ZCBtoSwapRateObject. ...
            createArrayfromCSVstring (obj.SwaptionAbsDiffStrikes);
    end
    
    obj.volatility_measure =  sDataSeriesIn(1).volatility_measure;
     
    if ischar(obj.outputfreq) 
        % we also use this variable to define the required option maturities
        obj.ouputfrequencyprofile = Bootstrap.Bsfrequencyprofile ...
            (obj.outputfreq, obj.endterm).AdjustedIntervalArray';
    end
    
 %%%% STEP 2: Check Data axis values and modify the input data-series to 
 %%%% contain only the requested terms and tenors using linear interpolation %%%%
    
    newLinearInterp =  Bootstrap.bsLinearInterpolation();
    % Allocate storage space
    VolatilitySurface= cell(inumberOfDates,1);
    
    for i = 1 : inumberOfDates
        
        if strcmp(sDataSeriesIn(1).axes(1).title, 'Tenor') && ...
                strcmp(sDataSeriesIn(1).axes(2).title, 'Term')
            
            OptionTenor = cell2mat(sDataSeriesIn(1).axes(1).values);
            OptionMaturities = cell2mat(sDataSeriesIn(1).axes(2).values);
            VolatilitySurface{i,1}= sDataSeriesIn(1).values{i,1}';
            
        elseif strcmp(DataSeriesIn(1).axes(1).title, 'Term') && ...
                strcmp(DataSeriesIn(1).axes(2).title, 'Tenor')
            
            OptionTenor = cell2mat(sDataSeriesIn(1).axes(2).values);
            OptionMaturities = cell2mat(sDataSeriesIn(1).axes(1).values);
            VolatilitySurface{i,1} = sDataSeriesIn(1).values{i,1};
            
        end
        VolatilitySurface{i,1} =newLinearInterp.BiLinearMatrix(...
            obj.ouputfrequencyprofile, obj.SwapTenors, OptionMaturities,...
            OptionTenor, VolatilitySurface{i,1}, 'true');
        sDataSeriesIn(1).values{i,1} = VolatilitySurface{i,1};
    end
    
    sDataSeriesIn(1).axes(1).values = num2cell(OptionMaturities);
    sDataSeriesIn(1).axes(2).values = num2cell(OptionTenor);
    
    
 %%%% STEP 3: Set-Up data series object to store results %%%%   
    % Use existing raw data series object to achieve this    
    obj.newDataSeriesObject = sDataSeriesIn(1).Clone;
    obj.newDataSeriesObject.axis1_scale ='years';
    obj.newDataSeriesObject.axis2_scale ='years';
    
    % Add third axis if necessary to incorporate strikes
    obj.newDataSeriesObject.volatility_measure =  obj.Methods{2};
    obj.newDataSeriesObject.volatility_type =  obj.Methods{3};
    
    SWAPRATETENOR = (1/ obj.compoundingfrequency);

    
 %%%% STEP 4: Calculate Data Series Values %%%%    
    newblackpriceObject = Bootstrap.bsBlackPrice;
    ZCBMaturities = cell2mat(sDataSeriesIn(2).axes(1).values);
    
    
    if strcmp(lower(obj.Methods{2}),lower(obj.volatility_measure)) && ...
            ~strcmp(lower(obj.Methods{3}), 'price')
        % Simply return inputted volatility values
        % obj.newDataSeriesObject.values = sDataSeriesIn(1).values ;
    else
        for i= 1 : inumberOfDates
            obj.newDataSeriesObject.values{i,1} = ...
                zeros(size(obj.newDataSeriesObject.axes(1).values,2)...
                ,size(obj.newDataSeriesObject.axes(2).values,2));
            for j = 1 : size(obj.newDataSeriesObject.axes(2).values,2)
                SwapTenor = cell2mat(obj.newDataSeriesObject.axes(2).values(j));
                for k = 1 : size(obj.newDataSeriesObject.axes(1).values,2)
                    SwaptionMaturity = cell2mat(obj.newDataSeriesObject...
                        .axes(1).values(k));
                    ZCBPRICES = sDataSeriesIn(2).values{i,1};
                    
                    [swapRate annuityValue]= ...
                        ZCBtoSwapRateObject.EQFORWARDSWAPRATE(ZCBPRICES...
                        ,ZCBMaturities, SwaptionMaturity,...
                        SwapTenor, SWAPRATETENOR);
                    
                    for l = 1 : size(obj.SwaptionAbsDiffStrikes,2)
                        
                        SwaptionStrike = max(0,swapRate +...
                            obj.SwaptionAbsDiffStrikes(l));
                        
                        % Get swaption implied volatility
                        % This code should be reinstated if there
                        % becomes a requirement to produce a
                        % volatility cube
                        impliedVolatility =  VolatilitySurface{i,1}(k,j);
                        
                        if ~swapRate == 0
                            switch lower(obj.Methods{2})
                                
                                case 'normaliv'
                                    % Note - For a Generality strike level 
                                    % we would/should use the
                                    % SABR approximation in order to
                                    % capture the strike effect between
                                    % a Black and Normal IV    
                                    value = impliedVolatility * swapRate;
                                    
                                    switch lower(obj.Methods{3})
                                        case 'price'
                                            % placeholder for the
                                            % gaussian pricing formulae
                                            value = -0.3; % Value used for error handling purposes
                                    end
   
                                case 'blackiv'
                                    value = impliedVolatility/swapRate;
                                    
                                    switch lower(obj.Methods{3})  
                                        case 'price'
                                            value = newblackpriceObject...
                                                .BlackPrice( swapRate ,...
                                                SwaptionStrike , ...
                                                SwaptionMaturity ,...
                                                impliedVolatility , ...
                                                annuityValue,...
                                                obj.SwapIVOptionType );
                                    end
                            end
                        else
                            value = -0.000001;
                        end
                        
                        % This code should be reinstated if there
                        % becomes a requirement to produce a
                        % volatility cube
                        obj.newDataSeriesObject.values{i,1}(k,j) = value;
                    end
                end
            end
        end
    end

    
 %%%% STEP 5. Return data series object %%%%   
    results = obj.newDataSeriesObject;
      
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 end   
end

