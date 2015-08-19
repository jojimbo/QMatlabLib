classdef Op_Agg < prursg.Engine.Model    

    properties
   %% 
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
      p36 = [];
      p37 = [];
      p38 = [];
      p39 = [];
      p40 = [];
      p41 = [];
      p42 = [];
      p43 = [];
      p44 = [];
      p45 = [];
      p46 = [];
      p47 = [];
      p48 = [];
      p49 = [];
      p50 = [];
      p51 = [];
      p52 = [];
      p53 = [];
      p54 = [];
      p55 = [];
      p56 = [];
      p57 = [];
      p58 = [];
      p59 = [];
      p60 = [];
      p61 = [];
      p62 = [];
      p63 = [];
      p64 = [];
      p65 = [];
      p66 = [];
      p67 = [];
      p68 = [];
      p69 = [];
      p70 = [];
      p71 = [];
      p72 = [];
      p73 = [];
      p74 = [];
      p75 = [];
      p76 = [];
      p77 = [];
      p78 = [];
      p79 = [];
      p80 = [];
      p81 = [];
      p82 = [];
      p83 = [];
      p84 = [];
      p85 = [];
      p86 = [];
      p87 = [];
      p88 = [];
      p89 = [];
      p90 = [];
      p91 = [];
      p92 = [];
      p93 = [];
      p94 = [];
      p95 = [];
      p96 = [];
      p97 = [];
      p98 = [];
      p99 = [];
      p100 = [];
      p101 = [];
      p102 = [];
      p103 = [];
      p104 = [];
      p105 = [];
      p106 = [];
      p107 = [];
      p108 = [];
      p109 = [];
      p110 = [];
      p111 = [];
      p112 = [];
      p113 = [];
      p114 = [];
      p115 = [];
      p116 = [];
      p117 = [];
      p118 = [];
      p119 = [];
      p120 = [];
      p121 = [];
      p122 = [];
      p123 = [];
      p124 = [];
      p125 = [];
      p126 = [];
      p127 = [];
      p128 = [];
      p129 = [];
      p130 = [];
      p131 = [];
      p132 = [];
      p133 = [];
      p134 = [];
      p135 = [];
      p136 = [];
      
      
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
      w36 = [];
      w37 = [];
      w38 = [];
      w39 = [];
      w40 = [];
      w41 = [];
      w42 = [];
      w43 = [];
      w44 = [];
      w45 = [];
      w46 = [];
      w47 = [];
      w48 = [];
      w49 = [];
      w50 = []
      w51 = [];
      w52 = [];
      w53 = [];
      w54 = [];
      w55 = [];
      w56 = [];
      w57 = [];
      w58 = [];
      w59 = [];
      w60 = [];
      w61 = [];
      w62 = [];
      w63 = [];
      w64 = [];
      w65 = [];
      w66 = [];
      w67 = [];
      w68 = [];
      w69 = [];
      w70 = [];
      w71 = [];
      w72 = [];
      w73 = [];
      w74 = [];
      w75 = [];
      w76 = [];
      w77 = [];
      w78 = [];
      w79 = [];
      w80 = [];
      w81 = [];
      w82 = [];
      w83 = [];
      w84 = [];
      w85 = [];
      w86 = [];
      w87 = [];
      w88 = [];
      w89 = [];
      w90 = [];
      w91 = [];
      w92 = [];
      w93 = [];
      w94 = [];
      w95 = [];
      w96 = [];
      w97 = [];
      w98 = [];
      w99 = [];
      w100 = [];
      w101 = [];
      w102 = [];
      w103 = [];
      w104 = [];
      w105 = [];
      w106 = [];
      w107 = [];
      w108 = [];
      w109 = [];
      w110 = [];
      w111 = [];
      w112 = [];
      w113 = [];
      w114 = [];
      w115 = [];
      w116 = [];
      w117 = [];
      w118 = [];
      w119 = [];
      w120 = [];
      w121 = [];
      w122 = [];
      w123 = [];
      w124 = [];
      w125 = [];
      w126 = [];
      w127 = [];
      w128 = [];
      w129 = [];
      w130 = [];
      w131 = [];
      w132 = [];
      w133 = [];
      w134 = [];
      w135 = [];
      w136 = [];

    end
        
    methods
        function obj = Op_Agg()
            % Constructor
            obj = obj@prursg.Engine.Model('Op_Agg');
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

