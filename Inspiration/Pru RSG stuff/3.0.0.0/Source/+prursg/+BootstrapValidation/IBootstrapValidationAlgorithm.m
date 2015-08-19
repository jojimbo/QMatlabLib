classdef IBootstrapValidationAlgorithm < handle
    %IBOOTSTRAPALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        validationResults = GenerateBootstrapValidationResults(obj, inputData)
    end
    
end

