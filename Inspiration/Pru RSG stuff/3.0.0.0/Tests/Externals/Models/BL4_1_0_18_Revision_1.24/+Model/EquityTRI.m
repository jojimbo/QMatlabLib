%% EQUITYTRI
% *PruRSG Engine Model  - Models Equity Total Return Index*
% 
% 
% *The EquityTRI class
% returns a vector of
% equity index values, calculated as the capital index plus a dividend
% yield*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef EquityTRI < prursg.Engine.Model     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|capinit|* -  initial capital index value
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        capinit = [];
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% List of Methods
% This model class has the following methods:
%
% *|1) [calibrate()]|* - not implemeted - returns 1 (success)
%
% *|2) [getNumberOfStocasticInputs()]|* - returns the number of stochastic
% inputs (0 for this distribution)
%
% *|3) [getNumberOfStochasticOutputs()]|* - - returns the number of stochastic
% outputs (the same as the number of initial values)
%
% *|4) [simulate()]|* - returns the Equity Total Return Index given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = EquityTRI()
            % Constructor
            obj = obj@prursg.Engine.Model('EquityTRI');
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
% The simulate method calculates a Total Return Index as 
% 
% $S = init \times [\frac {capindex}{capinit} + dy]$
%
%
%% *Inputs*
%
% *_Initial Values_*
%
% -  Initial value of an index, _capinit_, passed in via
%       _obj.capinit_
%
% *_Precedents_*
%
% -  Capital Index, _capindex_, passed in via the _workerObj_
%
% -  Dividend Yield, _dy_, passed in via the _workerObj_
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of Equity Total Return Index values, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)
            precedentList = obj.getPrecedentObj();
            dy = workerObj.getSimResults(precedentList('dy'));
    	    cri = workerObj.getSimResults(precedentList('capindex'));
            cr = cri./obj.capinit; %capital returns
            series = obj.initialValue.values{1} * (cr + dy);
            
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

