classdef GenLoggamma < prursg.Engine.Model    

    properties
        % model parameters
        alpha = []; 
        mu = [];
        sigma = [];
    end
        
    methods
        function obj = GenLoggamma()
            % Constructor
            obj = obj@prursg.Engine.Model('GenLoggamma');
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
           
            series = obj.mu + obj.sigma *log(gaminv(normcdf(corrNumElements),obj.alpha,1));
            
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

