%% GEN UNIFORM
% *PruRSG Engine Model*  - Uniform distribution.
%
%
% Returns a vector of Uniform distributed variates.
%  


%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef GenUniform < prursg.Engine.Model          
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
% outputs (1 for this distribution)
%
% *|4) [simulate()]|* - returns uniform distributed values given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = GenUniform()
            % Constructor
            obj = obj@prursg.Engine.Model('GenUniform');
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
% The simulate method calculates a uniform distributed value based on the
% standard Normal distribution z by inverting it using the normal
% cummulative distribution function $\phi(z)$.
% It returns a vector of random variates as the variable _series_, calculated as 
% 
% $S = \phi(z)$
%
%
%% *Inputs*
%
% *_Distribution Parameters_*
% 
% NONE
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of Uniformly distributed variates, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function series = simulate(obj, workerObj, corrNumElements)
            series = normcdf(corrNumElements);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
        
        
    end
    
end

