classdef Uniform < prursg.CriticalScenario.ISmoothingRule
    % Represents uniform smoothing rule.
    
    properties
    end
    
    methods
    
        % smooth the data.
        function outData = Smooth(obj, inData, weightings, windowSize, shapeParameter)            
            outData = [];
            
            if ~isempty(inData)
                centreIndex = round(size(inData, 1) / 2);
                window = (centreIndex - windowSize):(centreIndex + windowSize);
                outData = mean(inData(window, :), 1);
            end
        end        
    end
    
end

