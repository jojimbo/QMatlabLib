classdef GenHalf_exponential < prursg.Engine.Model    

    properties
        % model parameters
        lambda = [];
    end
        
    methods
        function obj = GenHalf_exponential()
            % Constructor
            obj = obj@prursg.Engine.Model('GenHalf_exponential');
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
            series = ones(1,obj.initialValue.getSize());
            rn = normcdf(corrNumElements);      
            series = (rn>0.5) .* (-log(1-2*(rn-0.5))./obj.lambda); %OK to have negative values in log() as it will simply return complex numbers
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

