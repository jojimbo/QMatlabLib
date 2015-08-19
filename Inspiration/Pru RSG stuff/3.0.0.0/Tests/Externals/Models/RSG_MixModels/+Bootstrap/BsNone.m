classdef BsNone < prursg.Bootstrap.BaseBootstrapAlgorithm
    
    properties
    
    end
    
    methods
        function obj = BsNone()
        end  
        
        function outDataSeries = Bootstrap(obj, inDataSeries)
            outDataSeries = inDataSeries(1);
        end
        
        function obj = Calibrate(obj, inDataSeries)
            
        end
    end
    
end

