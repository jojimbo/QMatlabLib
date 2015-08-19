%% VOL EGB2
% *PruRSG Engine Model*  - Exponential Generalised Beta of the Second Kind (EGB2) Swaption Volatility Surface 
%
%
% Returns a vector of EGB2 distributed swaption volatility surfaces.
%  
%% 
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef VolEGB2 < prursg.Engine.Model               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Properties
% These are global parameters which are available to all methods in
% this class. They are all arrays with dimensions term and tenor.
% 
% *|[mu]|* -  $\mu$ location parameter
%
% *|[sigma]|* -  $\sigma$ scale parameter
%
% *|[alpha]|* -  $\alpha$ shape parameter
%
% *|[beta]|* -  $\beta$ shape parameter
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        % model parameters
        mu = [];
        sigma = [];
        alpha=[];
        beta=[];
        
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
% *|4) [simulate()]|* - returns Exponential Generalised Beta function of the 2nd Kind (EGB2) distributed swaption vol surfaces given
% the normally distributed stochastic input array [corrNumElements]
%
% *|5) [validateCalibration()]|* - not implemeted - returns 1 (success)
%

%MATLAB CODE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
       
    methods
        function obj = VolEGB2()
            % Constructor
            obj = obj@prursg.Engine.Model('VolLogEGB2');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
        	%No code for calibration for now
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
% The simulate method calculates a vector of EGB2 distributed volatility surfaces based on the
% standard Normal distribution z and the parameters $\mu$, $\sigma$, $\alpha$ and $\beta$.
% It returns an array of swaption volatilites of dimension $(term, tenor)$, refactored as a vector, as the variable _series_. It is then floored at 5%. It is calculated as 
% 
% $S = \max(0.05, (\mu - \sigma(\ln \frac{1}{\beta^{-1}(z,\alpha,\beta)-1}+init)$
%
% The $n \times m$ 2 dimensional surface is refactored into a vector of
% length $n \times m$ for each simulation
%
%% *Inputs*
%
% *_Distribution Parameters_*
% 
% -  Location parameter, $\mu$, passed in via _obj.mu_
%
% -  Scale parameter, $\sigma$, passed in via _obj.sigma_
%
% -  Shape parameter, $\alpha$, passed in via _obj.alpha_
%
% -  Shape parameter, $\beta$, passed in via _obj.beta_
%
% *_Variates_*
%
% -  A vector of normally distributed variates, *z*, passed in from the engine as
% _corrNumElements_
%
%% *Outputs*
%
% A vector of EGB2 distributed variates, _series_

        function series = simulate(obj, workerObj, corrNumElements)
            series=ones(1,obj.initialValue.getSize()); 
            simsurface = cell(length(corrNumElements),1);
            
            % again this will pull out a hypercube of initial values
            initValue = obj.initialValue.values{1};
            initValue = squeeze(initValue)'; %gets rid of the singleton dimension(s) 

            %want dimensions of init surf and sigma to match, so remove rows if sigma too big
            sigma = obj.sigma;
            mu = obj.mu;
            alpha = obj.alpha;
            beta = obj.beta;
            d = size(sigma);
            e = size(initValue);
            f = size(mu);
            g = size(alpha);
            h = size(beta);
            if d(1)>e(1)
                sigma = sigma(1:e(1),:)	;
            end
            if f(1)>e(1)
                mu = mu(1:e(1),:)	;
            end
            if g(1)>e(1)
                alpha(1) = alpha(1:e(1),:);
            end
            if h(1)>e(1)
                beta = beta(1:e(1),:);
            end
                        
            rnum = normcdf(corrNumElements);
            for i=1:length(corrNumElements)                
                simsurface(i) = {mu - sigma.*(log(1./betainv(rnum(i),alpha,beta)-1)) + initValue};
            end
            
            % flatten surfaces
            for i0=1:length(corrNumElements)
                i4=0;
                mat=cell2mat(simsurface(i0));
                mat = mat'; %Note the Matlab read first from up to down, then left to right!
                for i1=1:size(mat,1)
                    for i2=1:size(mat,2)
                        i4=i4+1;
                        series(i0,i4)=mat(i1,i2);
                    end
                end
            end
            
            series = (series>=0.05).*series + (series<0.05)*0.05;   %floor values at 5%

	end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
          
    end
    
end

