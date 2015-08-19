classdef GenBeta < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
        alpha = [];
        beta = [];
    end
        
    methods
        function obj = GenBeta(initValue, parameters )
            % Constructor
            obj = obj@prursg.Engine.Model('GenBeta');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            % not implemented
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            series = obj.mu + obj.sigma * betainv(normcdf(corrNumElements),obj.alpha,obj.beta);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

