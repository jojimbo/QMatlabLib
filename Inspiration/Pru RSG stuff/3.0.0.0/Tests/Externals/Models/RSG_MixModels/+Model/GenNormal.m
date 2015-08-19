classdef GenNormal < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
    end
        
    methods
        function obj = GenNormal()
            % Constructor
            obj = obj@prursg.Engine.Model('GenNormal');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		%assign starting values
		for i = 1:length(calibParamNames)	
			if strcmp(calibParamNames{i}, 'mean')
				%mu as mean is a (very) good first guess...
				x0(1) = calibParamTargets{i};
			else
				%this is also a good guess for sigma
                % note this line assumes that first initial value assigned
                % already
				%x0(2) = (calibParamTargets{i}-x0(1))/norminv(calibParamTargets{i},0,1);
                x0(2) = 1;
			end
		end

		%thus now have x0 = [mu, sigma] if given two percentiles, mean and a %.  but we may not have been...

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-x(1))^2;
				else
					valu=valu+100*(calibParamTargets{i}-(x(1)+x(2)*norminv(str2num(calibParamNames{i}),0,1)))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
		y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);

		%assign parameters
		obj.mu = y(1);
		obj.sigma = y(2);

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
            series = corrNumElements*obj.sigma + obj.mu;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

