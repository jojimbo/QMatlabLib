classdef CredCIR_Parallel < prursg.Engine.Model    

    properties
        % model parameters
        alpha = [];
        theta = [];
        sigma = [];
	r0 = [];
    end
        
    methods
        function obj = CredCIR_Parallel()
            % Constructor
            obj = obj@prursg.Engine.Model('CredCIR_Parallel');
        end

        function success_flag = calibrate(obj, dataObj, calibParamNames, calibParamTargets)
	    % no calibration in RSG for moment
            success_flag = 1;
        end
        
        function inputs = getNumberOfStochasticInputs(obj)
            inputs = 1;
        end
        
        function outputs = getNumberOfStochasticOutputs(obj)
            outputs = obj.initialValue.getSize();
        end
        
        function series = simulate(obj, workerObj, corrNumElements)
            t = 12; % =obj.simEngine.simTimeStepInMonths;  ...model is calibrated to monthly data
            % MODEL API NOTE
            % 10) see below for API to pull out precedents of the current
            % risk factor, note it is in general a cell array of strings, which are names
            % matching the names given in the XML model file
            precedentList = obj.getPrecedentObj();
            if str2num(precedentList('parent_spread')) == 0 % modeller has to remember that zero denotes no precedent credit risk factor
                parent = 0;
                parentinit = 0;
            else
                precedent = precedentList('parent_spread');
            	parent = precedent;
                % MODEL API NOTE
                % 13) the getInitVal method allows you to access the initial
                % value of any other risks, and again it comes in as a
                % DataSeries object, within which the "values" property
                % contains a cell array of hypercubes, since it's an
                % initial value there is only one cube so we pick the first
                % one
                parentinit = workerObj.getInitVal(precedent).values{1};
                parentresults = workerObj.getSimResults(precedent);
	    end

    	initValue = obj.initialValue.values{1}; % pulls out entire curve of initial values

	%initial short rate
    	    r0 = obj.r0;
            r0 = 0.05;
	% first adjust random stream to preserve rank correlation
	x0 = -2*sqrt(r0/t)/obj.sigma;
	minU = normcdf(x0,0,1);
	adjcorrNumElements = norminv(normcdf(corrNumElements)*(1-minU)+minU,0,1);

	%parallel shift
	shift = (r0+obj.alpha*obj.theta*t+obj.sigma.*adjcorrNumElements*sqrt(t*r0)+0.25*obj.sigma^2 * t .* (adjcorrNumElements.^2-1))/(1+obj.alpha*t) - r0;

	%now form output
	for i =1:length(initValue)
        if parent == 0
            series(i,:) = r0 + shift' + initValue(i) - initValue(1);
        else
            series(i,:) = r0 + shift' + initValue(i) + parentresults(:,i)' - initValue(1);
        end
    end
    series = series';
    end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
        
    end
    
end

