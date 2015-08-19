classdef GenGamma < prursg.Engine.Model    

    properties
        % model parameters
        alpha = [];
        beta = [];
    end
        
    methods
        function obj = GenGamma(initValue, parameters )
            % Constructor
            obj = obj@prursg.Engine.Model('GenGamma');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		%assign starting values
		x0(1)=0.1;
		for i = 1:length(calibParamNames)	
			if strcmp(calibParamNames{i}, 'mean')
				x0(2) = calibParamTargets{i}/x0(1);
			end
		end

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-x(1)*x(2))^2;
				else
					valu=valu+100*(calibParamTargets{i}-gammaincinv(1-str2num(calibParamNames{i}),x(1),'upper')*x(2))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
        % y = fminunc(@ourfunc,x0);
		% y = fmincon(@ourfunc,x0,[-1 0 ; 0 0],[0 0]); THIS DOESN'T WORK
        y = [0 0]; % no optimisation present in code from Pru, set to zeros for now
		%assign parameters
		obj.alpha = y(1);
		obj.beta = y(2);

		%success
            	success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            series = gammaincinv(1-normcdf(corrNumElements,0,1),obj.alpha,'upper')*obj.beta;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

