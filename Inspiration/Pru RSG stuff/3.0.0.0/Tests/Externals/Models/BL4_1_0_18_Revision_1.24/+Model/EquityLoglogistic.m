%% EQUITYLOGLOGISTIC
% *PruRSG Engine Model  - Models Log Logistic Distributed Equity Index Values*
% 
% 
% *The EquityLoglogistic class
% returns a vector of
% log logistic distributed equity index values, multiplied by a 1 year drift based on the 1
% year spot rate from the nominal yield curve plus a risk premium.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef EquityLoglogistic < prursg.Engine.Model       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[alpha]|* -  $\alpha$ shape parameter
%
% *|[beta]|* -  $\beta$ scale parameter
%
% *|[riskprem]|* -  risk premium parameter
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        alpha = [];
    	beta = [];
        riskprem = [];
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
        function obj = EquityLoglogistic()
            % Constructor
            obj = obj@prursg.Engine.Model('EquityLoglogistic');
        end
%%
% _________________________________________________________________________________________
%
%% calibration
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *Description*
%
% The calibration method estimates values for the parameters $\hat \alpha$ and
% $\hat \beta$ by minimising the cost function, _v_, where 
%
% $v = \sum_{i=1}^N (t_i-\hat \alpha(\frac{1-q_i}{q_i})^\frac {1}{\hat \beta})^2$
%
% subject to $\hat \beta > 0$
% where $q_ = Quant$ is a vector of the _N_ quantiles and $t = Target$ is a vector of the corresponding _N_ target values for the distribution.
%
%% *Inputs*
%
% *_calibParamNames_*
%
% -  A cell array of the values of the quantiles to which the distribution
% is to be fitted, passed as strings.
%
% *_calibParamTargets_*
%
% -  A cell array of the values of the targets corresponding to the
% quantiles.
%
%
%% *Outputs*
%
% _success_flag_ is always returned as 1 if the method completes.
% _obj.alpha_ is set to the estimate of $\hat \alpha$
% _obj.beta_ is set to the estimate of $\hat \beta$


        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		% assign starting values - need to think more about what are good starting values
		x0(1)=1;
		x0(2)=10;

        % MODEL API NOTE
        % 3) calibration parameters are passed in as two separate cell arrays, the percentile names are in
        % calibParamNames, whilst the target values are in
        % calibParamTargets, see here for example usage
        Quant(1) = str2num(calibParamNames{1});
        Quant(2) = str2num(calibParamNames{2});
        Target(1) = calibParamTargets{1};
        Target(2) = calibParamTargets{2};
		
        %sum of square differences fn - note no 'mean' available here
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				valu=valu+100*(Target(i)-x(1)*((1-Quant(i))/Quant(i))^(1/x(2)))^2;
			end
		end

		%minimize sum of square differences - remember have constraint beta>0
		y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);

		%assign parameters
		obj.alpha = y(1);
		obj.beta = y(2);
		%and ignore riskprem in calibration (for now)

		%success
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
% The simulate method calculates a LogLogistic distributed equity index value based on the initial value _init_ and the parameters $\alpha$, $\beta$, and multiplies it by $1 +\mu$, where $\mu$ is equal to the drift rate _r_,
% based on the 1 year spot rate from the nominal yield curve plus the risk premium, _riskprem_. It returns a vector of random
% variates as the variable _series_, calculated as 
% 
% $S = init \times \alpha (1 + riskprem + r)   [\frac{\phi(z)}{(1-\phi(z)}]^\frac{1}{\beta}$
%
%
%% *Inputs*
%
% *_Initial Values_*
%
% -  Initial value of an index, _init_, passed in via
%       _obj.initialvalues_
%
% *_Precedents_*
%
% -  Drift parameter, _r_, based on 1 year spot rate from the nominal yield
% curve, passed in via the _workerObj_
%
% *_Distribution Parameters_*
%
% -  Shape parameter, $\alpha$, passed in via _obj.alpha_
% 
% -  Location parameter, $\mu$, calculated as _obj.riskprem_ + _r_, where
% _r_ is the 1 year spot rate from the nominal yield curve.
%
% -  Scale parameter, $\beta$, passed in via _obj.beta_
%
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of LogLogistic distributed equity returns, _series_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function distributionSamples = simulate(obj, workerObj, corrNumElements)
           
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('r'); % modeller would know the first one (and the only one here) is the one needed
            Y1 = workerObj.getSimResults(precedent);
            Y11 = Y1(:,1); % 1y points of nyc serve as annualised short rate
            mu=obj.riskprem+Y11;
            series = obj.initialValue.values{1}.*(1+mu).*obj.alpha.*(normcdf(corrNumElements)./(1-normcdf(corrNumElements))).^(1/obj.beta);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

