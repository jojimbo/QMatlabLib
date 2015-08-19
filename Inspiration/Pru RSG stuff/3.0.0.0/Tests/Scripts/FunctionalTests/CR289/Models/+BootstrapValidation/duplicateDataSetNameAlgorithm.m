classdef duplicateDataSetNameAlgorithm < prursg.BootstrapValidation.BaseBootstrapValidationAlgorithm
    %MYNEWVALIDATIONALGORITHM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        desc
        amount
    end
    
    methods
        function obj = duplicateDataSetNameAlgorithm()
        end
        
        function validationResults = GenerateBootstrapValidationResults(obj, inputData)
            
            % Retrieve the first set of time series data using the name as
            % specified in the XML control file
            rowDataSet = inputData('RowDataSet');
            
            % Retrieve the second set of time series data using the name as
            % specified in the XML control file
            bootstrappedDataSet = inputData('BootstrappedDataSet');
            
            % Get the first time series from each of the sets
            firstOfFirstSet = rowDataSet(1);
            firstOfSecondSet = bootstrappedDataSet(1);
            
            % Initialize the ValidationResults object to hold the
            % individual validation results items
            validationResults = prursg.BootstrapValidation.ValidationResults();
           
            % Add a validation result of type 'string'
            validationResults.AddResults('string', 'Currency', firstOfFirstSet.Currency);
            
            % Add a custom parameter of type 'string'. The RSG will
            % determine the type of the parameters. There is no need to set
            % them manually.
            validationResults.AddCustomProperty('string', 'ratetype', firstOfFirstSet.ratetype);
            
            % Add a validation result of type 'double'
            validationResults.AddResults('double', 'daysInFiveCompoundingPeriods', firstOfFirstSet.daycount/firstOfFirstSet.compoundingfrequency*5);
            
            % Initialize two variables to be used in the graph
            x = -pi:.1:pi;
            y = sin(x);
            
            % Set the properties of the graph
            set(gcf, 'Visible', 'off');
            set(gcf, 'PaperType', 'A1');
            
            % Run the command to create the graph
            plot(x,y);
            
            % Save the results in the path specified in the
            % validationResultsPath property of the validation algorithm
            
            graphName = [obj.validationResultsPath 'myNewImage.png'];
            print('-dpng', graphName);
            
            % Add a validation result of type 'image'            
            validationResults.AddResults('image', 'newImage', graphName);
            
            % Add a custom parameter of type 'double'
            validationResults.AddCustomProperty('double', 'daycount', 123456);
            
            % Add a validation result of type 'table'
            validationResults.AddResults('table', 'dataForDS1', num2cell(firstOfFirstSet.values{1,1}(:,:,1)));
            
            % Add a custom parameter of type 'date'
            validationResults.AddCustomProperty('date', 'firstDate', firstOfFirstSet.dates{1});
        end
    end
    
end

