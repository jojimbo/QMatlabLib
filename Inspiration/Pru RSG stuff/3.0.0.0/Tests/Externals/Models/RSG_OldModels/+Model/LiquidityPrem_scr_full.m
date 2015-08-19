classdef LiquidityPrem_scr_full < prursg.Engine.Model    

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
        wcmbssen_AAA = [];
        wcmbsot_AAA = [];
        wcmbs_AA = [];
        wcmbs_A = [];
        wcmbs_BBB = [];
        wcmbs_BB = [];
        wcmbs_B = [];
        wabs_AAA = [];
        wabs_AA = [];
        wabs_A = [];
        wabs_BBB = [];
        wabs_BB = [];
        wabs_B = [];
        wrmbs_AAA = [];
        wrmbs_AA = [];
        wrmbs_A = [];
        wrmbs_BBB = [];
        wrmbs_BB = [];
        wrmbs_B = [];
    end
        
    methods
        function obj = LiquidityPrem_scr_full()
            % Constructor
            obj = obj@prursg.Engine.Model('LiquidityPrem_scr_full');
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
            cmbssen_spdAAA = workerObj.getSimResults(precedentList('spdcmbssen_AAA'));
            cmbsot_spdAAA = workerObj.getSimResults(precedentList('spdcmbsot_AAA'));
            cmbs_spdAA = workerObj.getSimResults(precedentList('spdcmbs_AA'));
            cmbs_spdA = workerObj.getSimResults(precedentList('spdcmbs_A'));
            cmbs_spdBBB = workerObj.getSimResults(precedentList('spdcmbs_BBB'));
            cmbs_spdBB = workerObj.getSimResults(precedentList('spdcmbs_BB'));
            cmbs_spdB = workerObj.getSimResults(precedentList('spdcmbs_B'));
            abs_spdAAA = workerObj.getSimResults(precedentList('spdabs_AAA'));
            abs_spdAA = workerObj.getSimResults(precedentList('spdabs_AA'));
            abs_spdA = workerObj.getSimResults(precedentList('spdabs_A'));
            abs_spdBBB = workerObj.getSimResults(precedentList('spdabs_BBB'));
            abs_spdBB = workerObj.getSimResults(precedentList('spdabs_BB'));
            abs_spdB = workerObj.getSimResults(precedentList('spdabs_B'));
            rmbs_spdAAA = workerObj.getSimResults(precedentList('spdrmbs_AAA'));
            rmbs_spdAA = workerObj.getSimResults(precedentList('spdrmbs_AA'));
            rmbs_spdA = workerObj.getSimResults(precedentList('spdrmbs_A'));
            rmbs_spdBBB = workerObj.getSimResults(precedentList('spdrmbs_BBB'));
            rmbs_spdBB = workerObj.getSimResults(precedentList('spdrmbs_BB'));
            rmbs_spdB = workerObj.getSimResults(precedentList('spdrmbs_B'));
            %cml_spdBBB = workerObj.getSimResults(precedentList('cml_spdBBB'));
            %cml_spdBB = workerObj.getSimResults(precedentList('cml_spdBB'));
            lqp = obj.mult*(spdAAA(:,1)*obj.wAAA + spdAA(:,1)*obj.wAA + spdA(:,1)*obj.wA + spdBBB(:,1)*obj.wBBB + spdBB(:,1)*obj.wBB + spdB(:,1)*obj.wB + ...
                cmbssen_spdAAA(:,1)*obj.wcmbssen_AAA + cmbsot_spdAAA(:,1)*obj.wcmbsot_AAA + cmbs_spdAA(:,1)*obj.wcmbs_AA + cmbs_spdA(:,1)*obj.wcmbs_A + ...
                cmbs_spdBBB(:,1)*obj.wcmbs_BBB + cmbs_spdBB(:,1)*obj.wcmbs_BB + cmbs_spdB(:,1)*obj.wcmbs_B + abs_spdAAA(:,1)*obj.wabs_AAA + ...
                abs_spdAA(:,1)*obj.wabs_AA + abs_spdA(:,1)*obj.wabs_A + abs_spdBBB(:,1)*obj.wabs_BBB + abs_spdBB(:,1)*obj.wabs_BB + ...
                abs_spdB(:,1)*obj.wabs_B + rmbs_spdAAA(:,1)*obj.wrmbs_AAA + rmbs_spdAA(:,1)*obj.wrmbs_AA + rmbs_spdA(:,1)*obj.wrmbs_A + ...
                rmbs_spdBBB(:,1)*obj.wrmbs_BBB + rmbs_spdBB(:,1)*obj.wrmbs_BB rmbs_spdB(:,1)*obj.wrmbs_B - obj.deduct);
            
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

