%% Frequency profile
% *The class converts an input frequency string to a frequency profile; an
% array of integers which indicate the number of monthly, quarterly,
% semi-annual and annual intervals contained in the output data series.*
%
% *The class also contains functions to:*
% 
% * *Extend a frequency profile up to a maximum term.*
% * *Return an array of output dates.*
% * *Crop a data series to include only certain specified elements.*
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Bsfrequencyprofile < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% How to use the class
% There is are three ways to use this class:
%
% # To produce a frequency profile from an input frequency string. This can
% be extended up to a maximum term if desired.
% # To produce an array of output maturities from a given frequency profile.
% # To produce a cropped data series containing only specified maturities
% from a larger input data series.
%
%% Properties
%
% *|[interval]|* : An object set up to store the number of outputs with 
% monthly, quarterly, semi-annual and annual separations.
%
%  Data type : -
%
% *|[maxterm]|* : The maximum term to be specified in the frequency profile
% , in years. This has a default value of 135.
%
%  Data type : double
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Creates a frequency profile based on an string format
    
    properties
      interval = [];  
      maxterm  = 135;  % Default Value
    end
           

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of methods
% The class introduces four new methods:
%
% *|1)[Bsfrequencyprofile()]|* - Function converts an input frequency 
% string to a frequency profile; an object of integers which indicates the 
% number of monthly, quarterly, semi-annual and annual intervals.
%
% *|2)[AdjustedIntervalArray()]|* - Function returns a data series
% containing the maturities as specified.
% 
% *|3)[AdjustedIntervalCount()]|* - Function returns an adjusted
% frequency profile such that the cumulative term extends up to the 
% *|maxterm|*.
% 
% *|4)[SmallerDataSeriesObject()]|* - Function returns  a reduced data
% series object with only the values specified in *|AxesArraytoMatch|*.
%
%
%% Details of methods
%
% *1) |[Bsfrequencyprofile()]|*
%
% """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% The function converts an input frequency string to a frequency profile; 
% an object of integers which indicates the number of monthly, quarterly,
% semi-annual and annual intervals.
%
% *_Inputs_*
%
% *|[frequencystring()]|* : cvs string containing the number of monthly, 
% quarterly, semi-annual and annual intervals.
%
%  Data type : string
%
% *|[maxterm]|* : The maximum term to be specified in the frequency profile
% in years. This has a default value of 135.
%
%  Data type : double
%
% *_Outputs_*
%
% An object of integers which indicates the number of monthly, quarterly,
% semi-annual and annual intervals. It also holds the maximum term 
% required, which has a default of 135 years.
%
% *_Calculations_*
%
% The function converts the input frequency string to an object of integers
% which indicates the number of monthly, quarterly, semi-annual and annual 
% intervals. The object created also holds the maximum term required, which
% has a default of 135 years.
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
  
   % Constructor       
        function obj = Bsfrequencyprofile(frequencystring,maxterm)
            % Set the frequency for each interval   
            obj.interval(1,2) = 1/12;       % Months
            obj.interval(2,2) = 1/4;     % Quarters
            obj.interval(3,2) = 1/2;  % Halfyears 
            obj.interval(4,2) = 1;      % Years 
            
            if ~isempty(frequencystring)            
             Pos = findstr(frequencystring,',');            
            % Extract M, Q, SA, & A profile from string
               obj.interval(1,1) = str2num(frequencystring(1:Pos(1)-1));       
               obj.interval(2,1) = str2num(frequencystring(Pos(1)+1:Pos(2)));  
               obj.interval(3,1) = str2num(frequencystring(Pos(2)+1:Pos(3)));  
               obj.interval(4,1) = str2num(frequencystring(Pos(3)+1:...
                   length(frequencystring)));      
           
            else
               obj.interval(1,1) = 0;       % Months
               obj.interval(2,1) = 0;     % Quarters
               obj.interval(3,1) = 0;  % Halfyears 
               obj.interval(4,1) = 1;      % Years 
            end    
           if ~isempty(maxterm)      
             obj.maxterm =maxterm;
           end  
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%% 
%
% *2) |[AdjustedIntervalCount()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns an adjusted frequency profile such that the outputs
% extend up to the *|maxterm|*. 
%
% *_Inputs_*
%
% *|[interval]|* : An array of integers and doubles which indicates the 
% number of outputs separated by monthly, quarterly, semi-annual and annual 
% intervals.  
%
%  Data type : double and integer array
%
% *|[maxterm]|* : The maximum term to be specified in the frequency profile
% , in years. This has  default value of 135.
%
%  Data type : double
%
% *_Outputs_*
%
% An adjusted frequency profile such that the outputs extend to the 
% *|maxterm|*. 
%
% *_Calculations_*
%
% If the cumulative maturity is less than the *|maxterm|*, then the number
% of the largest, specified (i.e. number of intervals is non-zero),
% interval (e.g quarterly, semi-annually etc.) is increased until the
% *|maxterm|* is reached.
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Adjust intervals allowing for maxterm    
 
        function y = AdjustedIntervalCount(obj)            
                   
                y = obj.interval;
                 MaxMonths = ceil(obj.maxterm/y(1,2));                 

                       for i = 1 : size( obj.interval ,1)
                           sum1 = 0;
                         for j= 1 : size( obj.interval ,1)  
                                 if ne(j,i)
                                   sum1 =  sum1 + obj.interval(j,1);
                                 end
                         end                                                   
                         
                         if sum1 == 0 
                             y(i,1) = max(obj.interval(i,1), ...
                                 obj.maxterm/y(i,2));                             
                         else
                              sum2 = 0;
                             for j= i+1 : size( obj.interval ,1)  
                                 if ne(j,i)
                                   sum2 =  sum2 + obj.interval(j,1);
                                 end
                              end
                             
                                                          
                              maxRemainingInterval= max(0, ...
                                  MaxMonths*y(1,2)/y(i,2));
                              
                             if sum2 == 0
                                  y(i,1)=  maxRemainingInterval;
                             else
                                  y(i,1)=  min(y(i,1), ...
                                      maxRemainingInterval); 
                             end
                                                          
                         end    
                            y(i,1)= ceil(y(i,1));  
                            
                            % Calculate the residual number of months                            
                            MaxMonths = MaxMonths - y(i,1)*...
                                (y(i,2)/obj.interval(1,2));                            
                       
                       end
                          
                return 
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%
% *1) |[AdjustedIntervalArray()]|*
%
% """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns a data series containing the maturities of the required 
% outputs.
%
% *_Inputs_*
%
% *|[interval]|* : An array of integers which indicates the number of
% monthly, quarterly, semi-annual and annual intervals.  
%
%  Data type : double and integer array
%
% *|[maxterm]|* : The maximum term to be specified in the frequency profile
% in years. This has a default value of 135.
%
%  Data type : double
%
% *_Outputs_*
%
% An array containing output timings.
%
% *_Calculations_*
%
% The function, initially adjusts the input frequency profile to
% incorporate the maximum term using *|AdjustedIntervalCount()|*.
% 
% An array containing the output maturities is then created from the 
% adjusted frequency profile. The timings are created in increasing size 
% order. So for a frequency string of '1,2,4,6' (months, quarters, 
% semi-annual, annual) the first timing would be after a month, the second
% after a month plus a quarter, the third after a month an two quarters and
% so on.
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Interval Array
 
     function z = AdjustedIntervalArray(obj)
                  
         AdjustedCounts = AdjustedIntervalCount(obj) ;
         aux = sum(AdjustedCounts,1);
         z = zeros (aux(1),1);
              
          % Calculate incremental profile
          count = 0;                  
           for i = 1 :  size(AdjustedCounts ,1)
               for j = 1 : AdjustedCounts(i,1)
                   count = count +1;
                  z(count) = AdjustedCounts(i,2);
               end    
           end
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Calculate cumulative profile
            
          for i = 2 :  size(z ,1)
              z(i) = z(i-1) + z(i);
          end    
           
          return
     end    
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%
% *1) |[SmallerDataSeriesObject()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns a reduced data series object with only the values
% specified in *|AxesArraytoMatch|*.
%
% *_Inputs_*
%
% *|[AxesArraytoMatch]|* : Data series containing the specific maturities
% of the desired outputs.
%
%  Data type : double array
% 
% *|[DataSeriesObject]|* : The original data series to be cut down to
% contain just the values specified in *|AxesArraytoMatch|*.
%
% *_Outputs_*
%
% A cut down version of the original *|DataSeriesObject|* including only
% the values specified in *|AxesArraytoMatch|*.
%
% *_Calculations_*
%
% The function searches the original data series for axis values that are
% within the *|SearchTolerance|* of axis values specified in 
% *|AxesArraytoMatch|*. Axis values that adhere to this criterion are
% copied into an output data series.
%
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Create a cut down dataseriesobjected based on the adjusted interval array
 % Search is over all three axes - axes are assumed to be numeric
     
    function newDataSeriesObject = SmallerDataSeriesObject(obj, ...
            AxesArraytoMatch, DataSeriesObject)
                      
          % Create New Dataseries object
          newDataSeriesObject = DataSeriesObject.Clone;      
          
          % Calculate incremental profile         
          SearchStartIndex = 1;          
          SearchTolerance = 1/250; % Tolerance within one business day
          
          axisvalues = cell2mat(DataSeriesObject.axes(1).values);
           NewValues = cell( size(DataSeriesObject.dates, 1));
          
           for i = 1 :  size(AxesArraytoMatch, 1)
               SearchItem = AxesArraytoMatch(i , 1 : ...
                   size(AxesArraytoMatch, 2));
               % SearchEndIndex = size(cell2mat(DataSeriesObject.values{1}),2);
               SearchEndIndex = size(cell2mat(DataSeriesObject.values),2);
               
               for j = SearchStartIndex : SearchEndIndex                 
                    
                    % sum1 = sqrt(   sum((SearchItem - axisvalues(:,j)).^2) );
                    sum1 = abs(SearchItem - axisvalues(j));
                   
                  if sum1 < SearchTolerance
                      SearchStartIndex= j+1;
                      SearchEndIndex = j;                         
                      for k = 1 : size(DataSeriesObject.dates, 1)
                        %values = cell2mat(DataSeriesObject.values{k});
                        values = DataSeriesObject.values{k};
                        NewValues{k}(i) = values(j); 
                      end 
                      
                      
                 end                     
               end    
           end
          
             for k = 1 : size(DataSeriesObject.dates, 1)
                  newDataSeriesObject.values{k} =NewValues{k} ;
             end   
           
               for i = 1 : size(DataSeriesObject.axes,1)
                newDataSeriesObject.axes(i).values = ...
                    num2cell(AxesArraytoMatch(:,i)');
               end  
%          
%                     
%           import prursg.Engine.*;
%             allAxis = [];
%            for i = 1 : size(DataSeriesObject.axes,1)
%                 axis = Axis();
%                 axis.title = DataSeriesObject.axes(i).title;
%                 axis.values = AxesArraytoMatch(:,i);
%                 allAxis = [allAxis axis];           
%            end   
%                             
%             dataObj = DataSeries();
%             dataObj.axes = allAxis;
%             dataObj.values = NewValues;
%             dataObj.dates = DataSeriesObject.dates;
%             
%             z  = dataObj;
           
          return
     end    
     
     
     
     
    end
    
end



