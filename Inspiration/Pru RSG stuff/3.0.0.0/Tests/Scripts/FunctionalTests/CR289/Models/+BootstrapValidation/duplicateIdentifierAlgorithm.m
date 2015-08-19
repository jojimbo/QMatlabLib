classdef duplicateIdentifierAlgorithm < prursg.BootstrapValidation.BaseBootstrapValidationAlgorithm
    %MYNEWVALIDATIONALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        desc
        amount
    end
    
    methods
        function obj = duplicateIdentifierAlgorithm()
        end
        
        function validationResults = GenerateBootstrapValidationResults(obj, inputData)
           validationResults = prursg.BootstrapValidation.ValidationResults();
           validationResults.AddResults('string', 'ID1', 'testing');
           validationResults.AddCustomProperty('string', 'Param1', 'custom1');
           validationResults.AddResults('double', 'num1', 202500.23);
           validationResults.AddResults('image', 'im1', 'testingImage');
           validationResults.AddCustomProperty('string', 'Param2', 'custom2');
           validationResults.AddResults('table', 'table1', {1,2,3;'cr',4,'br'});
           validationResults.AddCustomProperty('date', 'myDate', '10/MAR/1981');
           validationResults.AddCustomProperty('string', 'ID1', 'duplicate');
        end
    end
    
end

