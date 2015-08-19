%% FX LOG NORMAL
% *PruRSG Engine Model  - Models Log Normal Distributed FX Values*
% 
% 
% *The FxLogNormal class returns a vector of Log Normal distributed FX
% values.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef FXLognormal < prursg.Engine.Model          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
%
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ scale parameter
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        sigma = [];
        mu = [];
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% List of Methods
% This model class has the following methods:
%
% *|1) [calibrate()]|* - estimates the volatility of the FX rate, $\hat \sigma$, - returns 1 (success)
%
% *|2) [getNumberOfStocasticInputs()]|* - returns the number of stochastic
% inputs (1 for this distribution)
%
% *|3) [getNumberOfStochasticOutputs()]|* - - returns the number of stochastic
% outputs (1 for this distribution)
%
% *|4) [simulate()]|* - returns Log Normally distributed values given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = FXLognormal()
            % Constructor
            obj = obj@prursg.Engine.Model('FXLognormal');
        end
%%
% _________________________________________________________________________________________
%
%% calibrate
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The calibrate method estimates values for the parameter 
% $\hat \sigma$ by calculating a log return 
%
% $r_i = \ln \frac{y_i}{y_{i+1}}$
% 
% subtracting the mean return, $\bar r$
%
% $\hat r = r - \bar r$ 
% 
% and then taking the standard deviation of $\hat r$ and converting to a
% monthly standard deviation, $\hat \sigma$
%
% $\hat \sigma = sd(\hat r) \sqrt {12}$
% 
        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            %get data from dataObj
            y = dataObj{1}.getDataByName();

            %get log returns
            logreturn = zeros(1, length(y) - 1);
            for i = 1:length(y)-1
                logreturn(i)=log(y(i)/y(i+1));
            end
            logreturn = logreturn - mean(logreturn); % de-mean returns
            obj.sigma = std(logreturn)*sqrt(12); %assuming we have monthly data

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
% The simulate method calculates Log Normal distributed values based on the parameters $\mu$ and $\sigma$.
% It returns a vector of random
% variates as the variable _series_, calculated as 
% 
% $S = init.e^{\mu+\sigma \sqrt {t} z}$
%
% where _t_ is the number of samples per year of the data, which is set to 1.
%
%
% *Inputs*
%
% *_Initial Value_* init
%
%
%
% *_Precedents_*
%
% *_None_*
%
%
% *_Distribution Parameters_*
%
% -  Location parameter, $\mu$, passed in via _obj.mu_
%
% -  Scale parameter, $\sigma$, passed in via _obj.sigma_
%
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
% *Outputs*
%
% A vector of Log Normal distributed values, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements) 
            t = 1; %annual data - t = 1/year
            series = obj.initialValue.values{1} * exp(obj.mu + obj.sigma*sqrt(t)*corrNumElements);
        end
        
        function s = validateCalibration(obj)
            s = 'Not implemented';
        end
        
    end
end

