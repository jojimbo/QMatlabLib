%% GENNORMAL
% *PruRSG Engine Model*  - Generalised Normal distribution.
%
%
% Returns a vector of Normally distributed variates.
%  


%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GenNormal < prursg.Engine.Model           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ scale parameter
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        mu = [];
        sigma = [];
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
% outputs (1 for this distribution)
%
% *|4) [simulate()]|* - returns the scaled General Normal distributed values given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = GenNormal()
            % Constructor
            obj = obj@prursg.Engine.Model('GenNormal');
        end
%%
% _________________________________________________________________________________________
%
%% calibration
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The calibration method estimates values for the parameters $\hat \mu$ and
% $\hat \sigma$ by minimising the cost function, _v_, where
%
% $v = \sum_{i=1}^N (t_i-\hat \mu + \hat \sigma \phi^-1(q_i))^2$
%
%
%
%% *Inputs*
%
% *_calibParamNames_*
%
% -  A cell array of the values of the quantiles to which the distribution
% is to be fitted, passed as strings.
%
% *_calibParamTargets_*
%
% -  A cell array of the values of the targets corresponding to the
% quantiles.
%
%
%% *Outputs*
%
% _success_flag_ is always returned as 1 if the method completes.
% _obj.mu_ is set to the estimate of $\hat \mu$
% _obj.sigma_ is set to the estimate of $\hat \sigma$

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		% assign starting values
		for i = 1:length(calibParamNames)	
			if strcmp(calibParamNames{i}, 'mean')
				%mu as mean is a (very) good first guess...
				x0(1) = calibParamTargets{i};
			else
				% this is also a good guess for sigma
                % note this line assumes that first initial value assigned
                % already
				%x0(2) = (calibParamTargets{i}-x0(1))/norminv(calibParamTargets{i},0,1);
                x0(2) = 1;
			end
		end

		%thus now have x0 = [mu, sigma] if given two percentiles, mean and a %.  but we may not have been...

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-x(1))^2;
				else
					valu=valu+100*(calibParamTargets{i}-(x(1)+x(2)*norminv(str2num(calibParamNames{i}),0,1)))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
		y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);

		%assign parameters
		obj.mu = y(1);
		obj.sigma = y(2);

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
% The simulate method calculates a Normally distributed value based on the
% standard Normal distribution z and the parameter $\mu$, and multiplies it by $\sigma$.
% It returns a vector of random variates as the variable _series_, calculated as 
% 
% $S = \sigma z + \mu$
%
%
%% *Inputs*
%
% *_Distribution Parameters_*
% 
% -  Location parameter, $\mu$, passed in via _obj.mu_
%
% -  Scale parameter, $\sigma$, passed in via _obj.sigma_
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of Normally distributed variates, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function series = simulate(obj, workerObj, corrNumElements)
            series = corrNumElements*obj.sigma + obj.mu;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

