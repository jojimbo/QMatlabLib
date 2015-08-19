classdef BaseBootstrapAlgorithm < prursg.Bootstrap.IBootstrapAlgorithm
    %BASEBOOTSTRAPALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function outDataSeries = Bootstrap(obj, inDataSeries)
            outDataSeries = inDataSeries;
        end
        
        function Calibrate(obj)
        end
    end
    
end

