classdef bootstrap_EqDamp < handle
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     % Enter Description
     properties
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Data Series
         EqLevel = [];
         
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Parameters
         
         AvgPeriod = [];
         Adj = [];
         Proportion = [];
         DayConvention = [];
         UpperBound = [];
         LowerBound = [];
         
     end
    
    methods
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Constructor
    
       function obj = bootstrap_EqDamp ()
           
       end
                  
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find Symmetrical Adjustment (SA) Value
    
        function results = bs(obj, DataSeriesIn, ParametersIn)
            
            obj.EqLevel = DataSeriesIn;
            
            obj.AvgPeriod = ParametersIn{1};
            obj.Adj = ParametersIn{2};
            obj.Proportion = ParametersIn{3};
            obj.DayConvention = ParametersIn{4};
            obj.UpperBound = ParametersIn{5};
            obj.LowerBound = ParametersIn{6};
            
            results = obj.EqLevel; % set up results structure
            
            AvgDays = obj.AvgPeriod*obj.DayConvention;
            AI = mean(cat(1,obj.EqLevel.values{1:AvgDays}));
            CI = obj.EqLevel.values{1};
            
            SA = min(max(obj.Proportion * ((CI - AI) / AI - obj.Adj), obj.LowerBound), obj.UpperBound);           
            
            results.values = num2cell(SA);
            results.dates = obj.EqLevel.dates(1);
        end 

    end
    
end

