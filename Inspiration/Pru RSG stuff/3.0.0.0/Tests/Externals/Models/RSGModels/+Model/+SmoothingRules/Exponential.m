classdef Exponential < prursg.CriticalScenario.ISmoothingRule
    % Represent exponential smoothing rule.
    
    properties
    end
    
    methods
        
        function outData = Smooth(obj, inData, weightings, windowSize, shapeParameter)                        
            outData = [];
            
            if ~isempty(inData)
                
                centreIndex = round(size(inData, 1) / 2);
                window = (centreIndex - windowSize):(centreIndex + windowSize);
                inData = inData(window, :);
                                
               
                smoothingFactor = 0.2;

                centreIndex = round(size(inData, 1) / 2);
                smoothedData = zeros(size(inData));
                for i = 1:centreIndex
                    if i == 1
                        smoothedData(i, :) = inData(1, :);
                        smoothedData(end, :) = inData(end, :);
                    elseif i == centreIndex
                         smoothedData(i, :) = smoothingFactor * inData(i, :) + ( 1 - smoothingFactor) * smoothedData(i - 1, :);   
                    else
                        smoothedData(i, :) = smoothingFactor * inData(i, :) + ( 1 - smoothingFactor) * smoothedData(i - 1, :);
                        smoothedData(end - i + 1, :) = smoothingFactor * inData(end - i + 1, :) + ( 1 - smoothingFactor) * smoothedData(end - i + 2, :);
                    end
                end

                outData = mean(smoothedData, 1);
            end        
        end
    end
    
end

