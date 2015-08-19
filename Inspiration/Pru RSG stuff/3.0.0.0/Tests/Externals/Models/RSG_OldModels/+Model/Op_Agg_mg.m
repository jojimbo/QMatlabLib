classdef Op_Agg_mg < prursg.Engine.Model    

    properties
      p1 = [];
      p2 = [];
      p3 = [];
      p4 = [];
      p5 = [];
      p6 = [];
      p7 = [];
      p8 = [];
      p9 = [];
      p10 = [];
      p11 = [];
      p12 = [];
      p13 = [];
      p14 = [];
      p15 = [];
      p16 = [];
      p17 = [];
      p18 = [];
      p19 = [];
      p20 = [];
      p21 = [];
      p22 = [];
      p23 = [];
      p24 = [];
      p25 = [];
      p26 = [];
      p27 = [];
      p28 = [];
      p29 = [];
      p30 = [];
      p31 = [];
      p32 = [];
      p33 = [];
      p34 = [];
      p35 = [];
      w1 = [];
      w2 = [];
      w3 = [];
      w4 = [];
      w5 = [];
      w6 = [];
      w7 = [];
      w8 = [];
      w9 = [];
      w10 = [];
      w11 = [];
      w12 = [];
      w13 = [];
      w14 = [];
      w15 = [];
      w16 = [];
      w17 = [];
      w18 = [];
      w19 = [];
      w20 = [];
      w21 = [];
      w22 = [];
      w23 = [];
      w24 = [];
      w25 = [];
      w26 = [];
      w27 = [];
      w28 = [];
      w29 = [];
      w30 = [];
      w31 = [];
      w32 = [];
      w33 = [];
      w34 = [];
      w35 = [];
    end
        
    methods
        function obj = Op_Agg_mg()
            % Constructor
            obj = obj@prursg.Engine.Model('Op_Agg_mg');
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
            for ii = 1:length(precedentList)
                p(ii,:) = eval(['workerObj.getSimResults(precedentList(''p' num2str(ii) '''))']);
                w(ii) = eval(['obj.w' num2str(ii) ';']);
            end
            series = (w*p)';
        end
        
        
        function s = validateCalibration( obj )
            s = 'Not implemented';
        end
       
        
    end
    
end

