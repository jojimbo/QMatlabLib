classdef EquityTRI < prursg.Engine.Model    

    properties
        % model parameters
        capinit = [];
    end
        
    methods
        function obj = EquityTRI()
            % Constructor
            obj = obj@prursg.Engine.Model('EquityTRI');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration required
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 0;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            precedentList = obj.getPrecedentObj();
            dy = workerObj.getSimResults(precedentList('dy'));
    	    cri = workerObj.getSimResults(precedentList('capindex'));
            cr = cri./obj.capinit; %capital returns
            series = obj.initialValue.values{1} * (cr + dy);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

