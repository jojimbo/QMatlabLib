%% GEN BETA
% *PruRSG Engine Model  - Models Generalised Beta Distributed Values*
% 
% 
% *The GenBeta class returns a vector of Generalised Beta distributed
% values.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GenBeta < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[alpha]|* -  $\alpha$ shape parameter
% 
% *|[beta]|* -  $\beta$ shape parameter
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
        alpha = [];
        beta = [];
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
% *|4) [simulate()]|* - returns the Generalised Beta distributed values given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = GenBeta(initValue, parameters )
            % Constructor
            obj = obj@prursg.Engine.Model('GenBeta');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % not implemented
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
% The simulate method calculates Generalised Beta distributed values based on the $\alpha$, $\beta$, $\mu$ and $\sigma$.
% It returns a vector of random
% variates as the variable _series_, calculated as 
% 
% $S = (\mu+\sigma \times \beta^{-1}(\phi(z), \alpha , \beta))$
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
% -  Shape parameter, $\alpha$, passed in via _obj.alpha_
%
% -  Shape parameter, $\beta$, passed in via _obj.beta_
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
% A vector of Generalised Beta distributed values, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)
            series = obj.mu + obj.sigma * betainv(normcdf(corrNumElements),obj.alpha,obj.beta);
            
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

