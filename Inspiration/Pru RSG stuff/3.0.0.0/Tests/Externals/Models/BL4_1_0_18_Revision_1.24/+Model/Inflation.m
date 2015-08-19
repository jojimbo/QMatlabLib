%% INFLATION
% *PruRSG Engine Model*  - Inflation model
%
%
% Returns a vector of implied Inflation values based on the nominal and real risk free yields.
%  


%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Inflation < prursg.Engine.Model              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[nyc]|* -  nominal yield curve
%
% *|[ryc]|* -  real yield curve
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % subRisks = 1; % number of sub-risks this model represents, e.g. for a yield curve this could be 90
        % model parameters

	%model precendents
	nyc = [];
	ryc = [];

    end
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
        function obj = Inflation()
            % Constructor
            obj = obj@prursg.Engine.Model('Inflation');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % no calibration required
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 0;
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
% The simulate method calculates an inflation rate and returns it as the variable _series_, calculated as 
% 
% $S = \frac {1+nom}{1+real}-1$
%
%
%% *Inputs*
%
% *_Yields_*
% 
% -  Nominal Yield, _nom_, passed in via the precedent risk _workerObj.getSimResults(nyc)_
%
% -  Real Yield, _real_, passed in via the precedent risk _workerObj.getSimResults(ryc)_
%
% *_Variates_*
%
% NONE
%
%% *Outputs*
%
% A vector of Inflation rate values, _series_ (as a decimal, not a
% percentage).

        function series = simulate(obj, workerObj, corrNumElements)
            precedentList = obj.getPrecedentObj();
            nycRisk = precedentList('nyc');
            rycRisk = precedentList('ryc');
            nom = workerObj.getSimResults(nycRisk);
            real = workerObj.getSimResults(rycRisk);
          
            
            series = (1+nom)./(1+real) - 1; 

        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

