%% CREDIT NORMAL
% *PruRSG Engine Model  - Models Normally Distributed Credit Spread*
% 
% 
% *The Credit Normal class
% returns a vector of
% Normal distributed credit spreads.*
%
% 
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef CreditNormal < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ distribution scale parameter
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
% *|4) [simulate()]|* - returns the LogGamma distributed equity index given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = CreditNormal()
            % Constructor
            obj = obj@prursg.Engine.Model('CreditNormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration in RSG for moment
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
% The simulate method calculates a Normally distributed credit spread, $series$, based on the parameters $\mu$ and $\sigma$. It returns a vector of random
% spreads as the variable $series$, that is floored such that it cannot be less than a minimum value, $F$, and also cannot be less than the parent spread plus a minimum value $V$ (the parent spread is the credit spread of the next higher rated bond i.e. the parent of a A rated bond would be a AA rated bond). 
% It is calculated as 
%
% $series = \max (F, shift + init - parentinit + parentspread, parentspread + V))$
%
% where
%
% $shift = \sigma \mu$
% 
% $F$ is a floor value hardcoded to 0.0001 and 
% $V$ is a miminum shift in
% the credit spread hardcoded to 0.0001
%
% *Inputs*
%
% *_Initial Values_*
%
% -  Initial value of the credit spread, $init$, passed in via
%       _obj.initialvalues_
%
% *_Precedents_*
%
% -  Initial value of the credit spread of the parent, $parentinit$, passed in via
%       _workerObj.getInitValue_
%
% -  Stochastic value of the parent credit spread, $parentspread$, passed in via
%       _workerObj.getSimResults_
%
% *_Distribution Parameters_*
%
% -  Location parameter, $\mu$, passed in via _obj.mu_
%
% -  Distribution scale parameter, $\sigma$, passed in via _obj.sigma_
%
% 
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
% *Outputs*
%
% A vector of Normally distributed credit spreads, _series_
        
        function series = simulate(obj, workerObj, corrNumElements)            
            % MODEL API NOTE
            % 10) see below for API to pull out precedents of the current
            % risk factor, note it is in general a cell array of strings, which are names
            % matching the names given in the XML model file
            precedentList = obj.getPrecedentObj();
            if str2num(precedentList('parent_spread')) == 0 % modeller has to remember that zero denotes no precedent credit risk factor
                parent = 0;
                parentinit = 0;
            else
                precedent = precedentList('parent_spread');
            	parent = precedent;
                % MODEL API NOTE
                % 13) the getInitVal method allows you to access the initial
                % value of any other risks, and again it comes in as a
                % DataSeries object, within which the "values" property
                % contains a cell array of hypercubes, since it's an
                % initial value there is only one cube so we pick the first
                % one
                parentinit = workerObj.getInitVal(precedent).values{1};
                parentresults = workerObj.getSimResults(precedent);
            end
            initValue = obj.initialValue.values{1}; % pulls out entire curve of initial values

            %all parameters
            mu = obj.mu;
            sigma = obj.sigma;        
              
            shift = corrNumElements*obj.sigma + obj.mu;
                    
            %now form output
            for i =1:length(initValue)
                if parent == 0
                    series(i,:) = shift' + initValue(i);
                else
                    minimumShiftValue = 0.0001;
                    series(i,:) = max(shift' + initValue(i) - parentinit(i) + parentresults(:,i)',parentresults(:,i)'+ minimumShiftValue) ; %limit spread so that not less than parent's spread
                end
            end
            outputFloorValue = 0.0001;
            series = max(series, outputFloorValue)';
           
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
        
    end
    
end

