%% WILSON SMITH
%
% *The main purpose of this class is to interpolate and extrapolate par (swap) 
% rates and zero coupon bond prices*
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef BsWilsonSmith < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% How to Use the Class
% 
% This class inherits the properties and methods from the parent class |[handle]|.
%
% New properties have been defined and the default methods have been
% overwritten.
%
% The aim of the Wilson-Smith method is to find a discount function $P(t)$,
% i.e. the ZCB prices, for all maturities $t>0$.
% 
% The intuition of the model is to assess the ZCB price as a linear combination
% of $N$ kernel functions,
%
% $P(t) = e^{-f_{\infty} \cdot t} + \sum_{i=1}^{N} \xi_i \cdot (\sum_{j=1}^{J} c_{i,j} \cdot W(t,u_{i,j}))$
%
% where $N$ is the number of input assets, $\xi_i$ the parameters 
% to fit the actual yield curve, $W(t,u_{i,j})$ the wilson functions, and 
% the inner parenthesis $\sum_{j=1}^{J} c_{i,j} \cdot W(t,u_{i,j})$ is called
% the kernel functions $K_i(t)$ (See |[WilsonsKernelFunction()]|).
%
% The Wilson functions are defined functions of two input parameters: the 
% long term forward rate $f_{\infty}$ and the decay rate $\alpha$ that determines 
% how fast the estimated forward rates converge to the long term forward rate. 
% (see |[WilsonsFunction()]|)  
%
% To work out $\xi$, Based on the cash flows profile of each input asset, the Wilson and the kernel 
% functions are computed. 
%
% Once the kernel and the Wilson functions are determined, given the market prices 
% of the $N$ input assets, $m_i, i=1,2,...,N$, we can set up $N$ linear equations,
%
% $m_i = \sum_{j=1}^{J} c_{i,j} \cdot P(u_{i,j})$
%
% Substituting in the formula of $P(t)$, we have the right side of the equation equals to,
%
% $\sum_{j=1}^{J} c_{i,j} (\cdot e^{-f_{\infty} \cdot t} + \sum_{l=1}^{N} \xi_l \cdot (\sum_{k=1}^{J} c_{l,k} \cdot W(u_{l,j},u_{l,k})))$
% 
% Rearranging the equation, we have,
%
% $m_i = \sum_{j=1}^{J} c_{i,j} \cdot e^{-f_{\infty} \cdot t} + \sum_{l=1}^{N} (\sum_{k=1}^{J} (\sum_{j=1}^{J} c_{i,j} \cdot W(u_{l,j},u_{l,k})) \cdot c_{l,k}) \cdot \xi_l$
%
% Let $A$ be a $N \times N$ |[DesignMatrix]| with values equal to $\sum_{l=1}^{N} (\sum_{k=1}^{J} (\sum_{j=1}^{J} c_{i,j} \cdot
% W(u_{l,j},u_{l,k})) \cdot c_{l,k})$.
%
% Let $y$ be a $N \times 1$ |[responseVector]| with values equal to
% $m_i - \sum_{j=1}^{J} c_{i,j} \cdot e^{-f_{\infty} \cdot t}$.
%
% The parameters needed to compute the linear combination of the kernel functions, 
% $\xi_l$, can then be derived by solving the linear system,
%
% $\xi = A^{-1} y$
%
% See |[FitWilsonSmithParameters()]| for details.
%
% By plugging the solution $\xi$ back into the pricing function $P(t)$ at any given time $t$
% we receive the discount function for maturity $t$. (See |[WilsonsSmithZCBPriceFunction()]|).
%
% 
%% Properties
% These are global parameters which are available to all methods in
% this class.
%  
% *|[outputfreq]|* - a string that lists the number of monthly, quarterly,
% semi-annual, and annual output intervals
%
% _Data Type_: string
%
% *|[longTermFwdRate]|* - the value that forward rates converge to in the
% long term.
% Note that the input long term forward rate is assumed to be annually compounded, 
% thererfore it is first transformed to a continuously compounded rate.
%
% _Data Type_: scalar
%
% *|[lastLiquidPoint]|* - $T_{LLP}$ maximum maturity at which swaps/bonds are liquid
%
% _Data Type_: scalar
% 
% *|[decayrate]|* - $\alpha$, represents the speed with which the standard deviation 
% of returns reverts to its long term level. It controls the exponential decay 
% from the last liquid point to the long-term target
%
% _Data Type_: scalar
%
% *|[outputStartTerm]|* - defines the start term of the ouput yield curve
%
% _Data Type_: scalar
% 
% *|[outputEndTerm]|* - defines the end term of the ouput yield curve
%
% _Data Type_: scalar
%
% *|[ratetype]|* - the type of rate the input dataseries is, e.g. "swap",
% "spot" or "zcb"
%
% _Data Type_: string
%
% *|[compounding]|* - the way that the input rate is compounded, 
% e.g. "ann" or "cont"
%
% _Data Type_: string
%
% *|[compoundingfrequency]|* - the annual frequency, $f$ at which 
% the input rate is compounded e.g. "2" for semi-annually
%
% _Data Type_: scalar
%
% *|[daycount]|* - defines the day count convention of the output e.g. "360"
%
% _Data Type_: scalar
%
% *|[units]|* - defines the unit of the input rate, e.g. "percent" or "bps"
%
% _Data Type_: string
%
% *|[ValidRawDataSeries]|* - data series with valid maturities and rates
%
% _Data Type_: array
%
% *|[CashflowprofileSeries]|* - defines the cashflow profiles of the input
% instruments
%
% _Data Type_: array
%
% *|[ouputfrequencyprofile]|* - determines the output frequency of the
% DataSeriesObject
%
% _Data Type_: string
%
% *|[WilsonSmithParameters]|* - return of |[FitWilsonSmithParameters()]|,
% i.e., the solution of the Wilson Smith Linear System
%
% _Data Type_: array
%
% *|[minValidRate]|* - validation parameter, $-10$, the minimum valid rate
%
% _Data Type_: string
%
% *|[MaxValidRate]|* - validation parameter, $100$, the maximum valid rate
%
% _Data Type_: string
%
% *|[newDataSeriesObject]|* - initial set-up of the bootstrap object
%
% _Data Type_: array
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        minValidRate = -10;
        MaxValidRate = 100;
        
        % Set-Up data series object to store results
        newDataSeriesObject
        
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

%% List of Methods
% This bootstrap class introduces the following methods:
%
% *|1) [WilsonsSmithZCBPrices()]|* - For each date, this function returns a
% data series object. The values of the object are the ZCB prices for all 
% maturities that are defined in the |[ouputfrequencyprofile]|.
% 
%
% *|2) [WilsonsSmithZCBPriceFunction()]|* - This is referred to as the pricing 
% function in the Deliotte Technical Literature. 
% It calculates the ZCB prices for all maturities using the fitted parameters, 
% $\xi_1, \xi_2,..., \xi_N$
%
% *|3) [FitWilsonSmithParameters()]|* - Function works out the unknown parameters 
% needed to compute the linear combination of the kernel functions, $\xi_j, j=1,2,...,N$
%
% *|4) [WilsonsMatrixFunction()]|* - Constructs the Response and Design Array 
% Matrices of the Wilson Smith linear Kernel (basis) function method
%
% *|5) [WilsonsKernelFunction()]|* - This is referred to as the kernel function 
% in the Deliotte Technical Literature.
% For each input instrument a particular kernel function is computed. 
%
% *|6) [WilsonsFunction()]|* - This function is referred to as the wilson function 
% in the Deliotte Technical Literature and has been designed to minimize a 
% standard smoothing functional subject to the constrainst that it reproduces the market prices.
%
% *|7) [Valid_RawDataSeries()]|* - Function collects the valid data fo object 
% to contain only points that are valid for the purposes of interpolation and extrapolation

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
 % Constructor
        function obj = BsWilsonSmith(DataSeriesIn, ParametersIn)
           
            obj.outputfreq = ParametersIn{1};
            obj.longTermFwdRate = log(1+ParametersIn{2});
            obj.lastLiquidPoint = ParametersIn{3};
            obj.decayrate = ParametersIn{4};
            obj.outputStartTerm = ParametersIn{5};
            obj.outputEndTerm = ParametersIn{6};
            obj.ValidRawDataSeries = obj.Valid_RawDataSeries(DataSeriesIn);
            obj.ouputfrequencyprofile = Bootstrap.Bsfrequencyprofile...
                (obj.outputfreq, obj.outputEndTerm).AdjustedIntervalArray;
            
            obj.ratetype = DataSeriesIn.ratetype;
            obj.compounding=DataSeriesIn.compounding ;
            
            if ~strcmp(lower(DataSeriesIn.compoundingfrequency), 'na' )
                obj.compoundingfrequency =str2num...
                    (DataSeriesIn.compoundingfrequency) ;
            else
                obj.compoundingfrequency = 'na';
            end
            
            obj.daycount= str2num(DataSeriesIn.daycount) ;
            obj.units = DataSeriesIn.units;
            
            % Allocate storage space
            % WilsonSmithParameters Stores the parameters of each Wilson-Smith fit
            obj.WilsonSmithParameters = cell...
                (size(obj.ValidRawDataSeries,1),1);
            % CashflowprofileSeries stores the asset values, cash flow maturity times, & cash flow values
            obj.CashflowprofileSeries = cell...
                (size(obj.ValidRawDataSeries,1),3);
            
            
            % Set-Up data series object to store results :: use existing
            % raw data series object to achieve this
            obj.newDataSeriesObject = DataSeriesIn.Clone();
            
            obj.newDataSeriesObject.axes.values= num2cell...
                (obj.ouputfrequencyprofile)';
            inumberOfDates =  size(obj.newDataSeriesObject.dates,1);
            
            for i= 1 : inumberOfDates
                obj.newDataSeriesObject.values{i,1} = zeros...
                    (size(obj.ouputfrequencyprofile'));
            end
            
            obj.newDataSeriesObject.Name = '';
            obj.newDataSeriesObject.source ='iMDP';
            obj.newDataSeriesObject.ticker= 'na';
            
            obj.newDataSeriesObject.description = ...
                'derived zcb prices using wilson-smith method';
            obj.newDataSeriesObject.ratetype = 'zcb';
            obj.newDataSeriesObject.compounding ='na';
            obj.newDataSeriesObject.compoundingfrequency =  'na';
            obj.newDataSeriesObject.daycount ='na';
            obj.newDataSeriesObject.units ='absolute';
            
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________________________
%
%% |1) [WilsonsSmithZCBPrices()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% For each date of the input data series, this function returns the ZCB prices
% for the maturities that are defined in the |[ouputfrequencyprofile]|. 
%
% *_Inputs_*
%
% NA 
% 
% *_Outputs_*
%
% |[WilsonsSmithZCBPricesReturn]| - the new data series object with
% properties defined in the *Constructor* above and values calculated as |[fittedZCBs]|
%
% _Data Type_: data series object
%
% *_Calculation_* 
%
% For each date $i$, parameters are fitted using |[WilsonSmithParameters()]|.
% ZCB prices are then calculated using the fitted parameters. See function
% |[WilsonsSmithZCBPriceFunction()]| for details.
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
        
    function  WilsonsSmithZCBPricesReturn = WilsonsSmithZCBPrices(obj)

        % Step 0 Initilise parameters and vectors
        inumberOfDates =  size(obj.ValidRawDataSeries,1);
        inumberOfZCBs = size(obj.ouputfrequencyprofile,1);

        fittedZCBs = cell(inumberOfDates,1);
        Maturities = obj.ouputfrequencyprofile;

        % Step 1 Calculate bond prices for each date
        for i = 1 : inumberOfDates
            FittedParameters = obj.WilsonSmithParameters {i,1};
            dblCashflowMaturities = obj.CashflowprofileSeries {i,2};
            dblCashflows = obj.CashflowprofileSeries {i,3};
            fittedZCBs{i,1} = WilsonsSmithZCBPriceFunction(obj, ...
                Maturities, FittedParameters, dblCashflowMaturities, ...
                dblCashflows, obj.decayrate, obj.longTermFwdRate);
            obj.newDataSeriesObject.values{i,1} = fittedZCBs{i,1}';
        end

        WilsonsSmithZCBPricesReturn =obj.newDataSeriesObject;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% 
% _________________________________________________________________________________________
%
%% |2) [WilsonsSmithZCBPriceFunction()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This is referred to as the pricing function in the Deliotte Technical 
% Literature. It calculates the ZCB prices for all maturities $t$ using the
% fitted parameters $\xi_1, \xi_2,..., \xi_N$, and thus the term structure
% for the spot rates.
%
% *_Inputs_*
%
% |[MaturityTime]| - a vector of doubles, $t_1, t_2,..., t_T$, the term to maturity of the ZCBs
% where $T$ is the total number of different maturities
%
% _Data Type_: 1-dim array
% 
% |[FittedParameters]| - a vector of doubles, $\xi_1, \xi_2,..., \xi_N$,
% parameters that fitted the actual yield curve, where $N$ is the total number of assets. 
% See |[FitWilsonSmithParameters]| for details
%
% _Data Type_: 1-dim array
% 
% |[dblCashflowMaturities]| - a vector of doubles, $u_{i,1}, u_{i,2},..., u_{i,J}$, the cash payment dates for the
% input instruments $i$ with the number of dates $J$. $J$ varies from asset to asset
%
% _Data Type_: 1-dim array
%          
% |[dblCashflows]| - a vector of doubles, $c_{i,1}, c_{i,2},..., c_{i,J}$, the cash flows that are due for
% instrument $i$ at time $u_{i,1}, u_{i,2}, u_{i,3},..., u_{i,J}$
%
% _Data Type_: 1-dim array
%          
% |[decayrate]| - $\alpha$, mean reversion, a measure for the speed of
% convergence to the |[longTermFwdRate]|
%
% _Data Type_: scalar
%           
% |[longTermFwdRate]| - $f_{\infty}$, the unconditional value that forward rates converge to in the
% long term, continuously compounded
%
% _Data Type_: scalar  
% 
% *_Outputs_*
%
% |[ZCBPrice]| - a $T \times 1$ vector of ZCB prices, where $T$ is the total number of maturities
%
% _Data Type_: 1-dim array
%
% *_Calculation_* 
%
% Let the $j^{th}$ ZCB price be ZCBPrice(j,1), $j = 1,2,...,T$
%
% $ZCBPrice(j,1) = e^{-f_{\infty} \cdot t_j} + \sum_{i=1}^{N} \xi_i \cdot K_i(t_j)$
%


%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    function  ZCBPrice = WilsonsSmithZCBPriceFunction(obj,MaturityTime,...
            FittedParameters, dblCashflowMaturities, dblCashflows, ...
            decayrate, longTermFwdRate)

        iNumberofMaturities =size(MaturityTime,1) ;
        iNumberOfAssets= size(dblCashflowMaturities,1);
        ZCBPrice = zeros(iNumberofMaturities,1);

        for j =1 : iNumberofMaturities 
            sum = 0 ;
            for i =1 : iNumberOfAssets 
                KernelFunctionValue = obj.WilsonsKernelFunction ...
                    (MaturityTime(j,1), dblCashflowMaturities{i,1}, ...
                    dblCashflows{i,1}, decayrate, longTermFwdRate);
                sum = sum + FittedParameters(i,1) * KernelFunctionValue;
            end
            ZCBPrice(j,1)= exp(-longTermFwdRate*MaturityTime(j,1)) + sum;
        end

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% 
% _________________________________________________________________________________________
%
%% |3) [FitWilsonSmithParameters()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function works out the unknown parameters needed to compute the linear 
% combination of the kernel functions, $\xi_j, j=1,2,...,N$. 
%
% *_Inputs_*
%
% NA
% 
% *_Outputs_*
%
% |[FitWilsonSmithParametersReturn]| - the solution of the Wilson Smith
% linear system. 
%
% _Data Type_: 2-dim array
%
% *_Calculation_* 
%
% STEP1: For a given date calculate the asset price and cashflows for
% a given yield type. See |[ValidRawDataSeries()]| for details.
%
% STEP2: We now proceed to solve the linear system of equations which is
% of the standard form $y = Ax$ such that we find the solution vector $x$ 
% satisfying the equation, $x = A^{-1} y$
% 
% The linear system consists of $N$ of the following equation,
%
% $m_i - \sum_{j=1}^{J} c_{i,j} \cdot e^{-f_{\infty} \cdot t} = \sum_{l=1}^{N} (\sum_{k=1}^{J} (\sum_{j=1}^{J} c_{i,j} \cdot W(u_{l,j},u_{l,k})) \cdot c_{l,k}) \cdot \xi_l$
%
% Using standard terminlogy from probability and statitics,  
%
% We define $y$ as a $N \times 1$ |[responseVector]| with values equal to the
% left side of the equation,
% $m_i - \sum_{j=1}^{J} c_{i,j} \cdot e^{-f_{\infty} \cdot t}$
%
% Define $A$ as a $N \times N$ |[DesignMatrix]| with values equal to
% $\sum_{l=1}^{N} (\sum_{k=1}^{J} (\sum_{j=1}^{J} c_{i,j} \cdot W(u_{l,j},u_{l,k})) \cdot c_{l,k})$
%
% Then, the parameter vector $\xi = A^{-1} y$
%
% See |[WilsonsMatrixFunction()]| for details.
%
% STEP3: Solve the linear system to obtian the parameters of the
% Kernel (basis) functions. 
% Store parameters for each date in the data series object.
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function FitWilsonSmithParametersReturn = FitWilsonSmithParameters(obj)

        % STEP 0: Initialise problem
        FitWilsonSmithParametersReturn = [];
        iNumberofDates = size(obj.ValidRawDataSeries,1);

        for ii = 1 :  iNumberofDates
        % STEP 1: Calculate the asset price and cashflows for a given yield type
          iNumberofAssetPrices =size(obj.ValidRawDataSeries{ii,1}, 2);
          dblRawAssetValuesOrRates =obj.ValidRawDataSeries{ii,2}';
          dblRawAssetMaturities = obj.ValidRawDataSeries{ii,1}';

          % The function assetcashflowprofiles expects to receive
          % arrays for obj.ratetype, obj.compounding & obj.compoundingfrequency
          % This set-up is in keeping with a more flexible XML schema
          % and multi different types of input assets to be developed
          % in later iterations

          if size(obj.ratetype,1) == 1
             ratetype1 = repmat(obj.ratetype(1,:),iNumberofAssetPrices,1);
             compounding1 = repmat(obj.compounding(1,:), ...
                 iNumberofAssetPrices,1);
             compoundingfrequency1=repmat(obj.compoundingfrequency(1,:),...
                 iNumberofAssetPrices,1);
             units1 = repmat(obj.units(1,:),iNumberofAssetPrices,1);
          else
             ratetype1 = obj.ratetype;
             compounding1 = obj.compounding;
             compoundingfrequency1 = obj.compoundingfrequency;
             units1 = obj.units;
          end

          Cashflowprofile = Bootstrap.bsAssetCashflowProfile();
          [dblAssetPrices,dblCashflowMaturities, dblCashflows] = ...
              Cashflowprofile.assetcashflowprofiles...
              (dblRawAssetValuesOrRates, dblRawAssetMaturities, ...
              ratetype1, compounding1, compoundingfrequency1, units1);
          obj.CashflowprofileSeries {ii,1} = dblAssetPrices;
          obj.CashflowprofileSeries {ii,2} = dblCashflowMaturities;
          obj.CashflowprofileSeries {ii,3} = dblCashflows;

          % STEP 2: Constructs the Response and Design Array Matrices
          [DesignMatrix,responseVector] = obj.WilsonsMatrixFunction ...
              (dblAssetPrices, dblCashflowMaturities, dblCashflows, ...
                obj.decayrate, obj.longTermFwdRate);

          % STEP 3: Solve the linear system
          obj.WilsonSmithParameters{ii,1}=(DesignMatrix^-1)*responseVector;

        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%
% _________________________________________________________________________________________
%
%% |4) [WilsonsMatrixFunction()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Constructs the Response and Design Array Matrices of the Wilson Smith linear Kernel (basis) function method
%
% *_Inputs_*
%
% |[dblAssetPrices]| - $m_i$, the market prices of the input
% instruments $i$ at valuation date, for $i = 1,2,...N$, $N$ the number of
% assets
%
% _Data Type_: 1-dim array
% 
% |[dblCashflowMaturities]| - a vector of $N$ cells. Each cell is a vector of doubles, 
% $u_{i,1}, u_{i,2}, u_{i,3},..., u_{i,J}$, the cash payment dates for the
% input instruments $i$ with the number of dates $J$. $J$ varies from asset to asset 
%
% _Data Type_: 1-dim array
%          
% |[dblCashflows]| - a vector of $N$ cells. Each cell is a vector of doubles,
% $c_{i,1}, c_{i,2}, c_{i,3},..., c_{i,J}$, the cash flows that are due for
% instrument $i$ at time $u_{i,1}, u_{i,2}, u_{i,3},..., u_{i,J}$
%
% _Data Type_: 1-dim array
%          
% |[decayrate]| - $\alpha$, mean reversion, a measure for the speed of
% convergence to the |[longTermFwdRate]|
%
% _Data Type_: scalar
%           
% |[longTermFwdRate]| - $f_{\infty}$, the unconditional value that forward rates converge to in the
% long term, continuously compounded
%
% _Data Type_: scalar 
% 
% *_Outputs_*
%
% |[DesignMatrix,responseVector]| - two arrays:
% 
% 1) |[DesignMatrix]| is a $N \times N$ matrix, where $N$ is the number of assets.
% Each value of the matrix is a sum product of cashflows and kernel functions 
% 
% 2) |[responseVector]| is a $N \times 1$ vector, each value represents the difference
% of the market value of asset $m$ and the present value of the cashflows of the asset
%
% _Data Type_: two arrays, one 2-dim and one 1-dim
%
% *_Calculation_*
%
% STEP 1: Calculate Design Matrix
% 
% Let the value in the $k^{th}$ row and the $i^{th}$ column of the matrix
% be DesignMatrix(k,i), assuming the asset $k$ has $J$ number of cash flows, then
%
% $DesignMatrix(k,i) = \sum_{j=1}^{J} c_{k,j} \cdot K_i(u_{k,j})$
% 
% where $K_i(u_{k,j})$ is the kernel function of asset $i$ and maturity
% time $u_{k,j}$. See |[WilsonsKernelFunction()]| for calculation details.
%
% The matrix is symmetric with respect to the diagonal. 
% Therefore, DesignMatrix(i, k) = DesignMatrix(k, i) 
% 
% STEP 2: Calculate Response Matrix
%
% Let the value in the $k^{th}$ row of the response vector be
% responseVector(k, 1), assuming the asset $k$ has $J$ number of cash flows, then
% 
% $responseVector(k, 1)= m_k - \sum_{j=1}^{J} c_{k,j} \cdot
% e^{-f_{\infty} \cdot u_{k,j}}$
%
         
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
    function [DesignMatrix,responseVector] = WilsonsMatrixFunction(obj,...
            dblAssetPrices, dblCashflowMaturities, dblCashflows, ...
            decayrate, longTermFwdRate)

        iNumberOfAssets = size(dblCashflowMaturities,1);

        DesignMatrix = zeros(iNumberOfAssets, iNumberOfAssets);
        responseVector = zeros(iNumberOfAssets, 1);
        
        % Calculate Design Matrix
        fprintf('WilsonsMatrixFunction - Calculating Design Array \n');

        for k = 1 : iNumberOfAssets
            iNumberOfCashflows = size(dblCashflowMaturities{k,1},2);
            for i = k : iNumberOfAssets
                sum = 0;
                for j = 1 : iNumberOfCashflows
                    assetcashflow = dblCashflows{k, 1}(j);
                    assetCashflowTime = dblCashflowMaturities{k,1}(j);
                    sum = sum + assetcashflow* obj.WilsonsKernelFunction...
                        (assetCashflowTime, dblCashflowMaturities{i,1},...
                        dblCashflows{i,1}, decayrate, longTermFwdRate);
                end
                DesignMatrix(k, i) = sum;
                DesignMatrix(i, k) = DesignMatrix(k, i) ;
            end
        end

        % Calculate Response Matrix
        fprintf('WilsonsMatrixFunction - Calculating Response Array \n');

        for k = 1 : iNumberOfAssets
            iNumberOfCashflows = size(dblCashflowMaturities{k,1},2);
            sum = 0;
            for j = 1 : iNumberOfCashflows
                assetcashflow = dblCashflows{k,1}(j);
                assetCashflowTime = dblCashflowMaturities{k,1}(j) ;
                sum = sum + assetcashflow* exp(-longTermFwdRate * ...
                    assetCashflowTime);
            end
            responseVector(k, 1) = dblAssetPrices(k,1) - sum;
        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%
% _________________________________________________________________________________________
%
%% |5) [WilsonsKernelFunction()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function is referred to as the kernel function in the Deliotte Technical 
% Literature.
% For each input instrument a particular kernel function is computed.
% The intuition here is to assess the ZCB price as the linear combination
% of all the kernel functions.
%
% *_Inputs_*
%
% |[MaturityTime]| - $t$, the term to maturity of the ZCB when calculating ZCB prices or; 
% $u_{i,k}$, the $k^{th}$ cash payment date of the instrument $i$ when fitting Wilson Smith Parameters
%
% _Data Type_: scalar
% 
% |[dblCashflowMaturities]| - a vector of doubles, $u_{i,1}, u_{i,2},..., u_{i,J}$, the cash payment dates for the
% input instruments $i$ with the number of dates $J$. $J$ varies from asset to asset
%
% _Data Type_: 1-dim array
%          
% |[dblCashflows]| - a vector of doubles, $c_{i,1}, c_{i,2},..., c_{i,J}$, the cash flows that are due for
% instrument $i$ at time $u_{i,1}, u_{i,2}, u_{i,3},..., u_{i,J}$
%
% _Data Type_: 1-dim array
%          
% |[decayrate]| - $\alpha$, mean reversion, a measure for the speed of
% convergence to the |[longTermFwdRate]|
%
% _Data Type_: scalar
%           
% |[longTermFwdRate]| - $f_{\infty}$, the unconditional value that forward rates converge to in the
% long term, continuously compounded
%
% _Data Type_: scalar
% 
% *_Outputs_*
%
% |[WilsonsKernelFunctionReturn]| - Given maturity time $t$ (or $u_{i,k}$), and cashflow date $u_{i,j}$
% we calculate a symmetric wilson function for the instrument $i$, $K_i(t)$ (or $K_i(u_{i,k})$)kernel functions
%
% _Data Type_: scalar
%
% *_Calculation_*
%
% When calculating ZCB prices,
%
% $K_i(t) = \sum_{j=1}^{J} c_{i,j} \cdot W(t,u_{i,j})$
%
% When fitting Wilson Smith Parameters,
%
% $K_i(u_{i,k}) = \sum_{j=1}^{J} c_{i,j} \cdot W(u_{i,k},u_{i,j})$
%
% where $W(t,u_{i,j})$ ($W(u_{i,k},u_{i,j})$) is the wilson function of the maturity $t$ ($u_{i,k}$) and cash
% payment date $u_j$. The inputs |[decayrate]| and |[longTermFwdRate]| are
% used for the calculation of the wilson function. See |[WilsonsFunction()]| for details
%
           
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
    function WilsonsKernelFunctionReturn = WilsonsKernelFunction(obj, ...
            MaturityTime, dblCashflowMaturities, dblCashflows, ...
            decayrate, longTermFwdRate)

        iNumberOfCashflows = size( dblCashflowMaturities,2);
        sum = 0 ;

        for j =1 : iNumberOfCashflows
            cashflow = dblCashflows(1, j);
            CashflowTime = dblCashflowMaturities(1,j) ;
            sum = sum +  cashflow * obj.WilsonsFunction(MaturityTime, ...
                CashflowTime, decayrate, longTermFwdRate);
        end

        WilsonsKernelFunctionReturn = sum ;

    end
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%
% _________________________________________________________________________________________
%
%% |6) [WilsonsFunction()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function is referred to as the wilson function in the Deliotte Technical 
% Literature and has been designed to minimize a standard smoothing functional subject to the
% constrainst that it reproduces the market prices.
% Note that wilson function is symmetric in the time arguments AssetMaturityTime, 
% AssetCashflowMaturityTime which implies that these two order in which they are
% inputted does not matter.
%
% *_Inputs_*
%
% |[MaturityTime1]| - $t$, the term to maturity of the ZCB when calculating ZCB prices or; 
% $u_{i,k}$, the $k^{th}$ cash payment date of the instrument $i$ when fitting Wilson Smith Parameters
%
% _Data Type_: scalar
%
% |[MaturityTime2]| - $u_{i,j}$, the $j^{th}$ cash payment date of the instrument $i$.
% Note that as the wilson function is symmetric, the definition of the two MaturityTime are interchangeable
%
% _Data Type_: scalar
%
% |[decayrate]| - $\alpha$, mean reversion, a measure for the speed of
% convergence to the |[longTermFwdRate]|
%
% _Data Type_: scalar
%           
% |[longTermFwdRate]| - $f_{\infty}$, the unconditional value that forward rates converge to in the
% long term, continuously compounded
%
% _Data Type_: scalar
%           
% *_Outputs_*
%
% |[WilsonsFunctionReturn]| - Given maturityTime1 $t$ ($u_{i,k}$) and maturityTime2
% $u_{i,j}$,we calculate a symmetric wilson function, $W(t,u_{i,j})$ ($W(u_{i,k},u_{i,j})$)
%
% _Data Type_: scalar
%
% *_Calculation_*
%
% When calculating ZCB prices,
%
% $W(t,u_{i,j}) = e^{{-f_{\infty}} \cdot (t+u_{i,j})} \cdot \{ \alpha \cdot min(t,u_{i,j}) -
% e^{{- \alpha}{max(t,u_{i,j})}} \cdot sinh(\alpha \cdot min(t,u_{i,j})) \}$
%
% When fitting Wilson Smith Parameters,
%
% $W(u_{i,k},u_{i,j}) = e^{{-f_{\infty}} \cdot (u_{i,k}+u_{i,j})} \cdot \{ \alpha \cdot min(u_{i,k},u_{i,j}) -
% e^{{- \alpha}{max(u_{i,k},u_{i,j})}} \cdot sinh(\alpha \cdot min(u_{i,k},u_{i,j})) \}$
%
           
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
   function WilsonsFunctionReturn = WilsonsFunction(obj, MaturityTime1,...
            MaturityTime2, decayrate, longTermFwdRate)
        
       WilsonsFunctionReturn = exp( -longTermFwdRate*(MaturityTime1 + ...
          MaturityTime2))*(decayrate * min(MaturityTime1,MaturityTime2)...
            - exp(-decayrate * max(MaturityTime1,MaturityTime2))* ...
              sinh(decayrate * min(MaturityTime1,MaturityTime2)));
    
   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%
% _________________________________________________________________________________________
%
%% |7) [Valid_RawDataSeries()]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% Function collects the valid data fo object to contain only points that are 
% valid for the purposes of interpolation and extrapolation
%
% *_Inputs_*
%
% |[DataSeriesIn]| - input data series object
%
% _Data Type_: data series object
%           
% *_Outputs_*
%
% |[Valid_RawDataSeriesReturn]| - data with valid maturities and valid rates 
%
% _Data Type_: 2-dim array
%
% *_Calculation_*
%
% STEP 1: Create a cell array of valid matrurities and rate values for each date
%
% STEP 2: Sort data by maturities
%
           
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
    function Valid_RawDataSeriesReturn = Valid_RawDataSeries(obj, ...
            DataSeriesIn)

        % STEP1
        Valid_RawDataSeriesReturn = cell(size(DataSeriesIn.dates, 1), 2);
        for j = 1 : size(DataSeriesIn.dates, 1)
            k =0;
            for i =1 : size(DataSeriesIn.axes(1,1).values, 2)
                if DataSeriesIn.axes(1).values{i} <= obj.lastLiquidPoint
                    if isnumeric(DataSeriesIn.values{j,1}(i)) && ...
                       (DataSeriesIn.values{j,1}(i) >= obj.minValidRate)...
                       && (DataSeriesIn.values{j,1}(i) <= obj.MaxValidRate)
                        k= k+1;
                        Maturities(k) =DataSeriesIn.axes(1).values{i};
                        Rates(k) =DataSeriesIn.values{j,1}(1,i);
                    end
                end
            end

            % STEP2
            sortedData=Bootstrap.BsSort().ShellSort2([Maturities;Rates],2);

            Valid_RawDataSeriesReturn{j, 1} = sortedData(1, :);
            Valid_RawDataSeriesReturn{j, 2} = sortedData(2, :);
        end

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
  end
end  