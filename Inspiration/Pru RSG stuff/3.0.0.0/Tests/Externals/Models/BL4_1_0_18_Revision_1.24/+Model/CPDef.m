%% CPDEF
% *PruRSG Engine Model  - Calculate if Counterparty default event occurs*
% 
%   
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef CPDef < prursg.Engine.Model      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% - none
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        Threshold = [];    	
    end
        
    methods
        function obj = CPDef()
            % Constructor
            obj = obj@prursg.Engine.Model('CPDef');
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
 
%% List of Methods
% This model class has the following methods:
%
% _________________________________________________________________________________________
%
%%  simulate
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% Calculates a counterparty default event based on whether the delta NAV, _dNAV_, of the precedent model is less
% than a threshold value, _Threshold_. 
%
%% *Inputs*
%
% *dNAV*
%
% -  Delta Net Asset Value, _dNAV_, passed in via
%       the precendent model
%
% *Threshold*
%
% -  The threshold for the delta NAV passed in via _obj.Threshold
%
%% *Outputs*
%
% A vector, _series_, the same length as corrNumElements, which is 1 if dNAV< Threshold, otherwise it is 0. 

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)            
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('dNav');
            dNAV = workerObj.getSimResults(precedent);            
            series = (dNAV < obj.Threshold);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

