%% GEN LOG NORMAL MINUS 1
% *PruRSG Engine Model  - Models Log Normal - 1 Distributed Values*
% 
% 
% *The GenLogNormalmin1 class returns a vector of Log Normal distributed
% values, with 1 subtracted from the returned value.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GenLognormalmin1 < prursg.Engine.Model          
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
        mu = [];
        sigma = [];
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% List of Methods
% This model class has the following methods:
%
% *|1) [calibrate()]|* - fit $\mu , \sigma$ using least squares minimisation - returns 1 (success)
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
        function obj = GenLognormalmin1()
            % Constructor
            obj = obj@prursg.Engine.Model('GenLognormalmin1');
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
% The calibrate method estimates values for the parameters $\hat \mu$ and
% $\hat \sigma$ by minimising the cost function, $v$, where 
%
% $v = \sum_{i=1}^N (t_i- [e^{ \hat \mu + \frac{1}{2}\hat \sigma^2}-1])^2$
%
% subject to $\hat \sigma \geq 0$,
% where $q_ = Quant$ is a vector of the $N$ quantiles and $t = Target$ is a vector of the corresponding $N$ target values for the distribution.
%
        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		%assign starting values
		for i = 1:length(calibParamTargets)	
			if strcmp(calibParamNames{i}, 'mean')
				%we can assign a close value for mu
				% x0(1) = log(calibParamTargets{i}-1);
                x0(1) = calibParamTargets{i};
			else
				x0(2) = 1; %start sigma at 1
			end
		end
		%thus now have x0

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+0.5*x(2)^2)-1))^2;
				else
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+x(2)*norminv(str2num(calibParamNames{i}),0,1))-1))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
        % this seems to work much better than contrained optimiser
        y = fminunc(@ourfunc,[0 1]);
		% y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);
        % y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0],[],[],[],[],[],optimset('MaxIter',50000,'TolFun',1e-10));

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
% The simulate method calculates Log Normal distributed values -1, based on the parameters $\mu$ and $\sigma$.
% It returns a vector of random
% variates as the variable _series_, calculated as 
% 
% $S = e^{\mu+\sigma z}-1$
%
%
% *Inputs*
%
% *_None_*
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
            series = exp(corrNumElements*obj.sigma + obj.mu) - 1;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end
