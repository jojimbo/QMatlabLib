classdef IncomeVasicek < prursg.Engine.Model    

    properties
         % model parameters
        sigma = [];
        alpha = [];
    	theta = [];
    end
        
    methods
        function obj = IncomeVasicek()
            % Constructor
            obj = obj@prursg.Engine.Model('IncomeVasicek');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration atm - RSG currently uses a const value
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            initValue = obj.initialValue.values{1};
            series = initValue + obj.alpha*(obj.theta-initValue) + corrNumElements*obj.sigma*sqrt(1);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

