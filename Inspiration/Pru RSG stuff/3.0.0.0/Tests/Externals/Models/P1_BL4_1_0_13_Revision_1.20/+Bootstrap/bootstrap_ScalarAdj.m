%% Scalar Adjustment
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
% Given an input data series we globally adjust the values by *|[scalaradj]|* using the operation given in *|[operation]|*.

%% Properties
% *Input Data Series*
%
% *|[InputDataSeries]|* - Data series to be adjusted.
%
%  Data Type: data series
%
% *Input Parameters*
% 
% *|[scalaradj]|* - The numerical amount to adjust by.
%
%  Data Type: double
%
% *|[outputfreq]|* - A string that lists the number of monthly, quarterly, 
% semi-annual and annual intervals.
%
%  Data Type: string 
%
% *|[operation]|* - Operation used to make the adjustment; "+", "-", "*"
% or "/".
%
%  Data Type: string
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
      
      % Data Series            
        InputDataSeries  = [];  

      
      % Parameters 
        scalaradj ;
        outputfreq ; 
        operation ; 
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[bootstrap_ScalarAdj ()]|* - Function returns an adjusted data series
% by a applying a global operation, specified in *|[operation]|*, of magnitude *|[scalaradj]|*.
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
% Function returns an adjusted data series by acting globally on the *|[InputDataSeries]|* by the quantity 
% *|[scalaradj]|* using the operation specified in, *|[operation]|*. 
% 
% *_Inputs_*
%
% *|[InputDataSeries]|* - Data series to be adjusted.
%
%  Type: data series
% 
% *|[scalaradj]|* - The numerical amount to adjust by.
%
%  Type: double
%
% *|[outputfreq]|* - Time series used to produce a frequency profile.
%
%  Type: string 
%
% *|[operation]|* - Operation used to make the adjustment; "+", "-", "*"
% or "/".
%
%  Type: string
%
% *_Outputs_*
%
% Adjusted version of original data series.
%
% *_Calculations_*
%
% Sort and clone the input data.
%
% Identify and set up the output frequency profile which specifies the
% frequency of outputs e.g. annually or monthly etc.
%
% Apply the scalar adjustment to the input data series using the operation 
% specified in *|[operation]|*.  
%
% Update data series properties.
%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
        function results = Bootstrap(obj, DataSeriesIn)

           
                       
                         
             newSortDataSeries=Bootstrap.BsSort();
             obj.InputDataSeries = newSortDataSeries.SortDataSeries...
                 (DataSeriesIn.Clone);
                          
            
                         
            maxTerm = obj.InputDataSeries.axes(1).values{1, end};       
            BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                (obj.outputfreq,maxTerm);
            outputfreqProfile = ...
                BsfrequencyprofileObject.AdjustedIntervalArray;

            
            InputDataSeries_Temp = ...
                BsfrequencyprofileObject.SmallerDataSeriesObject...
                (outputfreqProfile,obj.InputDataSeries(1,1));
            

            results = InputDataSeries_Temp;

            for i = 1 : size(results.dates, 1)
                if strcmp(obj.operation, '+')
                    results.values{i} = results.values{i} + obj.scalaradj;
                elseif strcmp(obj.operation, '-')
                    results.values{i} = results.values{i}- obj.scalaradj;
                elseif strcmp(obj.operation, '*')
                    results.values{i} = results.values{i} .* obj.scalaradj;
                elseif strcmp(obj.operation, '/')
                   
                    results.values{i} = obj.scalaradj ./ results.values{i};
                 
                end
            end

           
           results.Name = '';
           results.source ='iMDP';         
           results.description = 'derived using bootstrap_DataAdj method';
           
            
        end

    end
    
end

