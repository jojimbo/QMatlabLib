%% EMPIRICAL
% *PruRSG Engine Model  - Models Empirical Distribution*
% 
% 
% *The Empirical class returns a vector of values which are linearly interpolated 
% from the table of percentiles and corresponding values*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Empirical < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% NONE
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters        
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% List of Methods
% This model class has the following methods:
%
% *|1) [calibrate()]|* - not implemeted - returns 1 (success)
%
% *|2) [getNumberOfStocasticInputs()]|* - returns the number of stochastic
% inputs (1 for this distribution)
%
% *|3) [getNumberOfStochasticOutputs()]|* - - returns the number of stochastic
% outputs (the same as the number of initial values)
%
% *|4) [simulate()]|* - returns the empirical distribution
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = Empirical()
            % Constructor
            obj = obj@prursg.Engine.Model('Empirical');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)		
            %success
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
 
%%
% _________________________________________________________________________________________
%
%%  simulate
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The simulate method calculates a loss value by transforming the standard variate, *z*, to 
% a uniform distribution to give a quantile output, then using that to linearly interpolate
% the loss from the table of quantiles and corresponding losses attached to
% the model. Note that values outside the range defined in quantiles will
% be linearly extrapolated.
%
%
%% *Inputs*
%
% *_percentiles_*
%
% -  A vector of quantiles in the range 0-1 specifying the points at which
% the loss distribution is calibrated, passed in as
% _obj.calibrationTargets.percentile_
%
% *_values_*
%
% -  A vector of the loss values corresponding to the percentiles defined
% in _obj.calibrationTargets.percentile_, passed in as
% _obj.calibrationTargets.value_
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of Empirical loss values, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)
            %Load calibration parameters (empirical calibration targets and
            %values are just the model parameters and values
            calibTargets = obj.calibrationTargets;
            for j = 1:length(calibTargets)
                percentiles{j} = calibTargets(j).percentile;
                values{j} = calibTargets(j).value;
            end
            percentiles = str2double(percentiles); %array of percentiles
            values = cell2mat(values);             %array of values
            u = normcdf(corrNumElements);
            
            series = interp1(percentiles,values,u,'linear','extrap');
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end



