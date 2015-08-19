classdef GenLognormalminalpha < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
        alpha = [];
    end
        
    methods
        function obj = GenLognormalminalpha()
            % Constructor
            obj = obj@prursg.Engine.Model('GenLognormalminalpha');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		%assign starting values
		for i = 1:length(calibParamNames)	
			if strcmp(calibParamNames{i}, 'mean')
				%we can assign a close value for mu
				x0(1) = log(calibParamTargets{i});
			end
		end
		x0(2) = 1; %start sigma at 1
		x0(3)=0; %start alpha at 0
		% now have x0

		%sum of square differences fn - assume only non % percentile is 'mean'
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(calibParamTargets)
				if strcmp(calibParamNames{i}, 'mean')
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+0.5*x(2)^2)-x(3)))^2;
				else
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+x(2)*norminv(1-str2num(calibParamNames{i}),0,1))-x(3)))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
		y = fmincon(@ourfunc,x0,[0 0 0 ; 0 -1 0 ; 0 0 0],[0 0 0]);

		%assign parameters
		obj.mu = y(1);
		obj.sigma = y(2);
		obj.alpha = y(3);

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
            series = exp(corrNumElements*obj.sigma + obj.mu) - obj.alpha;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end
