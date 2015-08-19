classdef YCCIR_Parallel < prursg.Engine.Model    
   
    properties        
        % model parameters
        alpha=[];
        theta=[];
        sigma=[];
	r0=[];
    end
        
    methods
        function obj = YCCIR_Parallel()
            % Constructor
            obj = obj@prursg.Engine.Model('YCCIR_Parallel');
        end
        % Perform calibration
        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
           	%no calibration implemented
		success_flag = 1;
        end

        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end        
        
        function series = simulate(obj, workerObj, corrNumElements)
            Y0 = obj.initialValue.values{1};
            r0 = obj.r0;
            shifts = (r0 + obj.alpha*obj.theta*dt + obj.sigma.*corrNumElements*sqrt(r0*12) + 0.25*obj.sigma^2*(corrNumElements.^2-1)*12)/(1+12*obj.alpha)-r0;
            for i = 1:length(Y0)
                series(:,i) = shifts + Y0(i);
            end
        end
        
        function s = validateCalibration( obj ) %#ok<MANU>
            s = 'Not implemented';
        end
    end
end

