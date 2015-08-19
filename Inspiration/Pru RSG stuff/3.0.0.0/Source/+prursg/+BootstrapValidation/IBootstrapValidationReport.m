classdef IBootstrapValidationReport < dynamicprops
    % Interface for the Bootstrap Validation
    
    methods (Abstract)
        % Method that generates a Report
        Generate(obj)
    end
end
