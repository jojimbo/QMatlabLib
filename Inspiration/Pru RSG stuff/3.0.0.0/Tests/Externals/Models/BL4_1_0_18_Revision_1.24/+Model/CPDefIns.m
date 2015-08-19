%% CPDEFINS
% *PruRSG Engine Model  - Calculate Loss due to Counterparty Default
% 
%   
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef CPDefIns < prursg.Engine.Model        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% - none
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % subRisks = 1; % number of sub-risks this model represents, e.g. for a yield curve this could be 90
        % model parameters
    end
        
    methods
        function obj = CPDefIns()
            % Constructor
            obj = obj@prursg.Engine.Model('CPDefIns');
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
% Calculates the loss on default as $(1-RR) . IsDef$ where $RR$ is the
% recovery rate on default and $IsDef$ is a Boolean indicating whether the
% precedent is in default
%
%% *Inputs*
%
% *IsDef*
%
% -  Boolean indicating if Precedent, _cpdef_, is in default.
%
% *RR*
%
% -  Recovery rate if in default, _cprr_.
%
%% *Outputs*
%
% A vector, _series_, indicating the rate of loss due to default.

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)
            precedentList = obj.getPrecedentObj();
            cpdef = precedentList('cpdef');
            cprr = precedentList('cprr');
            IsDef = workerObj.getSimResults(cpdef);
            RR = workerObj.getSimResults(cprr);
	    
            %convert to spot
            series = (1-RR) .* IsDef;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

