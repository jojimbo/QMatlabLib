%% EQUITYLOGGAMMA
% *PruRSG Engine Model  - Models Log Gamma Distributed Equity Index Values*
% 
% 
% *The EquityLoggamma class
% returns a vector of
% Log Gamma distributed equity index values, multiplied by a 1 year drift based on the 1
% year spot rate from the nominal yield curve.*
%
% 

%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef EquityLoggamma < prursg.Engine.Model    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all single values.
% 
% *|[alpha]|* -  $\alpha$ shape parameter
%
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ scale parameter
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        alpha = []; 
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
        function obj = EquityLoggamma()
            % Constructor
            obj = obj@prursg.Engine.Model('EquityLoggamma');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % no calibration required
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
% The simulate method calculates a LogGamma distributed equity index value based on the initial value _init_ and the parameters $\alpha$, $\mu$, $\sigma$, and multiplies it by a drift rate _r_,
% based on the 1 year spot rate from the nominal yield curve. It returns a vector of random
% variates as the variable distributionSamples, calculated as 
% 
% $S = init \times \exp{(\mu+\sigma \times \log[{\Gamma^{-1}(\phi(z), \alpha , 1)}])} \times (1+r)$
%
%
% *Inputs*
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
% -  Location parameter, $\mu$, passed in via _obj.mu_
%
% -  Scale parameter, $\sigma$, passed in via _obj.sigma_
%
%
% *_Variates_*
%
% -  A vector of standard normal variates, *z*, passed in from the engine as
% _corrNumElements_
%
% *Outputs*
%
% A vector of LogGamma distributed equity returns, _distributionSamples_

%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function distributionSamples = simulate(obj, workerObj, corrNumElements)
           
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('r'); 
            yieldCurve = workerObj.getInitVal(precedent);   %the risk-free rate should be the initial values rather than the simulated one (also fwd=spot for term <= 1Y)
            y1Point = 3; % 1y point of nyc serve as annualised short rate (note we have 0.25 and 0.5 before 1Y)
            drift = yieldCurve.values{1}(y1Point); %risk premium and interest rate
            distributionSamples = obj.initialValue.values{1}.*exp(obj.mu + obj.sigma *log(gaminv(normcdf(corrNumElements),obj.alpha,1)))*(1+drift);
            
        end
%%
%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end  
    end
end

