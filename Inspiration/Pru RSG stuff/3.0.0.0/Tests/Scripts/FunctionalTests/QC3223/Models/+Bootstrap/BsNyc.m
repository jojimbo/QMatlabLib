classdef BsNyc < prursg.Bootstrap.BaseBootstrapAlgorithm
    %BSNYC Bootstrapping nominal yield curve
    %   Detailed function may go to subclass
    
    properties
        Test1
        Test2
    end
    
    methods
        function obj = BsNyc()
        end  
        
        function outDataSeries = Bootstrap(obj, inDataSeries)
            outDataSeries = inDataSeries(1);
            disp('BsNyc Algorithm Bootstrap Method Called!');
        end
        
        function obj = Calibrate(obj, inDataSeries)
            disp('BsNyc Algorithm Bootstrap Calibrate Method Called!');
        end
    end
    
end

