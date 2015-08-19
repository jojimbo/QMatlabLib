%% Smoothing Algorithm Specification: Triangle
% Specification for smoothing algorithm to apply to scenarios to determine critical scenarios
%% Definitions
% windowSize    : one wing of (critical scenario) window; total (critical scenario) window = 2*windowSize+1 scenarios wide
%
% ii    : scenario number; ii = 1 to 2windowSize+1
%
% smoothingKernel(ii)   : weight applied to scenario ii (scaled)
 
 
classdef Triangle < prursg.CriticalScenario.ISmoothingRule
    % Represent triangle smoothing rule.
    
    properties
    end
    
    methods
    
        % smooth the data.
        function outData = Smooth(obj, inData, weightings, windowSize, shapeParameter)            
            outData = [];
            
            if ~isempty(inData)
                centreIndex = round(size(inData, 1) / 2);
                window = (centreIndex - windowSize):(centreIndex + windowSize);
                smoothingKernel = zeros(1,2*windowSize+1);
                for ii = 1:windowSize
                    smoothingKernel(ii) = ii;
                end
                
                smoothingKernel(windowSize+1)= windowSize+1;
                
                for ii = windowSize+2:2*windowSize+1
                    smoothingKernel(ii) = windowSize*2-ii+2;
                end
                
                if windowSize == 0
                    smoothingKernel(ii) = 1;
                end
                
                smoothingKernel = smoothingKernel/sum(smoothingKernel);
                
		for ii = 1:size(inData,2)
                    outData(ii) = dot(inData(window,ii)',smoothingKernel);
                end
            end
        end        
    end
    
end
