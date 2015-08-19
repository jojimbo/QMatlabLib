classdef EquityLoglogistic < prursg.Engine.Model    

    properties
        % model parameters
        alpha = [];
    	beta = [];
        riskprem = [];
    end
        
    methods
        function obj = EquityLoglogistic()
            % Constructor
            obj = obj@prursg.Engine.Model('EquityLoglogistic');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
		% assign starting values - need to think more about what are good starting values
		x0(1)=1;
		x0(2)=10;

        % MODEL API NOTE
        % 3) calibration parameters are passed in as two separate cell arrays, the percentile names are in
        % calibParamNames, whilst the target values are in
        % calibParamTargets, see here for example usage
        Quant(1) = str2num(calibParamNames{1});
        Quant(2) = str2num(calibParamNames{2});
        Target(1) = calibParamTargets{1};
        Target(2) = calibParamTargets{2};
		
        %sum of square differences fn - note no 'mean' available here
		function valu = ourfunc(x)
        	valu=0;
			for i = 1:length(x)
				valu=valu+100*(Target(i)-x(1)*((1-Quant(i))/Quant(i))^(1/x(2)))^2;
			end
		end

		%minimize sum of square differences - remember have constraint beta>0
		y = fmincon(@ourfunc,x0,[0 0 ; 0 -1],[0 0]);

		%assign parameters
		obj.alpha = y(1);
		obj.beta = y(2);
		%and ignore riskprem in calibration (for now)

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
            % MODEL API NOTE
            % below is an example of how to pull out the list of precedent
            % risk and then pull out the simulation results of a specific precedent risk
            precedentsList = obj.getPrecedentObj();
            precedent = precedentsList('r'); % modeller would know the first one (and the only one here) is the one needed
            Y1 = workerObj.getSimResults(precedent);
            Y11 = Y1(:,1); % 1y points of nyc serve as annualised short rate
            mu=obj.riskprem+Y11;
            series = obj.initialValue.values{1}.*(1+mu).*obj.alpha.*(normcdf(corrNumElements)./(1-normcdf(corrNumElements))).^(1/obj.beta);
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

