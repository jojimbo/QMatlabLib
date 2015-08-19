classdef CPDefIns < prursg.Engine.Model    

    properties
        % subRisks = 1; % number of sub-risks this model represents, e.g. for a yield curve this could be 90
        % model parameters
    end
        
    methods
        function obj = CPDefIns()
            % Constructor
            obj = obj@prursg.Engine.Model('CPDefIns');
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
            cpdef = precedentList('cpdef');
            cprr = precedentList('cprr');
            IsDef = workerObj.getSimResults(cpdef);
            RR = workerObj.getSimResults(cprr);
	    
            %convert to spot
            series = (1-RR) .* IsDef;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

