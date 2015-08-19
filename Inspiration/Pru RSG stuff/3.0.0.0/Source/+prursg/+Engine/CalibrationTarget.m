classdef CalibrationTarget < handle
    %CALIBRATIONTARGETS definition of a calibration to percentiles
    
    properties
        percentile  % string like 'mean' or '95%' or ...
        value       % value like 0.01, 1 etc
    end
            
    methods (Static)
        function targets = fromXml(xmlCalibTargets)
            % parse one or more calibration targets
            targets = [] ;
            if(~isempty(xmlCalibTargets))
                for i = 1:xmlCalibTargets.getLength()
                    xmlTarget = xmlCalibTargets.item(i - 1);
                    target = prursg.Engine.CalibrationTarget();
                    target.percentile = char(xmlTarget.getAttribute('percentile'));
                    target.value = str2double(xmlTarget.getFirstChild().getData());
                    targets = [ targets target ]; %#ok<AGROW>
                    %targets(end + 1) = target; %#ok<AGROW>
                end
            end
        end
    end
end

