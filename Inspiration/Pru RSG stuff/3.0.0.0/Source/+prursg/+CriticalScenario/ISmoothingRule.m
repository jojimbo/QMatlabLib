classdef ISmoothingRule < handle    
    % Smoothing Rule interface.
    
    properties
        
    end
    
    methods(Abstract)
        outData = Smooth(obj, inData, weightings, windowSize, shapeParameter)
    end
    
end
