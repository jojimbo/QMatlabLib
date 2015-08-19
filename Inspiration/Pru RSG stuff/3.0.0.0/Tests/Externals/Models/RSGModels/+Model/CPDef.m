classdef CPDef < prursg.Engine.Model    

    properties
        % model parameters
        Threshold = [];    	
    end
        
    methods
        function obj = CPDef()
            % Constructor
            obj = obj@prursg.Engine.Model('CPDef');
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
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('dNav');
            dNAV = workerObj.getSimResults(precedent);            
            series = (dNAV < obj.Threshold);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

