%% Smoothing Algorithm Specification: Gaussian
% Specification for smoothing algorithm to apply to scenarios to determine critical scenarios
%% Definitions
% k : one wing of (critical scenario) window; total (critical scenario) window = 2k+1 scenarios wide
% 
% i : scenario number; i = 1 to 2k+1
% 
% sigma : standard deviation of Gaussian curve
% 
% sum_nwt   : sum of nwt(i) (i = 1 to 2k+1)
% 
% nwt(i)    : weight applied to scenario i (NOT scaled)
% 
% wt(i) : weight applied to scenario i (scaled)
%% Calculations
% To calculate wt(i):
%   
%   nwt(i) = exp(-0.5* (k/(window_size*sigma))^2) where k is the distance from the centre
%   of the window
% 
%   wt(i) = nwt(i) / sum_nwt
classdef Gaussian < prursg.CriticalScenario.ISmoothingRule
    % Represent triangle smoothing rule.
    
    properties
    end
    
    methods
    
        % smooth the data.
        function outData = Smooth(obj, inData, weightings, windowSize, shapeParameter)            
            
            outData = [];
            sigma = shapeParameter;
            
            if ~isempty(inData)
                centreIndex = round(size(inData, 1) / 2);
                window = (centreIndex - windowSize):(centreIndex + windowSize);
                smoothingKernel = zeros(1,2*windowSize+1);
                
                for ii = 1:(2 * windowSize + 1)
                    k = ii - 1 - windowSize;
                    smoothingKernel(ii) = exp(-0.5 * (k /(sigma * windowSize))^2);
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