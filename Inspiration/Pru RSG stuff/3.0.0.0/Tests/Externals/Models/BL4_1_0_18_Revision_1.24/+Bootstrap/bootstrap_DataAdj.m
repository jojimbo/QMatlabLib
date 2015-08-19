%% DATA ADJUSTMENT
% 
% *The class allows the user to perform adjustments to a data series by 
% acting on it with an adjustment data series.*
%

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_DataAdj < prursg.Bootstrap.BaseBootstrapAlgorithm
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method adjusts an input data series using 
% the values given in |[InputAdjDataSeries]| and the operation given in |[dataAdjOperation]|.
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
% *|[dataAdjOperation]|* - Operation used to make the adjustment; "+", "-",
% "*" or "/"
%
% _Data Type_: string
%
% *|[dataAdjMethod]|* - the way that input dataseries are adjusted: "point", 
% "curve", or "mix". for example, one point added to another point, one curve 
% multiplied by another curve, or one curve divided by one point
%
% _Data Type_: string
%
% *|[dataAdjIndexAxis]|* - when input dataseries contain an index, the axis 
% value of the index needs to be specified, e.g. for a credit index, the axis 
% can be "spread", "yield", "OAS" etc
%
% _Data Type_: string
% 
% *|[dataAdjCurveTerm]|* -when method involves operation on point data and 
% the point needs to be taken from a curve, the corresponding term/maturity 
% of the point on the curve needs to be specified, e.g. "3", "10"
%
% _Data Type_: double
%
% *|[tolerance]|* - permissible limit of variation, $0.01$
%
% _Data Type_: single value
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
       
      % Data Series  
        InputAdjDataSeries; 

      
      % Parameters 
       
        outputfreq 
        dataAdjOperation 
        dataAdjMethod
        dataAdjIndexAxis
        dataAdjOutputIndexAxis
        dataAdjCurveTerm
        
        tolerance = 1E-02;
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap()]|* - Function returns an adjusted data series by 
% acting on the input dataseries with an adjustment series by a simple operation 
% specified in |[dataAdjOperation]|.
%

%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
methods
        
    % Constructor
    
   function obj = bootstrap_DataAdj ()
       obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
   end
                  
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function returns an adjusted data series by acting on the input data
% series with |[InputAdjDataSeries]| by a simple operation 
% specified by |[dataAdjOperation]|
%
% *_Inputs_*
%
% *|[DataSeriesIn]|* - two data series, one adjustment, one to be adjusted,
% can be in the form of yield curves, credit indices or point data
% 
% _Data Type_: 1-dim array
%
% *_Outputs_*
%
% Adjusted version of original to-be-adjusted data series.
%
% _Data Type_: 1-dim array
%
% *_Calculations_*
%
% Process the |[DataSeriesIn]| depending on the |[dataAdjMethod]|.
%
% If "point", extract the point value from the *|[DataSeriesIn]|*, be it a 
% yield curve, a credit index or a point data, and clone the input data structure; 

% If "curve", sort and clone the input data.
% Identify and set up the output frequency profile which specifies the
% frequency of outputs e.g. annually or monthly etc.
%
% Once data is ready, apply the operation specified in |[dataAdjOperation]|
% to the two set of data.  
%
% Update data series properties - including changing data units to "absolute"

%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  function results = Bootstrap(obj, DataSeriesIn)

    inumberOfDates = size(DataSeriesIn(1).dates,1);
    numOfDataSeries = size(DataSeriesIn,2);

    if strcmp(obj.dataAdjMethod, 'point')

       InputAdjDataSeries_Temp = prursg.Engine.DataSeries();

       for i = 1 : numOfDataSeries
           for j = 1: inumberOfDates

             % read points off the dataseries
             if strcmp(DataSeriesIn(i).dataseries_type,'bond_index')
                 InputAdjDataSeries_Temp(i).values{j} =DataSeriesIn(i). ...
                     values{j}(strmatch(obj.dataAdjIndexAxis, ...
                     DataSeriesIn(i).axes.values));

             elseif strcmp(DataSeriesIn(i).dataseries_type, 'point')
                 InputAdjDataSeries_Temp(i).values{j} = DataSeriesIn(i). ...
                     values{j}(1);    

             elseif strcmp(DataSeriesIn(i).dataseries_type, 'curve')
                 InputAdjDataSeries_Temp(i).values{j} = DataSeriesIn(i). ...
                     values{j}( find (str2num(obj.dataAdjCurveTerm) - ...
                     obj.tolerance < cell2mat(DataSeriesIn(i).axes. ...
                     values) & cell2mat(DataSeriesIn(i).axes.values) ...
                     < str2num(obj.dataAdjCurveTerm) + obj.tolerance));
             end

             % convert units to absolute values
             if strcmp(DataSeriesIn(i).dataseries_type,'bond_index')      
                 unitsVector = strread (DataSeriesIn(i).units, ...
                       '%s', 'delimiter', ',');
                 units = unitsVector(strmatch(obj.dataAdjIndexAxis,...
                     {'Index Value' 'yield' 'duration' 'convexity' 'spread' 'OAS'}));
             else units = DataSeriesIn(i).units;
             end

             if strcmp(units,'percent')
                 InputAdjDataSeries_Temp(i).values{j} = ...
                     InputAdjDataSeries_Temp(i).values{j} /100;
             elseif strcmp(units,'bps')
                 InputAdjDataSeries_Temp(i).values{j} = ...
                     InputAdjDataSeries_Temp(i).values{j} /10000;
             end


           end
       end
       % set up results base value
       results = DataSeriesIn(1).Clone;
       results.units ='absolute';
       results.axes.values = {obj.dataAdjOutputIndexAxis};
       results.values{1} = InputAdjDataSeries_Temp(1).values{1};

    end

    %if strcmp(obj.dataAdjMethod, 'mix')

    if strcmp(obj.dataAdjMethod, 'curve')
        newSortDataSeries = Bootstrap.BsSort();

        obj.InputAdjDataSeries = newSortDataSeries.SortDataSeries...
            (DataSeriesIn(1).Clone);
        for i = 2 : numOfDataSeries
            obj.InputAdjDataSeries = [obj.InputAdjDataSeries ...
                newSortDataSeries.SortDataSeries(DataSeriesIn(i).Clone)];
        end

        maxTerm = obj.InputAdjDataSeries(1).axes(1).values{1, end};

        BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
            (obj.outputfreq,maxTerm);
        outputfreqProfile = ...
            BsfrequencyprofileObject.AdjustedIntervalArray;

        for i =1:numOfDataSeries
            InputAdjDataSeries_Temp(i) = ...
                BsfrequencyprofileObject.SmallerDataSeriesObject...
                (outputfreqProfile,obj.InputAdjDataSeries(1,i));
        end
        % set up results base value
        results = InputAdjDataSeries_Temp(1) ;
    end

    % data adjustment operations
    for i = 2 : numOfDataSeries
        for j = 1 : inumberOfDates

            if strcmp(obj.dataAdjOperation, '+')
                results.values{j} = results.values{j} + ...
                    InputAdjDataSeries_Temp(i).values{j};
            elseif strcmp(obj.dataAdjOperation, '-')
                results.values{j} =  results.values{j} - ...
                    InputAdjDataSeries_Temp(i).values{j};
            elseif strcmp(obj.dataAdjOperation, '*')
                results.values{j} = results.values{j} .* ...
                    InputAdjDataSeries_Temp(i).values{j};
            elseif strcmp(obj.dataAdjOperation, '/')
                results.values{j} = results.values{j} ./ ...
                    InputAdjDataSeries_Temp(i).values{j};
            end
        end
    end

    results.Name = '';
    results.source ='iMDP';
    results.description = 'derived using bootstrap_DataAdj method';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  end
 end     
end


