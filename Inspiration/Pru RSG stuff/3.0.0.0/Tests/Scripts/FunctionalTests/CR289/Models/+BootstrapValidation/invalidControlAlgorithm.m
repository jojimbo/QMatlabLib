classdef invalidControlAlgorithm < prursg.BootstrapValidation.BaseBootstrapValidationAlgorithm
    %MYNEWVALIDATIONALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        desc
        amount
    end
    
    methods
        function obj = invalidControlAlgorithm()
        end
        
        function validationResults = GenerateBootstrapValidationResults(obj, inputData)
           validationResults = prursg.BootstrapValidation.ValidationResults();
           validationResults.AddResults('string', 'ID1', 'testing');
           validationResults.AddResults('double', 'num1', 202500.23);
           validationResults.AddResults('image', 'im1', 'testingImage');
           validationResults.AddResults('table', 'table1', {1,2,3;'cr',4,'br'});
        end
    end
    
end

