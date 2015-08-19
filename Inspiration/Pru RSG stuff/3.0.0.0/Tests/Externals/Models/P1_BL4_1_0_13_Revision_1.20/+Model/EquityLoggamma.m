classdef EquityLoggamma < prursg.Engine.Model    

    properties
        % model parameters
        alpha = []; 
        mu = [];
        sigma = [];
    end
        
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
        
        function series = simulate(obj, workerObj, corrNumElements)
            % MODEL API NOTE
            % below is an example of how to pull out the list of precedent
            % risk and then pull out the simulation results of a specific precedent risk
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('r'); % modeller would know the first one (and the only one here) is the one needed
            Y1 = workerObj.getInitVal(precedent);   %the risk-free rate shoudl be the initial values rather than the simulated one (also fwd=spot for term <= 1Y)
            Y11 = Y1.values{1}(3); % 1y points of nyc serve as annualised short rate (note we have 0.25 and 0.5 before 1Y)
            drift = Y11; %risk premium and interest rate
            series = obj.initialValue.values{1}.*exp(obj.mu + obj.sigma *log(gaminv(normcdf(corrNumElements),obj.alpha,1)))*(1+drift);
            
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
    end
    
end

