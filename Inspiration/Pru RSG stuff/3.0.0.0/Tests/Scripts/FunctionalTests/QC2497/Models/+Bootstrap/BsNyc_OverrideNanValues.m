classdef BsNyc_OverrideNanValues < prursg.Bootstrap.BaseBootstrapAlgorithm
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
            outDataSeries = outDataSeries.Clone();
            for i  = 1: length(outDataSeries.dates)
                outDataSeries.values{i}(find(isnan(outDataSeries.values{i}))) = 999999;
            end
            disp('BsNyc Algorithm Bootstrap Method Called!');
        end
        
        function obj = Calibrate(obj, inDataSeries)
            disp('BsNyc Algorithm Bootstrap Calibrate Method Called!');
        end
    end
    
end

