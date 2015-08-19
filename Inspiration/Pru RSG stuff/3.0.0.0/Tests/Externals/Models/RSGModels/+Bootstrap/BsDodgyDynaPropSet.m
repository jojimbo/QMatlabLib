classdef BsDodgyDynaPropSet < prursg.Bootstrap.BaseBootstrapAlgorithm
    %Created to test what happens when a dynamic property is set to an
    %unsupported data type 
    
    properties
        Test1
        Test2
    end
    
    methods
        function obj = BsDodgyDynaPropSet()
        end  
        
        function outDataSeries = Bootstrap(obj, inDataSeries)
            outDataSeries = inDataSeries(1);
            outDataSeries = outDataSeries.Clone();
            outDataSeries.ratetype = {'credit'};
            disp('BsDodgyDynaPropSet Algorithm Bootstrap Method Called!');
        end
        
        function obj = Calibrate(obj, inDataSeries)
            disp('BsDodgyDynaPropSet Algorithm Bootstrap Calibrate Method Called!');
        end
    end
    
end
