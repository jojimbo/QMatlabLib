classdef GenLognormalmin1 < prursg.Engine.Model    

    properties
        % model parameters
        mu = [];
        sigma = [];
    end
        
    methods
        function obj = GenLognormalmin1()
            % Constructor
            obj = obj@prursg.Engine.Model('GenLognormalmin1');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		%assign starting values
		for i = 1:length(calibParamTargets)	
			if strcmp(calibParamNames{i}, 'mean')
				%we can assign a close value for mu
				% x0(1) = log(calibParamTargets{i}-1);
                x0(1) = calibParamTargets{i};
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
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+0.5*x(2)^2)-1))^2;
				else
					valu=valu+100*(calibParamTargets{i}-(exp(x(1)+x(2)*norminv(str2num(calibParamNames{i}),0,1))-1))^2;
				end
			end
		end

		%minimize sum of square differences - remember have constraint sigma>0
        % this seems to work much better than contrained optimiser
        y = fminunc(@ourfunc,[0 1]);
		% y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);
        % y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0],[],[],[],[],[],optimset('MaxIter',50000,'TolFun',1e-10));

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
            series = exp(corrNumElements*obj.sigma + obj.mu) - 1;
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end
