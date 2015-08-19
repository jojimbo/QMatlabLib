classdef LiquidityPrem_scr < prursg.Engine.Model    

    properties
        % model parameters
        mult = [];        
        deduct = [];
        LLP = [];
        ZE = [];
        wAAA = [];
        wAA = [];
        wA = [];
        wBBB = [];
        wBB = [];
        wB = [];        
    end
        
    methods
        function obj = LiquidityPrem_scr()
            % Constructor
            obj = obj@prursg.Engine.Model('LiquidityPrem_scr');
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
            Y0 = obj.initialValue.values{1};
            curvelength = length(Y0);
            
            precedentList = obj.getPrecedentObj();
            spdAAA = workerObj.getSimResults(precedentList('spdAAA'));
            spdAA = workerObj.getSimResults(precedentList('spdAA'));
            spdA = workerObj.getSimResults(precedentList('spdA'));
            spdBBB = workerObj.getSimResults(precedentList('spdBBB'));
            spdBB = workerObj.getSimResults(precedentList('spdBB'));
            spdB = workerObj.getSimResults(precedentList('spdB'));            
            lqp = obj.mult*(spdAAA(:,1)*obj.wAAA + spdAA(:,1)*obj.wAA + spdA(:,1)*obj.wA + spdBBB(:,1)*obj.wBBB + spdBB(:,1)*obj.wBB + spdB(:,1)*obj.wB - obj.deduct);
            %up to LLP, fwd LQP is just lpq
            for i=1:(obj.LLP+2)
                series(:,i)=lqp;
            end
            %between LLP and ZE we go linearly to zero
            for i=(obj.LLP+3):(obj.ZE+2)
                series(:,i)=lqp - (i-obj.LLP-2)*lqp/(obj.ZE-obj.LLP);
            end
            %after the ZE, it's zero
            for i = (obj.ZE+3):curvelength
                series(:,i) = zeros(size(corrNumElements,1),1);
            end
            
            %SCR LQP does not require conversion from fwd to spot            
            
            series = (series>0).*series;   %remove all negative values

        end
        
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

