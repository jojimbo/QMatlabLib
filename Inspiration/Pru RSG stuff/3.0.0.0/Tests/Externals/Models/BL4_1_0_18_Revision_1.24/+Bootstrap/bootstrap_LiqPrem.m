%% LIQUIDITY PREMIUM
% 
% *The class calculates lliquidity premium and extrpolate to give a full term 
% structure based on the mehodology in QIS4.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_LiqPrem < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% Given credit swap spreads and BU credit portfolio composition, the re-defined 
% |[Bootstrap()]| method calculates liquidity premium and extrpolates to give 
% a full term structure with liquidity premium reducing linearly to zero after the cut-off point.
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
% *Input Data Series*
%
% *|[InputAdjDataSeries]|* - Data series used to adjust the input data series.
% 
% _Data Type_: data series
%
% *Input Parameters*
%
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string 
%
% *|[compounding]|* - Defines the way that the output yield curve is 
% compounded, e.g. "annually" or "continuously".
%
% _Data Type_: string
%
% *|[compoundingfrequency]|* - Defines the annual frequency, at which 
% the output yield curve is compounded e.g. "2" for semi-annually.
%
% _Data Type_: scalar
%
% *|[LTdefault]|* - allowance for long term expected default
%
% _Data Type_: scalar
%
% *|[proportion]|* - proportion of the excess spread over swaps remaining 
% after the deduction of LT defaults that is due to illiquidity
%
% _Data Type_: scalar 
%
% *|[cutOffpoint]|* - term after which liquidity premium starts to
% reduce to zero
%
% _Data Type_: scalar 
%
% *|[zeroLPpoint]|* - point where liquidity premium is reduced to zero
%
% _Data Type_: double 
%
% *|[endterm]|* - last maturity
%
% _Data Type_: scalar 
%
% *|[creditAdj]|* - credit risk adjustment to swap rates to reach risk free rates
%
% _Data Type_: scalar 
%
% *|[lqpMethod]|* - "pillar1", "pillar2"
%
% _Data Type_: string
%
% *|[assetWeighting]|* - BU credit portfolio composition
%
% _Data Type_: string

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
        
      % Data Series 
        assetSwapSpreads
 
      % Parameters 
       
        % output parameters
        outputfreq
        compounding
        compoundingfrequency
        
        % LP parameters
        LTdefault 
        proportion 
        cutOffpoint
        zeroLPpoint 
        endterm 
        creditAdj
        lqpMethod
        
        % BU credit portfolio
        assetWeighting
    
           
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap()]|* - Function calculates liquidity premium and 
% extrpolates to give a full term structure 
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 methods
% Constructor

   function obj = bootstrap_LiqPrem ()
       obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
   end                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function calculates liquidity premium from credit swap spreads and 
% extrpolates to give a full term structure with liquidity premium reducing 
% linearly to zero over the next 5 years after the cut-off point
%
% *_Inputs_*
%
% *|[DataSeriesIn]|* - credit swap spreads
% 
% _Data Type_: 1-dim array
%
% *_Outputs_*
%
% liquidity premium with full term structure
%
% _Data Type_: 1-dim array
%
% *_Calculations_*
%
% STEP 1: Calculate weighted average CreditSwapSpread, $CS$
%
% Multiply BU's |[assetWeighting]| in a credit index $i$ by the swap
% spread of that credit index $i$.
% Sum up the products over all BU's credit assets to give weighted average $CS$,
%
% $CS = \sum_{i \in assets} assetWeighting(i) \times assetSwapSpreads(i)$
% 
% STEP 2: Derive liquidity premium $LP$
%
% Given proportion $x$, LTdefault $ybps$, and creditAdj $-10bps$
%
% $LP = x \% \times (CS - y) - 10$
%
% _subject to a minimum of zero_
%
% STEP 3: Extrapoalte liquidity premium
%
% Based on QIS4 methodology, the liquidity premium is applied to the basic
% swap curve up to the cut-off point where the addition applied is reduced
% linearly to zero over the next 5 years.
%
% So in the full term structure, for terms up to (include) |[cutOffpoint]|,
% liquidity premium equals $LP$ that we obtained in STEP2; 
% From the |[cutOffpoint]|, $LP$ is reduced linearly by $\frac {LP}{5}$
% each year to zero at the end of 5 years and zero for all terms after.
%
%
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function results = Bootstrap(obj, DataSeriesIn)

        results = DataSeriesIn(1).Clone;

        % Add properties
        results.AddDynamicProperty('ratetype','llp');
        results.AddDynamicProperty('compounding',obj.compounding);
        results.AddDynamicProperty('compoundingfrequency', ...
            num2str(obj.compoundingfrequency));
        results.AddDynamicProperty('daycount','365');

        results.RemoveDynamicProperty('rating');
        results.RemoveDynamicProperty('index_type');

        % find 'spread' and reformat them into an array

        numOfDataSeries = size(DataSeriesIn,2);
        inumberOfDates = size(DataSeriesIn(1).dates,1);
        numOfAssets = size(str2num(obj.assetWeighting),2);

        obj.assetSwapSpreads = prursg.Engine.DataSeries();

        for i = 1 : numOfDataSeries
            for j = 1: inumberOfDates

              obj.assetSwapSpreads(j).values{i} = DataSeriesIn(i).values{j} ...
                    (strmatch('swapSpread',DataSeriesIn(i).axes.values));

            end
        end

        % main LQP calculations
        for i = 1: inumberOfDates

            % Step 1. Derive LP before cut-off point
            CreditSwapSpread(i) = sum( cell2mat ...
            (obj.assetSwapSpreads(i).values) .* ...
            str2num(obj.assetWeighting))/sum(str2num(obj.assetWeighting));

            LiqPrem(i) = max(0, (obj.proportion/100) .* ...
            (CreditSwapSpread(i)-obj.LTdefault/10000)-obj.creditAdj/10000);

            % Step 2. extrapolate LP curve
            OutputFrequencyProfile = Bootstrap.Bsfrequencyprofile ...
                (obj.outputfreq,obj.endterm).AdjustedIntervalArray;
            freq = sum(str2num(obj.outputfreq).* [12 4 2 1]);

            LP.values {i} = zeros (1, size(OutputFrequencyProfile,1));

            for j = 1:find(OutputFrequencyProfile<obj.cutOffpoint,1,...
                    'last');
                LP.values{i}(j) = LiqPrem(i);
            end

            for j = find(OutputFrequencyProfile>obj.cutOffpoint,1): ...
                    find(OutputFrequencyProfile<obj.zeroLPpoint,1, ...
                    'last');
                LP.values{i}(j) = max(0, LP.values{i}(j-1) - ...
                    LiqPrem(i)/(obj.zeroLPpoint-obj.cutOffpoint)/freq);
            end

        end

        results.Name = '';
        results.dates = DataSeriesIn(1).dates;
        results.source ='iMDP';
        results.description = 'derived using bootstrap_LiqPrem method';
        results.ticker = 'na';
        results.dataseries_type = 'curve';
        results.axes(1).title = 'Term';
        results.axes(1).values = num2cell(OutputFrequencyProfile');
        results.values = LP.values;

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
 end
end
    


