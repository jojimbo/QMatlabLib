classdef BaseBootstrapValidationAlgorithm < prursg.BootstrapValidation.IBootstrapValidationAlgorithm
    %BASEBOOTSTRAPVALIDATIONALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        validationAlgorithm
        reportTemplate
        reportName
        description
        format
        effectiveDate
        fromDate
        toDate
        frequency
        multiDateReports
        validationResultsPath
    end
    
    methods(Abstract)
        validationResults = GenerateBootstrapValidationResults(obj, inputData)
    end
    
    methods(Access = public)
        
        function obj = BaseBootstrapValidationAlgorithm()
            
        end      
        
    end
    
end

