%% RAW MARKET SWAPTION IMPLIED VOLATILITY TO SWAPTION IMPLIED VOLATILITY
% 
% *This class transforms raw swaption implied volatility surface into appropriate 
% volatility measure and extrapolates to give a surface with required maturities and tenors*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_RawSwapIVtoSwapIV < prursg.Bootstrap.BaseBootstrapAlgorithm  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% How to use the class  
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method takes raw market swaption implied 
% volatility surface, transforms into the required volatility measure 
% ('normalIV' or 'blackIV') by calling class |[bootstrap_SwaptionPrice]|, 
% and interpolates and extrapolates to give a surface with required maturities and tenors
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *|[outputfreq]|* : A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string
%
% *|[ouputfrequencyprofile]|* - determines the output frequency of the
% DataSeriesObject
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
% *|[SwapTenors]|* : A string that lists the length of the swap contracts, $\tau$.
% 
% _Data Type_: string
%
% *|[SwaptionAbsDiffStrikes]|* : Swaption strike rates, which are defined as their 
% absolute difference above the initial forward swap rates.
%
% _Data Type_: double
%
% *|[llpMaturity]|* : maximum maturity at which option is liquid
%
% _Data Type_: double
%
% *|[llpTenor]|* : maximum maturity at which swap contract is liquid
%
% _Data Type_: double
%
% *|[SwapIVMethod]|* : used to store multiple methods contain within method, 
% e.g. 'normaliv_constant', return normal implied vol and extrapolate constantly
%
% _Data Type_: string
%
% *|[ProxyMethod]|* - method to apply a proxy, e.g. "linear" 
%
% _Data Type_: string
%
% *|[ProxyCurrency]|* - currency to which the proxy method is applied to
%
% _Data Type_: string
%
% *|[ProxyParam1]|* - parameter used in the proxy calculation
%
% _Data Type_: double
%
% *|[ProxyParam2]|* - parameter used in the proxy calculation
%
% _Data Type_: double
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
        
        outputfreq
        ouputfrequencyprofile
        compoundingfrequency
        
        swappaymentfrequency
        SwapTenors
        SwaptionAbsDiffStrikes
        llpMaturity
        llpTenor
        SwapIVMethod
        
        ProxyMethod
        ProxyCurrency
        ProxyParam1
        ProxyParam2
        
        SwapIVOptionType
        SwapIVOutputType
        Methods
        startterm
        endterm
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap ()]|* - Function transforms raw swaption implied volatility
% surface into the appropriate volatility measure ('normalIV' or 'blackIV')
% and extrapolates to give a surface with required maturities and tenors 
%
% *|[Calibrate ()]|* - calibrates parameters which are then used in
% bootstrap methods. We have not created a calibrate method.
%    
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
 methods
   % Constructor  
   function obj =  bootstrap_RawSwapIVtoSwapIV ()
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
% Function takes raw market swaption implied volatility surface, transforms 
% into the required volatility measure ('normalIV' or 'blackIV') by calling 
% class |[bootstrap_SwaptionPrice]|, and interpolates and extrapolates to give
% a surface with required maturities and tenors
%
% *_Inputs_*
%
% *|[DataSeriesIn]|* - two/three data series.     
% DataSeries(1) - raw market swaption implied volatility surface;  
% DataSeries(2) - ZCB prices of the currency we wish to extrapolate;
% DataSeries(3) - (optional) ZCB prices of the proxy currency
% 
% _Data Type_: one 2-dim array, two 1-dim arrays 
% 
% *_Outputs_*
%
% Swaption surface with required volatility measure and required maturities
% and tenors
%
% _Data Type_: 2-dim array
%
% *_Calculation_* 
%
% STEP 0: Set-up the problem
% 1) Take a local copy of the data series. 
% 2) Sort data series to break reference/link problems.
% 3) Convert units to 'absolute' value.
% 4) Convert comma separated data (e.g. CSV strings) into arrays
%
% STEP 1: Truncate data in accordance with the last liquid points
%
% STEP 2: Transform (if necessary) into the appropriate volatility measure 
% (either 'Normal' or 'Black' volatility depending on the input volatility
% data) by calling |[Bootstrap()]| method in class |[bootstrap_SwaptionPrice]| 
% (see SWAPTION PRICE documentaion for details).
% Apply proxy method, e.g. 'linear'.
%
% STEP 3: Extrapolate the volatility surface by calling function
% |[BiLinearMatrix()]| (see class |[bsLinearInterpolation]| for details).
% Update the object properties with user input parameters.
%
% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function results = Bootstrap(obj,DataSeriesIn)

 %%%% STEP 0: Set-Up Problem %%%%
    Methodindices = find(obj.SwapIVOutputType== '_');

    obj.Methods = {obj.SwapIVOutputType(1 : Methodindices(1)-1), ...
        obj.SwapIVOutputType((Methodindices(1)+1) :Methodindices(2)-1), ...
        obj.SwapIVOutputType((Methodindices(2)+1) :end)};

    % property swappaymentfrequency to the class
    obj.compoundingfrequency = obj.swappaymentfrequency;

    %%%% STEP 0.1:  Count Data-Series & Dates
    inumOfDataSeries = size(DataSeriesIn,2);
    inumberOfDates =  size(DataSeriesIn(1).dates,1);

    obj.ouputfrequencyprofile= Bootstrap.Bsfrequencyprofile ...
        (obj.outputfreq, obj.endterm).AdjustedIntervalArray';

    %%%% STEP 0.2:  Clone & Sort Data-Series to break reference/link problems
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

    %%%% STEP 0.4: enter comma separated data into arrays
    newobject = Bootstrap.bootstrap_ZCBtoSwapRate;

    if ischar(obj.SwapTenors)
        % If we have a string then we expect to have a CSV
        obj.SwapTenors = newobject.createArrayfromCSVstring...
            (obj.SwapTenors);
    end

    if ischar(obj.SwaptionAbsDiffStrikes)
        % If we have a string then we expect to have a CSV
        obj.SwaptionAbsDiffStrikes = newobject.createArrayfromCSVstring...
            (obj.SwaptionAbsDiffStrikes);
    end
   
 %%%% STEP 1: Truncate data in acordance with the last liquid points %%%%
    % Note we are re-using the truncation fuctionality in the class 
    % bsEquityForwardVolExtrapolation

    newVolSurfaceObject =Bootstrap.bsEquityForwardVolExtrapolation (...
        0.1,0.1, 'median',0.1,obj.llpMaturity,0, obj.llpTenor,...
        0.1,0.1,0.1);

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

        [VolatilitySurface{i,1},ReducedOptionMaturities,ReducedTenors] =...
            newVolSurfaceObject.RawVolatilitySurfaceAdj ...
            (VolatilitySurface{i,1}, OptionMaturities ,OptionTenor);
        sDataSeriesIn(1).values{i,1} = VolatilitySurface{i,1};
    end

    sDataSeriesIn(1).axes(1).values = num2cell(ReducedOptionMaturities);
    sDataSeriesIn(1).axes(2).values = num2cell(ReducedTenors);


 %%%% STEP 2: Apply proxy method and transform if necessary into the
 %%%% appropriate volatility measure %%%%

    % Note bootstrap_SwaptionPrice is our main calculation class
    newIVObject = Bootstrap.bootstrap_SwaptionPrice();
    newIVObject.SwapTenors = ReducedTenors; % Output Tenors
    newIVObject.outputfreq = [];
    newIVObject.ouputfrequencyprofile = ReducedOptionMaturities; % Output maturities
    newIVObject.SwaptionAbsDiffStrikes = obj.SwaptionAbsDiffStrikes; % Output strikes
    newIVObject.compoundingfrequency = obj.compoundingfrequency;
    newIVObject.swappaymentfrequency = obj.swappaymentfrequency;
    newIVObject.SwapIVOptionType = obj.SwapIVOptionType;

    %%%% STEP 2.1: Transform volatility into either Normal or Black volatility 
       % depending on the input volatility data   
    if  strcmp(lower(obj.SwapIVMethod), 'normaliv_constant') && ...
            strcmp(lower(sDataSeriesIn(1).volatility_measure) , 'blackiv')

        newIVObject.SwapIVOutputType ='forward_normaliv_spotvol';
        % Allocate storage space
        VolatilitySurface = cell(inumberOfDates,1);
        % Calculate Normal Volatility:
        for i = 1 : inumberOfDates
            if ~strcmp(lower(obj.ProxyMethod) , 'none')
                % Note: In this case we intrepret data-series(1) as a proxy 
                % volatility surface and dataseries(3) as s proxy ZCB yield curve
                % We now calculate our normal volatilities
                VolatilitySurface{i,1} = newIVObject.Bootstrap ...
                    ([sDataSeriesIn(1) sDataSeriesIn(3)]).values{i,1};
            else
                VolatilitySurface{i,1} = newIVObject.Bootstrap ...
                    ([sDataSeriesIn(1) sDataSeriesIn(2)]).values{i,1};
            end
        end

    else
        % Place-holder for other possible calculation methods
    end

    %%%% STEP 2.2: Apply proxy method
    if strcmp(lower(obj.ProxyMethod) , 'linear')
        % Apply linear functional form
        for i=1:  inumberOfDates
            VolatilitySurface{i,1}= obj.ProxyParam1 + ...
                obj.ProxyParam2 .* VolatilitySurface{i,1};
        end
    else
        % Place-holder for other possible calculation methods
    end

    
 %%%% STEP 3: Apply Extrapolation Method %%%%

    newIVDataSeries = sDataSeriesIn(1).Clone; % Create New data-series object

    %%%% STEP 3.1
    switch lower(obj.SwapIVMethod) % Change strings to lower case
        case 'normaliv_constant'
            newLinearInterp =  Bootstrap.bsLinearInterpolation();
            for i = 1 : inumberOfDates
                VolatilitySurface{i,1} = newLinearInterp.BiLinearMatrix ...
                    (obj.ouputfrequencyprofile, obj.SwapTenors, ...
                    ReducedOptionMaturities, ReducedTenors, ...
                    VolatilitySurface{i,1}, 'true');
            end
            newIVDataSeries.volatility_measure ='normaliv';
        otherwise
            disp('Unknown method.')
    end

    %%%% STEP 3.2: Update axis values and values of the new data-series
    newIVDataSeries.axes(1).values = num2cell(obj.ouputfrequencyprofile);
    newIVDataSeries.axes(2).values = num2cell(obj.SwapTenors);
    newIVDataSeries.values = VolatilitySurface;
    newIVDataSeries.axis1_scale ='years';
    newIVDataSeries.axis2_scale ='years';

    % Calculate the final volatility surface and update the calculation 
    % object properties with user input parameters
    obj.Methods
    newIVObject.SwapIVOutputType = obj.SwapIVOutputType;
    newIVObject.SwapTenors = obj.SwapTenors; %Output Tenors
    newIVObject.outputfreq = [];
    newIVObject.ouputfrequencyprofile = obj.ouputfrequencyprofile; %Output maturities

    newIVDataSeries = newIVObject.Bootstrap([newIVDataSeries sDataSeriesIn(2)]);
    newIVDataSeries.volatility_measure = obj.Methods{2};
    newIVDataSeries.volatility_type = obj.Methods{3};

    results = newIVDataSeries;
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% _________________________________________________________________________________________
%
%% |2) [Calibrate()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function calibrates parameters which are then used in bootstrap methods 
%
% See class |[BaseBootstrapAlgorithm]| for details
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    function Calibrate(obj, DataSeriesIn)

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
 end  
end

