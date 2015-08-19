classdef Inflation < prursg.Engine.Model    

    properties
        % subRisks = 1; % number of sub-risks this model represents, e.g. for a yield curve this could be 90
        % model parameters

	%model precendents
	nyc = [];
	ryc = [];

    end
        
    methods
        function obj = Inflation()
            % Constructor
            obj = obj@prursg.Engine.Model('Inflation');
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
            nycRisk = precedentList('nyc');
            rycRisk = precedentList('ryc');
            nom = workerObj.getSimResults(nycRisk);
            real = workerObj.getSimResults(rycRisk);
            %For calc of the initial inflation rates
            %inom = workerObj.getInitVal(nycRisk).values{1};
            %ireal = workerObj.getInitVal(rycRisk).values{1};
            %iinf = (1+inom) ./ (1+ireal) - 1;
            %obj.initialValue.values{1} = iinf;  %recalc initial values
            
            series = (1+nom)./(1+real) - 1; 

        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

