%% CREDIT TILTED LAPLACE
% *PruRSG Engine Model  - Models Tilted Laplace Distributed Credit Spread*
% 
% 
% *The Credit Tilted Laplace class
% returns a vector of
% Tilted Laplace distributed credit spreads.*
%
% 
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef CredTiltedLaplace < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[theta]|* -  $\theta$ shape parameter
%
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ distribution scale parameter
%
% *|[r_0]|* - $r_0$ 
%
% *|[pivot]|* -  pivot parameter
%
% *|[Scalar]|* -  final scaling parameter
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        mu = [];
        sigma = [];        
        theta = [];
        r0 = [];
        pivot = [];
        Scalar = [];
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
        function obj = CredTiltedLaplace()
            % Constructor
            obj = obj@prursg.Engine.Model('CredTiltedLaplace');
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
% The simulate method calculates a Tilted Laplace distributed credit spread, $series$, based on the parameters $\theta$, $\mu$, $\sigma$, $r_0$ and $pivot$. It returns a vector of random
% spreads as the variable $series$, that is floored such that it cannot be less than a minimum value, $F$, and also cannot be less than the parent spread plus a minimum value $V$ (the parent spread is the credit spread of the next higher rated bond i.e. the parent of a A rated bond would be a AA rated bond). 
% It is calculated as 
%
% $series = \max (F, shift + init - parentinit + parentspread, parentspread + V))$
%
% $shift = \ln[\exp(S)(\exp (\frac {r_0}{pivot}-1)+1)]\times pivot -r_0$
% 
% Where
%
% $S = \left\{ \begin{array}{l l} \mu + \ln [\frac {2w}{1-\theta}](1-\theta)\sigma & \quad \textrm{if } w < T\\
% \mu - \ln [\frac {2(1-w)}{1+\theta}](1+\theta)\sigma & \quad \textrm{if } w \geq T \\ \end{array} \right.$
%
% Where
%
% $T = \frac {1- \theta}{2}$
%
% $w=\phi(z)$
% 
% and 
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
% -  Shape parameter, $\theta$, passed in via _obj.theta_
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
% A vector of Tilted Laplace distributed credit spreads, _series_
        
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
            theta = obj.theta;
            r0 = obj.r0;
            pivot = obj.pivot;
            Scalar = obj.Scalar;
            
            %Uniform random number
            rnum = normcdf(corrNumElements);
            
            threshold = ((1 - theta) / 2) * ones(size(rnum,1),1);
            simVal = (rnum<threshold) .* (mu + log(2 * rnum / (1 - theta)) * (1 - theta) * sigma) + ...
                (rnum>=threshold) .* (mu - log(2 * (1 - rnum) / (1 + theta)) * (1 + theta) * sigma);
         
            %Lambda transformation
            shift = log(exp(simVal) * (exp(r0/pivot) - 1) + 1) * pivot - r0;
            shift = shift * Scalar;
                    
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

