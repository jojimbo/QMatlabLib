classdef LiquidityPrem < prursg.Engine.Model    

    properties
        % model parameters
        mult = [];
        wAAA = [];
        wAA = [];
        wA = [];
        wBBB = [];
        wBB = [];
        wB = [];
	deduct = [];
	LLP = [];
	ZE = [];
    end
        
    methods
        function obj = LiquidityPrem()
            % Constructor
            obj = obj@prursg.Engine.Model('LiquidityPrem');
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
            spdAAA = workerObj.getSimResults(precedentList('spdAAA'));
            spdAA = workerObj.getSimResults(precedentList('spdAA'));
            spdA = workerObj.getSimResults(precedentList('spdA'));
            spdBBB = workerObj.getSimResults(precedentList('spdBBB'));
            spdBB = workerObj.getSimResults(precedentList('spdBB'));
            spdB = workerObj.getSimResults(precedentList('spdB'));
	    curvelength = length(obj.initialValue.values{1});

    	    lqp = obj.mult*(spdAAA(:,10)*obj.wAAA + spdAA(:,10)*obj.wAA + spdA(:,10)*obj.wA + spdBBB(:,10)*obj.wBBB + spdBB(:,10)*obj.wBB + spdB(:,10)*obj.wB-obj.deduct);
            % series = series(:,10)*ones(1,curvelength); % use 10 year point of credit curves

	    %up to LLP, it's lpq
	    for i=1:obj.LLP
		series(:,i)=lqp;
	    end
	    %between LLP and ZE we go linearly to zero
	    for i=obj.LLP+1:obj.ZE
		series(:,i)=lqp - (i-obj.LLP)*lqp/(obj.ZE-obj.LLP);
	    end
	    %after the ZE, it's zero
	    for i = obj.ZE+1:curvelength
		series(:,i) = zeros(size(corrNumElements,1),1);
	    end
        end
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

