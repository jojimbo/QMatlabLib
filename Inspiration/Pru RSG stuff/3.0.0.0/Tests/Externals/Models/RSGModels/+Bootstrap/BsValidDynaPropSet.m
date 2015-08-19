classdef BsValidDynaPropSet < prursg.Bootstrap.BaseBootstrapAlgorithm
    %Created to test what happens when a dynamic property is set to a
    %supported data type 
    
    properties
        Test1
        Test2
    end
    
    methods
        function obj = BsValidDynaPropSet()
        end  
        
        function outDataSeries = Bootstrap(obj, inDataSeries)
            outDataSeries = inDataSeries(1);
            outDataSeries = outDataSeries.Clone();
            outDataSeries.ratetype = 'credit';
            disp('BsValidDynaPropSet Algorithm Bootstrap Method Called!');
        end
        
        function obj = Calibrate(obj, inDataSeries)
            disp('BsValidDynaPropSet Algorithm Bootstrap Calibrate Method Called!');
        end
    end
    
end

