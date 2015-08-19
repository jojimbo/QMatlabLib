classdef IBootstrapAlgorithm < handle
    %IBOOTSTRAPALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        outDataSeries = Bootstrap(obj, dataSeries)
        Calibrate(obj)
    end
    
end

