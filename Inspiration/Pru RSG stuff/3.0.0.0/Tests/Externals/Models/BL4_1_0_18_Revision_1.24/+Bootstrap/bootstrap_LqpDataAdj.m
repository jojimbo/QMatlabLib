%% LIQUIDITY PREMIUM DATA ADJUSTMENT
% 
% *The class forms part of the liquidity premium calculation.
% It returns an interpolated swap spread that can be used to make the swap
% spread adjustment for a credit index.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_LqpDataAdj < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% Given two swap spreads with different tenors, the re-defined |[Bootstrap]| method linearly
% interpolates a swap spread for a required term
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *|[outputfreq]|* - a string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string 
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  properties
      
     outputfreq
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap()]|* - Function linear-interpolates a swap spread 
% for a term that is determined by a credit index's duration 
%
%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
  methods
    % Constructor
    
    function obj = bootstrap_LqpDataAdj ()
        obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
    end             
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function linear-interpolates a swap spread for a term that is determined by a credit index's duration 
% 
% *_Inputs_*
%
% *|[DataSeriesIn]|* - two swap spreads with different terms; 
% a credit index, the duration of which is the required term 
%
% _Data Type_: 1-dim array 
%
% *_Outputs_*
%
% An interpolated swap spread 
%
% _Data Type_: 1-dim array
%
% *_Calculations_*
%
% The duration of the credit index defines the outputTenor.
% The interpolation takes two data points defined by the two market swap spreads,
% then the interpolant is calcualted as,
%
% $result = LowerVal + \frac {(UpperVal - LowerVal)}{(UpperTerm -
% LowerTerm)} \times (outputTenor - LowerTerm)$
%
%
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
    function results = Bootstrap(obj, DataSeriesIn)

        inumberOfDates = size(DataSeriesIn(1).dates,1);

        results = DataSeriesIn(1).Clone;

        for i = 1: inumberOfDates

            outputTenor = DataSeriesIn(3).values{i}...
                (strmatch('duration',DataSeriesIn(3).axes.values));

            LowerTerm = DataSeriesIn(1).axes(1).values{1} ;
            UpperTerm = DataSeriesIn(2).axes(1).values{1} ;
            LowerVal = DataSeriesIn(1).values {i};
            UpperVal = DataSeriesIn(2).values {i};
            results.values{i}(1) = LowerVal + (UpperVal - LowerVal) /...
                (UpperTerm - LowerTerm) * (outputTenor - LowerTerm);

        end

        results.Name = '';
        results.description = 'derived Swap Spread method';
        results.source ='iMDP';
        results.ticker = 'na';
        results.axes(1).values{1}(1) = outputTenor;

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
  end
end
    


