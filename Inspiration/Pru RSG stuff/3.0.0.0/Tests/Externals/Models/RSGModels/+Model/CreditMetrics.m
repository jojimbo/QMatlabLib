classdef CreditMetrics < prursg.Engine.Model    

    properties
        % model parameters
        var = [];
        f = [];
    end
        
    methods
        function obj = CreditMetrics()
            % Constructor
            obj = obj@prursg.Engine.Model('CreditMetrics');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            corrNumElements = normcdf(corrNumElements);
	    %SL 5 APR - var is actually sqrt(var)!!
    	    series = normcdf(norminv(obj.initialValue.values{1},0,1),obj.f+corrNumElements*sqrt(12)*obj.var,1);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
    end
    
end

