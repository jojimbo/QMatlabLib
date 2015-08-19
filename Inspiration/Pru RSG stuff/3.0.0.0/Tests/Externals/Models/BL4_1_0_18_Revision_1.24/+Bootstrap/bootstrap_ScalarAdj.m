%% SACALAR ADJUSTMENT
% 
% *The class allows the user to make simple, scalar, global adjustments to a data
% series.*
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_ScalarAdj < prursg.Bootstrap.BaseBootstrapAlgorithm   
%% How to Use the Class
%
% This class inherits the properties and methods from the parent class |[BaseBootstrapAlgorithm]|.
%
% It contains two methods, one is |[Bootstrap]| and the other is |[Calibrate]|.
%
% New properties have been defined and the default method |[Bootstrap]| has been
% overwritten.
%
% The re-defined |[Bootstrap]| method adjust the input point/curve by |[scalaradj]|
% using the operation given in |[scalarAdjOperation]|.
%
% Method |[Calibrate]| calibrates parameters which are then used in
% bootstrap methods. 
% We have not created a calibrate method.
%
%% Properties
%
% *Input Data Series*
%
% *|[InputDataSeries]|* - Data series to be adjusted.
%
% _Data Type_: data series
%
% *Input Parameters*
% 
% *|[scalaradj]|* - The numerical amount to adjust by
%
% _Data Type_: scalar
%
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
% _Data Type_: string 
%
% *|[scalarAdjOperation]|* - Operation used to make the adjustment; "+", "-",
% "*", "/" or "^".
%
% _Data Type_: string
%
% *|[scalarAdjMethod]|* - the way that input dataseries is adjusted for the 
% scalar amount: "point" or "curve". i.e. scalar added to a point or a curve
%
% _Data Type_: string
%
% *|[scalarAdjIndexAxis]|* - when input dataseries contain an index, the axis 
% value of the index needs to be specified, e.g. for a credit index, the axis 
% can be "spread", "yield", "OAS" etc.
%
% _Data Type_: string
% 
% *|[scalarAdjCurveTerm]|* -when method involves operation on point data and 
% the point needs to be taken from a curve, the corresponding term/maturity 
% of the point on the curve needs to be specified, e.g. "3", "10"
%
% _Data Type_: scalar
%
% *|[RateSpecification]|* - specifies the type, the compounding method and 
% frequency of the output
%
% _Data Type_: string
%
% *|[tolerance]|* - permissible limit of variation, $0.01$
%
% _Data Type_: scalar
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
      
      % Data Series            
        InputDataSeries  

      % Parameters 
        scalaradj
        outputfreq 
        scalarAdjOperation 
        scalarAdjMethod
        scalarAdjIndexAxis
        scalarAdjCurveTerm
        RateSpecification
        
        tolerance = 1E-02
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[Bootstrap()]|* - Function returns an adjusted data series
% by a applying a global operation, specified in |[scalarAdjOperation]|, 
% of magnitude |[scalaradj]|.
%
%%
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 methods       
    % Constructor
    
    function obj = bootstrap_ScalarAdj ()
            obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of Methods
%
% *_Description_*
%
% Function adjusts input data series by the quantity |[scalaradj]| using 
% the operation specified in, |[scalarAdjOperation]|. 
% 
% *_Inputs_*
%
% *|[DataSeriesIn]|* - one data series, can be in the form of a yield curve,
% a credit index or a point data
% 
% _Data Type_: 1-dim array
%
% *_Outputs_*
%
% Adjusted version of original data series.
%
% _Data Type_: 1-dim array
%
% *_Calculations_*
%
% Process the |[DataSeriesIn]| depending on the |[scalarAdjMethod]|.
%
% If "point", extract the point value from the |[DataSeriesIn]|, be it a 
% yield curve, a credit index or a point data, and clone the input data structure; 

% If "curve", sort and clone the input data.
% Identify and set up the output frequency profile which specifies the
% frequency of outputs e.g. annually or monthly etc.
%
% Once data is ready, apply the scalar adjustment using the operation 
% specified in |[scalarAdjOperation]|.  
%
% Update data series properties - including changing data units to "absolute"
%
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
  function results = Bootstrap(obj, DataSeriesIn)

    inumberOfDates = size(DataSeriesIn.dates,1);
    results = DataSeriesIn.Clone;
    
    
    RateTypeIndices = find(obj.RateSpecification == '_');
    RateSpecification = {obj.RateSpecification(1:RateTypeIndices(1)-1), ...
     obj.RateSpecification((RateTypeIndices(1)+1):RateTypeIndices(2)-1), ...
     obj.RateSpecification((RateTypeIndices(2)+1):end)};

    if strcmp(obj.scalarAdjMethod, 'point')        

           for i = 1 : inumberOfDates
               if strcmp(DataSeriesIn.dataseries_type,'bond_index')
                   results.values{i} = DataSeriesIn.values{i}...
                      (strmatch(obj.scalarAdjIndexAxis, ...
                      DataSeriesIn.axes.values));
               elseif strcmp(DataSeriesIn.dataseries_type, 'point')
                   results.values{i} = DataSeriesIn.values{i}(1);
               elseif strcmp(DataSeriesIn.dataseries_type, 'curve')
                   results.values{i} = DataSeriesIn.values{i}(find ...
                       (str2num(obj.scalarAdjCurveTerm) - obj.tolerance ...
                       < cell2mat(DataSeriesIn.axes.values) ...
                       & cell2mat(DataSeriesIn.axes.values) ...
                       < str2num(obj.scalarAdjCurveTerm) + obj.tolerance));
               end
               
                % convert units to absolute values
               if strcmp(DataSeriesIn.dataseries_type,'bond_index')      
                   unitsVector = strread (DataSeriesIn.units, ...
                       '%s', 'delimiter', ',');
                   units = unitsVector(strmatch(obj.scalarAdjIndexAxis,...
                       {'Index Value' 'yield' 'duration' 'convexity' ...
                       'spread' 'OAS'}));
               else units = DataSeriesIn.units;
               end
               
               if strcmp(units,'percent')
                   results.values{i} = results.values{i} /100;
               elseif strcmp(units,'bps')
                   results.values{i} =results.values{i} /10000;
               end

           end
           
        results.units ='absolute';
        results.axes.values = {obj.scalarAdjIndexAxis};
        results.dataseries_type = 'point';
    end

    
    
    if strcmp(obj.scalarAdjMethod, 'curve')
        newSortDataSeries=Bootstrap.BsSort();
        obj.InputDataSeries = newSortDataSeries.SortDataSeries...
            (DataSeriesIn.Clone);
        
        if ~strcmp (lower(obj.outputfreq), 'default')
            
            maxTerm = obj.InputDataSeries.axes(1).values{1, end};
            BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                (obj.outputfreq,maxTerm);
            outputfreqProfile = ...
                BsfrequencyprofileObject.AdjustedIntervalArray;
            
            results = BsfrequencyprofileObject.SmallerDataSeriesObject...
                (outputfreqProfile,obj.InputDataSeries);
        end
          
         for i = 1 : inumberOfDates
             if strcmp(results.units,'percent')
                 results.values{i} = results.values{i} /100;
             elseif strcmp(results.units,'bps')
                 results.values{i} =results.values{i} /10000;
             end
         end 
         
        results.units ='absolute';       
        results.dataseries_type = 'curve';       
        results.ratetype = RateSpecification{1};
        results.compounding = RateSpecification{2};
        results.compoundingfrequency = RateSpecification{3};
    end
    

    for i = 1 : inumberOfDates
        if strcmp(obj.scalarAdjOperation, '+')
            results.values{i} = results.values{i} + obj.scalaradj;
        elseif strcmp(obj.scalarAdjOperation, '-')
            results.values{i} = results.values{i}- obj.scalaradj;
        elseif strcmp(obj.scalarAdjOperation, '*')
            results.values{i} = results.values{i} .* obj.scalaradj;
        elseif strcmp(obj.scalarAdjOperation, '/')
            results.values{i} = results.values{i} ./ obj.scalaradj;            
        elseif strcmp(obj.scalarAdjOperation, '^')    
            results.values{i} = results.values{i} .^ obj.scalaradj;
        end
    end

    results.Name = '';
    results.source ='iMDP';
    results.description = 'derived using bootstrap_ScalarAdj method';
    

  end

 end
    
end

