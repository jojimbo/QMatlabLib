classdef correctOrderInputDataSeriesAlgorithm < prursg.BootstrapValidation.BaseBootstrapValidationAlgorithm
    %MYNEWVALIDATIONALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        desc
        amount
    end
    
    methods
        function obj = correctOrderInputDataSeriesAlgorithm()
        end
        
        function validationResults = GenerateBootstrapValidationResults(obj, inputData)
            disp('entering algorithm');
            
            oddDataSetXML = {'TestOrder1' 'TestOrder3' 'TestOrder5'};
            evenDataSetXML = {'TestOrder2' 'TestOrder4' 'TestOrder6'};
            
            % Retrieve the first set of time series data using the name as
            % specified in the XML control file
            oddDataSet = inputData('OddDataSet');
            
            % Retrieve the second set of time series data using the name as
            % specified in the XML control file
            evenDataSet = inputData('EvenDataSet');
            
            % Get the first time series from each of the sets
            fprintf('The oddDataSet contains input time series in the following order:\n')
            for i = 1:numel(oddDataSet) 
                dataSeries = oddDataSet(i);
                fprintf('%s) %s\n', num2str(i), dataSeries.Name);
                assertTrue(strcmp(oddDataSetXML{i}, dataSeries.Name), 'The order of the input data series does not much the one specified in the control XML file');
            end
            
            fprintf('The evenDataSet contains input time series in the following order:\n')
            for i = 1:numel(evenDataSet) 
                dataSeries = evenDataSet(i);
                fprintf('%s) %s\n', num2str(i), dataSeries.Name);
                assertTrue(strcmp(evenDataSetXML{i}, dataSeries.Name), 'The order of the input data series does not much the one specified in the control XML file');
            end
            
            validationResults = [];
        end
    end
    
end

