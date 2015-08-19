classdef GenUniform < prursg.Engine.Model
    
    properties
        % model parameters
        
    end
    
    methods
        function obj = GenUniform()
            % Constructor
            obj = obj@prursg.Engine.Model('GenUniform');
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
            series = normcdf(corrNumElements);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
        
        
    end
    
end

