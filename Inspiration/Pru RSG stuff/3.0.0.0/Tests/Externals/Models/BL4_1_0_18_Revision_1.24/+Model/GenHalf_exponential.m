%% GEN HALF EXPONENTIAL
% *PruRSG Engine Model  - Models Generalised Half Exponential Distributed Values*
% 
% 
% *The GenHalf_exponential class returns a vector of Generalised Half Exponential distributed
% values.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GenHalf_exponential < prursg.Engine.Model          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[lambda]|* -  $\lambda$ shape parameter
% 

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        lambda = [];
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
% *|4) [simulate()]|* - returns Generalised Half Exponential distributed values given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = GenHalf_exponential()
            % Constructor
            obj = obj@prursg.Engine.Model('GenHalf_exponential');
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
% The simulate method calculates Generalised Half Exponential distributed values based on the parameter $\lambda$.
% It returns a vector of random
% variates as the variable _series_, calculated as 
% 
% $S = \left\{ \begin{array}{l l} - \frac {1}{\lambda}\ln [1-2(z- \frac {1}{2})] & \quad \textrm{if } z > \frac {1}{2}\\
% 0 & \quad \textrm{if } z \leq \frac{1}{2} \\ \end{array} \right.$
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
% -  Shape parameter, $\lambda$, passed in via _obj.lambda_
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
            series = ones(1,obj.initialValue.getSize());
            rn = normcdf(corrNumElements);      
            series = (rn>0.5) .* (-log(1-2*(rn-0.5))./obj.lambda); %OK to have negative values in log() as it will simply return complex numbers
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

