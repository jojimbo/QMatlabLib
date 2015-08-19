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
		%assign starting values
		for i = 1:length(calibParamNames)	
			if strcmp(calibParamNames{i}, 'mean')
				%we can assign a close value for mu
				x0(1) = log(calibParamTargets{i});
			else
				x0(2) = 1; %start sigma at 1
			end
		end
		%thus now have x0

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-exp(x(1)+0.5*x(2)^2))^2;
				else
					valu=valu+100*(calibParamTargets{i}-exp(x(1)+x(2)*norminv(str2num(calibParamNames{i}),0,1)))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
		y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);

		%assign parameters
		obj.mu = y(1);
		obj.lambda = y(2);

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
            series = ones(1,obj.initialValue.getSize());
            rn = normcdf(corrNumElements);      
            series = (rn>0.5) .* (-log(1-2*(rn-0.5))./obj.lambda); %OK to have negative values in log() as it will simply return complex numbers
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

