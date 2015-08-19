%% Equity Dampener
% *The class returns a symmetric adjustment parameter for the equity charge 
% (currently, only applicable for the standard formula). The equity 
% dampener is designed to prevent/reduce procyclical behaviour such that 
% insurance companies are forced to sell their equities in a downturn 
% leading to further market falls*
%
%
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef bootstrap_EqDamp < prursg.Bootstrap.BaseBootstrapAlgorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% How to use the class     
% There is one way to use this class:
%
% # To produce a symmetric adjustment parameter used to prevent/reduce
% procyclical behaviour.
%
%% Properties
%
%
% *|[EqLevel]|* : Equity level data series.
%
%  Data type : double array
%
% *|[AvgPeriod]|* : The period (in years) for which the mean equity level
% is taken.
%
%  Data type : double
%
% *|[Adj]|* : Base rate assumption.
%
%  Data type : double
%
% *|[Proportion]|* : Proportionality constant.
%
%  Data type : double
%
% *|[DayConvention]|* : The number of working days per calendar year, used
% to adjust for data only being available on week days.
%
%  Data type : double
%
% *|[UpperBound]|* : The upper bound of acceptable values of the symmetric
% adjustment parameter.
%
%  Data type : double
%
% *|[LowerBound]|* : The lower bound of acceptable values of the symmetric
% adjustment parameter.
%
%  Data type : double
%         
%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     properties
         
         % Data Series
         EqLevel
         
         
         % Parameters
         
         edAvgMonth
         edAdj
         edProportion
         edDayPerMonth
         edUpperBound
         edLowerBound
         
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% List of Methods
% The class introduces one new method:
%
% *|1)[bootstrap_EqDamp()]|* - Function returns a symmetric adjustment 
% parameter used to compensate for cyclical behaviour in the equity capital 
% charge.
%
%%
%MATLBAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
    % Constructor
    
       function obj = bootstrap_EqDamp ()
           obj = obj@prursg.Bootstrap.BaseBootstrapAlgorithm();
       end
       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Details of methods
%
% *1) |[bootstrap_EqDamp()]|*
%
% """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
%
% *_Description_*
%
% Function returns a symmetric adjustment parameter used to compensate for 
% cyclical behaviour in the equity capital charge.
%
% *_Inputs_*
%
% *|[EqLevel]|* : Equity level data series.
%
%  Data type : double array
%
% *|[AvgPeriod]|* : The period (in years) for which the mean equity level
% is taken.
%
%  Data type : double
%
% *|[Adj]|* : Base rate assumption.
%
%  Data type : double
%
% *|[Proportion]|* : Proportionality constant.
%
%  Data type : double
%
% *|[DayConvention]|* : The number of working days per calendar year, used
% to adjust for data only being available on week days.
%
%  Data type : double
%
% *|[UpperBound]|* : The upper bound of acceptable values of the symmetric
% adjustment parameter.
%
%  Data type : double
%
% *|[LowerBound]|* : The lower bound of acceptable values of the symmetric
% adjustment parameter.
%
%  Data type : double
%
% *_Outputs_*
%
% A symmetric adjustment parameter used to compensate for 
% cyclical behaviour in the equity capital charge.
%
% *_Calculations_*
%
% The function calculates the symmetric adjustment parameter using the
% formula below:
%
% $$ S=Max\left[Min\left[P\left(\frac{CI-AI}{AI} - BR\right), UB\right], LB\right]$$
%
% with,
%
% $CI$ : Latest equity level.
%
% $AI$ : Mean equity level.
%
% $BR$ : Base return assumption.
%
% $P$ : Proportionality constant.
%
% $UB$ : Upper bound
%
% $LB$ : Lower bound
%
% If the symmetric adjustment parameter is outside the upper or lower bound
% imposed on it , the upper or lower bound value is returned instead.
%
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Find Symmetrical Adjustment (SA) Value
    
        function results = Bootstrap(obj, DataSeriesIn)
            
            results = DataSeriesIn.Clone;   
            dateIndexMatrix = cell2mat([num2cell(datenum(DataSeriesIn.dates)) DataSeriesIn.values]);
            dimension = 1;
            newSortDataSeries=Bootstrap.BsSort(); 
            reverseDateIndexMatrix =newSortDataSeries.reverseOrder(dateIndexMatrix, dimension);
            
            results.dates = cellstr(datestr(reverseDateIndexMatrix(:,1)));
            results.values = reverseDateIndexMatrix(:,2);
            
            % number of days over which the Average is taken
            AvgDays = obj.edAvgMonth * obj.edDayPerMonth;
            % Average Index level
            AI = mean(results.values(1:AvgDays));
            % Current Index level
            CI = results.values(1);
            
            % calc of symetric adjustment
            SA = min(max(obj.edProportion * ((CI - AI) / AI - obj.edAdj),...
                obj.edLowerBound), obj.edUpperBound);           
            
            results.values = num2cell(SA);
            results.dates = results.dates(1);
            results.Name = '';
            results.source ='iMDP';
            results.ticker= 'na';
            results.description = 'derived EqDamp method';

            
        end 

    end
    
end

