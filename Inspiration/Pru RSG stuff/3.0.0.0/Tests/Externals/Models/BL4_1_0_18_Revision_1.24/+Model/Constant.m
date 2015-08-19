%% CONSTANT
% *PruRSG Engine Model  - Returns Constant Value*
% 
%   
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Constant < prursg.Engine.Model     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% - none
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters

    end
        
    methods
        function obj = Constant()
            obj = obj@prursg.Engine.Model('Constant');
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
% Returns a vector with each element (for each scenario) equal to the constant _initalValue_
%
%%*Inputs*
%
% *_Initial Values_*
%
% -  Initial value of an index, _init_, passed in via
%       _obj.initialValue.values_
%
%
%% *Outputs*
%
% A vector, _series_, the same length as corrNumElements, with every element equal to _obj.initalValues.value{1}_. 

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function series = simulate(obj, workerObj, corrNumElements)
        % return unmodified initial values          
            dummy(1:size(corrNumElements, 1), 1) = 1;
            series = obj.initialValue.values{1} * dummy;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end       
        
    end    
end

