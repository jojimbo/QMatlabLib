%% Data Adjustment
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
% Given an input data series we adjust it using the values given in
% *|[InputAdjDataSeries]|* and the operation given in *|[operation]|*.

%% Properties
% *Input Data Series*
%
% *|[InputAdjDataSeries]|* - Data series used to adjust the 
% input data series.
% 
%  Data Type: data series
%
% *Input Parameters*
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

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    properties
       
      % Data Series            
        InputAdjDataSeries  = []; 

      
      % Parameters 
       
        outputfreq ; 
        operation ;  
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This class introduces one method:
%
% *|[bootstrap_DataAdj ()]|* - Function returns an adjusted data series by acting on the input data
% series with an adjustment series by a simple operation specified in
% *|[operation]|*.
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
% series with *|[InputAdjDataSeries]|* by a simple operation 
% specified by *|[operation]|*
%
% *_Inputs_*
%
% *|[InputAdjDataSeries]|* - Data series used to adjust the 
% input data series.
% 
%  Data Type: data series
%
% *|[outputfreq]|* - Time series used to produce a frequency profile.
%
%  Data Type: string 
%
% *|[operation]|* - Operation used to make the adjustment; "+", "-", "*"
% or "/".
%
%  Data Type: string
%
% *_Outputs_*
%
% Adjusted version of original data series.
%
% *_Calculations_*
%
% Sort and clone data.
%
% Ensure that data series fits in with the output frequency profile.
%
% Apply the adjustment data series with the operation specified in *|[operation]|*.  
%
% Update data series properties.

%% 
%MATLAB Code     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        function results = Bootstrap(obj, DataSeriesIn)                     
             
             numOfDataSeries = size(DataSeriesIn,2);
           
            
             newSortDataSeries=Bootstrap.BsSort();         
                         
             obj.InputAdjDataSeries = newSortDataSeries.SortDataSeries...
                 (DataSeriesIn(1).Clone);
            for i =2 : numOfDataSeries
                 obj.InputAdjDataSeries = ...
                     [obj.InputAdjDataSeries ...
                     newSortDataSeries.SortDataSeries...
                     (DataSeriesIn(i).Clone)];                
            end    
            
             maxTerm = obj.InputAdjDataSeries(1).axes(1).values{1, end};                         
             
             BsfrequencyprofileObject =Bootstrap.Bsfrequencyprofile...
                 (obj.outputfreq,maxTerm);
             outputfreqProfile = ...
                 BsfrequencyprofileObject.AdjustedIntervalArray;
           
            
             for storing the dataseries objects
            for i =1:numOfDataSeries
                InputAdjDataSeries_Temp(i) = ...
                    BsfrequencyprofileObject.SmallerDataSeriesObject...
                    (outputfreqProfile,obj.InputAdjDataSeries(1,i));
            end
             
                
               results = InputAdjDataSeries_Temp(1) ;        
               
               for i = 2 : numOfDataSeries
                   for j = 1 : size(results.dates, 1)
                       
                       if strcmp(obj.operation, '+')
                           results.values{j} = results.values{j} + ...
                               InputAdjDataSeries_Temp(i).values{j};
                       elseif strcmp(obj.operation, '-')
                           results.values{j} =  results.values{j} - ...
                               InputAdjDataSeries_Temp(i).values{j};
                       elseif strcmp(obj.operation, '*')
                           results.values{j} = results.values{j} .* ...
                               InputAdjDataSeries_Temp(i).values{j};
                       elseif strcmp(obj.operation, '/')
                           results.values{j} = results.values{j} ./ ...
                               InputAdjDataSeries_Temp(i).values{j};
                       end
                   end
               end
               
          
            
           results.Name = '';
           results.source ='iMDP';         
           results.description = 'derived using bootstrap_DataAdj method';
          
             
        end

    end
    
end

