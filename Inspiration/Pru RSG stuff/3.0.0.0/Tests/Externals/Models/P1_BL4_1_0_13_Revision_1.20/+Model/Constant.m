classdef Constant < prursg.Engine.Model    

    properties
        % model parameters

    end
        
    methods
        function obj = Constant()
            obj = obj@prursg.Engine.Model('Constant');
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
        % return unmodified initial values          
            dummy(1:size(corrNumElements, 1), 1) = 1;
            series = obj.initialValue.values{1} * dummy;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end       
        
    end    
end

