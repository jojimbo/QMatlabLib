%% Bootstrap Validation - BootstrapValidationEngine
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *Description*
%
% The bootstrap validation engine controls the bootstrap validation
% process. The engine will perform the following tasks:
%
%   - Parse the input XML control file
%   - Instantiate the bootstrap validation algorithm specified in the input
%   XML control file
%   - Set the properties for the algorithm specified in the input XML
%   control file
%   - Retrieve the input data series set specified in the input XML control
%   file
%   - Invoke the algorithm with the data series set to perform the
%   bootstrap validation
%   - Persist the bootstrap validation results returned by the algorithm to
%   the file system in an intermediate file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef BootstrapValidationEngine < handle
%% How to Use the Class
%
% This class contains a single method, |[BootstrapValidate]|, which takes as
% input a string specifying the fully qualified path to the input XML
% control file.
%
% A number of private methods exist that assist in parsing the input XML
% control file, extracting the necessary information and building the input
% data that will be passed to the bootstrapping validation algorithm.
%

%% Properties
% These is a single property defined for the bootstrap validation engine,
% which is the following:
% 
% *|[readDao]|* - an instance of HistoricalDataDao for reading the required
% data series for the bootstrap validation process. Depending on the
% configuration, the data series will be retrieved either from the Market
% Data Store (MDS) or from XML files.
%
%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    properties(Access=private) 
        % Instance of HistoricalDataDao
        readDao
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% List of Methods
% This bootstrap validation engine class introduces the following method:
%
% *|[BootstrapValidate(obj, xmlFilePath)]|* - A function that handles the 
%   parsing of the input XML control file, the instantiation of the 
%   bootstrapping validation algorithm and population of its properties,
%   and the persistence of the validation results
%
       
%MATLAB CODE    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        function obj = BootstrapValidationEngine()
            addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
            import BootstrapValidation.*;
            factory = prursg.HistoricalDAO.HistoricalDataDaoFactory();
            obj.readDao = factory.Create(); 
        end 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[BootstrapValidate(obj, xmlFilePath)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function handles the whole bootstrap validation process. The engine
% will perform the following tasks:
%
%   - Parse the input XML control file
%   - Instantiate the bootstrap validation algorithm specified in the input
%   XML control file
%   - Set the properties for the algorithm specified in the input XML
%   control file
%   - Retrieve the input data series set specified in the input XML control
%   file
%   - Invoke the algorithm with the data series set to perform the
%   bootstrap validation
%   - Persist the bootstrap validation results returned by the algorithm to
%   the file system in an intermediate file
%
% *_Inputs_*
%
% |[xmlFilePath]| - A full qualified path pointing to the folder where the 
% input XML control file is stored.          
% 
% _Data Type_: string
% 
% *_Outputs_*
%
% |[Outputfiles]| - A fully qualified path pointing to the folder where the
% validation results (including the intermediate file) have been stored
%
% _Data Type_: string
%
% *_Calculation_*
%
% STEP 0: The Document Builder Factory is set up and the input XML control
% file is parsed
%
% STEP 1: All ValidationReport elements are retrieved. For each 
% ValidationReport element, the steps 2 to 5 described below are performed:
%
% STEP 2: The GetValidationAlgorithm method is called passing the validation 
% report node (returned from xpath), the xpath doc, and the readDao. This 
% method will instantiate and return the bootstrap validation algorithm
% object after its properties have been set using the attributes defined 
% for the ValidationReport element.
%
% STEP 3: The ProcessValidationReport method is called  passing the validation 
% report node (returned from xpath), the xpath doc, and the readDao. The 
% ProcessValidationReport is a private method and it returns the input data
% that will be passed to the GenerateBootstrapValidationResults method of
% the bootstrap validation algorithm. The ProcessValidationReport method
% retrieves all the DataSets defined under the ValidationReport element.
% For each DataSet element, the steps described below are performed:
%
% STEP 4: The data set name is retrieved to be used as the key to the input
% data map. The ProcessDataSet method is called passing the data set node
% (returned from xpath), the xpath doc, and the readDao. The ProcessDataSet
% is a private method and it returns an array containing the data series
% objects retrieved either from the Market Data Store (MDS) or the XML
% files. The ProcessDataSet method retrieves all DataSeries defined under
% the DataSet element. For each DataSeries element, the steps descrived
% below are performed:
%
% STEP 5: The RetrieveDataSeries method is called passing the DataSeries
% node (returned from xpath) and the readDao. The RetrieveDataSeries is a
% private method and it returns a populated DataSeries object based on its
% name. Initially the properties of the DataSeries object are set, as
% specified in the input XML control file, and then the PopulateData method
% of the HistoricalDataDao is called.
%
% STEP 6: When steps 3 to 5 have been completed, the
% GenerateBootstrapValidationResults method of the bootstrap validation
% algorithm is called passing the input data as argument. The input data is
% a map where the key is the data set name and the value is an array of
% DataSeries objects defined under that DataSet in the input XML control
% file. The output of the GenerateBootstrapValidationResults method will be
% a ValidationResults object containing the bootstrap validation results.
%
% STEP 7: The PersistValidationResults method is called passing the
% bootstrap validation results and the output directory where the
% intermediate files will be saved. The PersistValidationResults method is
% a private method and it will construct the intermediate XML file in order
% to persist the validation results.
%
% STEP 8: Return the fully qualified path to the output directory where the
% bootstrap validation results have been persisted.
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

        function OutputFilesPath = BootstrapValidate(obj, xmlFilePath)
            import javax.xml.xpath.*;
            
            outputDir = obj.readDao.OutputDir;
            
            
            [valid errorMessage] = schemaValidation(xmlFilePath);
            
            if (~valid)
                ex = MException('BootstrapValidationEngine:BootstrapValidate:InvalidControlXML',...
                    ['The control XML file provided does not conform to the schema defined for bootstrap validation. The error message is: ' errorMessage]);                
                throw(ex);  
            end
    
            outputDir = fullfile(outputDir, 'RSGBootstrapValidate', datestr(now, 30));
            mkdir(outputDir);
            
            % STEP 0: Set-up the Document Builder Factory and parse the
            % input XML control file
            xPathDoc = prursg.Xml.XPathDoc(xmlFilePath);
            
            % STEP 1: Retrieve all the ValidationReport elements.
            validationReports = xPathDoc.Evaluate('//ValidationReport', XPathConstants.NODESET);
            
            if ~isempty(validationReports)
                for i = 1:validationReports.getLength()
                    validationReport = validationReports.item(i - 1);
                    
                    reportNodeList = xPathDoc.Evaluate('./@reportName', XPathConstants.NODESET, validationReport);
                    reportName = reportNodeList.item(0).getValue();
                    fprintf('Report %s is currently being procesed.\n', char(reportName));
                    try
                        % STEP 2: Call the GetValidationAlgorithm method 
                        validationAlgorithm = GetValidationAlgorithm(validationReport, xPathDoc, outputDir);
                        
                        % STEP 3: Call the ProcessValidationReport method
                        inputData = ProcessValidationReport(validationReport, xPathDoc, obj.readDao, ...
                            validationAlgorithm.effectiveDate, validationAlgorithm.toDate, validationAlgorithm.fromDate, validationAlgorithm.frequency);
                        
                        % STEP 6: Call the GenerateBootstrapValidationResults method
                        validationResults = validationAlgorithm.GenerateBootstrapValidationResults(inputData);
                        
                        % STEP 7: Call the PersistValidationResults method
                        PersistValidationResults(validationResults, validationAlgorithm);
                        %fprintf('BootstrapValidationEngine: Validation report %s has been produced successfully. The validation report has been saved in %s\n',...
                        %    char(validationReport.getAttribute('reportName')), 'fix this path');
                    catch e
                        fprintf('\nERROR: BootstrapValidationEngine: Validation report %s failed to be generated, error is \n%s\n %s\n',...
                            char(validationReport.getAttribute('reportName')), e.message, 'The next validation report will now be processed (if present).');
                        %disp(e.message);
                    end
                    
                    fprintf('Processing of report %s has finished.\n', char(reportName));
                    
                end
                
            end
            
            
            fprintf('The validation results can be found under %s\n', fullfile(outputDir));
            % STEP 8: Return the fully qualified path to the output directory
            OutputFilesPath = fullfile(outputDir);
            %OutputFilesPath = validationAlgorithm.validationResultsPath;
            xPathDoc= [];
            
            
        end
        
    end
    
end

function inputData = ProcessValidationReport(validationReport, xPathDoc, readDao, varargin)
    import javax.xml.xpath.*;
            
    inputData = containers.Map('KeyType', 'char', 'ValueType', 'any');

    dataSetsList = xPathDoc.Evaluate('./InputDataSets/DataSet', XPathConstants.NODESET, validationReport);
    if ~isempty(dataSetsList)
        for i = 1:dataSetsList.getLength()
            dataSet = dataSetsList.item(i - 1);
            % STEP 4: The data set name is retrieved
            dataSetName = char(dataSet.getAttribute('name'));
            
            % STEP 4: Call the ProcessDataSet method
            dataSeriesArray = ProcessDataSet(dataSet, xPathDoc, readDao, varargin{1}, varargin{2}, varargin{3}, varargin{4});
            
            if (isKey(inputData, dataSetName))
                
                ex = MException('BootstrapValidationEngine:ProcessValidationReport:DuplicateDataSeriesName',...
                    ['BootstrapValidationEngine:ProcessValidationReport:DuplicateDataSeriesName: The data set name ''' dataSetName ...
                    ''' has been used multiple times in this validation report.']);
                throw(ex);
                
            else
                
                inputData(dataSetName) = dataSeriesArray;
                
            end

        end
    end
    
    % validate retrieved data series.
    emptyDataSeries = ValidateDataSeries(inputData);
    if ~isempty(emptyDataSeries)... || isempty(ds.dates)
            
        emptyDataSeries(2,:) = {', '};
        emptyDataSeries{2,end} = '';
        ex = MException('BootstrapValidationEngine:ProcessValidationReport:EmptyInputDataSeries',...
            ['BootstrapValidationEngine:ProcessValidationReport:EmptyInputDataSeries: The requested input data series(' ...
            [emptyDataSeries{:}] ') cannot be found. The next validation report will be processed now (if present).']);
        throw(ex);
    end
end

function emptyDataSeries = ValidateDataSeries(inputData)

    dsKeys = keys(inputData);
    emptyDataSeries = [];
    
    for i = 1:numel(dsKeys)
        
        dsKey = dsKeys{i};
        
        if (isempty(inputData(dsKey)))
            emptyDataSeries{end+1} = dsKey;
        end
    end

end

function dataSeriesArray = ProcessDataSet(dataSet, xPathDoc, readDao, varargin)
    import javax.xml.xpath.*;
    
    dataSeriesArray = prursg.Engine.DataSeries.empty();
    
    dataSeriesList = xPathDoc.Evaluate('./DataSeries', XPathConstants.NODESET, dataSet);
    if ~isempty(dataSeriesList)
        for i = 1:dataSeriesList.getLength()
            dataSeriesNode = dataSeriesList.item(i - 1);

            % STEP 5: Call the RetrieveDataSeries method
            dataSeries = RetrieveDataSeries(dataSeriesNode, readDao, varargin{1}, varargin{2}, varargin{3}, varargin{4});

            if ~isempty(dataSeries)
                dataSeriesArray(end + 1) = dataSeries;
            end 
            
        end
    end


end

function cdataTag = putStringInXML(dom, theValue)

    cdataTag = dom.createCDATASection(theValue);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[dataSeries = RetrieveDataSeries(dataSeriesNode, readDao)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function is responsible for retrieving the DataSeries data that are
% specified in the control XML file.
%
%   - Retrieve all attributes from the XML element and populate the
%   respective variables.
%   - Call the PopulateData function of the DAO to retrieve the DataSeries
%   data
%
% *_Inputs_*
%
% |[dataSeriesNode]| - The XML element for the data series
% 
% _Data Type_: object
%
% |[readDao]| - The DAO object that will be used to retrieve the DataSeries
% data
% 
% _Data Type_: object
%
% |[varargin]| - A cell array that contains the effective, to and from
% dates as well as the frequency of the data series
% 
% _Data Type_: cell array
% 
% *_Outputs_*
%
% |[dataSeries]| - The retrieved DataSeries
%
% _Data Type_: object
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dataSeries = RetrieveDataSeries(dataSeriesNode, readDao, varargin)
    dataSeriesName = char(dataSeriesNode.getAttribute('name'));
    %from = char(dataSeriesNode.getAttribute('fromDate'));
    %to = char(dataSeriesNode.getAttribute('toDate'));
    %frequency = char(dataSeriesNode.getAttribute('frequency'));
    dateOfMonth = char(dataSeriesNode.getAttribute('dateOfMonth'));
    holidayCalendar = char(dataSeriesNode.getAttribute('holidayCalendar'));
    missingDataTreatmentRule = char(dataSeriesNode.getAttribute('missingDataTreatmentRule'));
    status = char(dataSeriesNode.getAttribute('status'));
    if ~isempty(status)
        status = str2num(status);
    end
    purpose = char(dataSeriesNode.getAttribute('purpose'));
    
    %if ~isempty(varargin)
        effectiveDate = varargin{1};
        to = varargin{2};
        from = varargin{3};
        frequency = varargin{4};
    %else
    %    effectiveDate = [];
    %end
    dataSeries = readDao.PopulateData(dataSeriesName, from, to, effectiveDate, status, purpose, frequency, dateOfMonth, holidayCalendar, missingDataTreatmentRule);
end

function validationAlgorithm = GetValidationAlgorithm(validationReport, xPathDoc, outputDir)
    
    %try
        validationAlgorithmName = char(validationReport.getAttribute('validationAlgorithm'));
        validationAlgorithm = eval(['BootstrapValidation.' validationAlgorithmName '();']); 
        %eval(['validationAlgorithm = prursg.BootstrapValidation.Algorithms.' validationAlgorithmName '();']);
        SetAlgorithmParams(xPathDoc, validationReport, validationAlgorithm, outputDir)
    %catch e
        %ex = MException('BootstrapValidationEngine:GetValidationAlgorithm',...
        %    ['The "from" attribute for Data Series  dataSeriesName  under Item  outputName  is missing or is not populated. The next item will be processed now (if present).']);
    %    throw(e);
    %end

end

function SetAlgorithmParams(xPathDoc, validationReport, validationAlgorithm, outputDir)
    import javax.xml.xpath.*;
    
    attributesList = xPathDoc.Evaluate('./@*', XPathConstants.NODESET, validationReport);
    if ~isempty(attributesList)
        for i = 1:attributesList.getLength()
            attribute = attributesList.item(i - 1);
            name = char(attribute.getName());
            value = char(attribute.getValue());
            eval(['validationAlgorithm.' name '= value;']);
        end        
    end
    
    PerformParameterValidation(validationAlgorithm);
    
    validationResultsPath = fullfile(outputDir, [datestr(now, 30) '_' validationAlgorithm.reportName filesep]);
    validationAlgorithm.validationResultsPath = validationResultsPath;
    
    if (~exist(validationResultsPath, 'dir'))
       mkdir(validationResultsPath);
    end

    try
    propertiesList = xPathDoc.Evaluate('./Params/Property', XPathConstants.NODESET, validationReport);
        if ~isempty(propertiesList)
            for i = 1:propertiesList.getLength()
                property = propertiesList.item(i - 1);
                name = char(property.getAttribute('name'));
                type = char(property.getAttribute('type'));
                value = char(property.getTextContent());

                if ~isempty(type) && strcmp(type, 'double') && ~isempty(value)
                    value = str2double(value);
                end

                eval(['validationAlgorithm.' name '= value;']);
            end
        end
    catch e
        ex = MException('BootstrapValidationEngine:SetAlgorithmParams:InvalidProperty', ...
            ['BootstrapValidationEngine:SetAlgorithmParams:InvalidProperty: ' ...
            'There are has been an error while trying to set a property of the bootstrap validation algorithm. %s'], e.message);
        throw(ex);
    end
end

function PerformParameterValidation(validationAlgorithm)

    % Compare the "from" and "to" dates. The "from" date must
    % not exceed the "to" date.
    % If it does throw and exception and move to process the
    % next validation report if present.
    if datenum(validationAlgorithm.fromDate) > datenum(validationAlgorithm.toDate)
        ex = MException('BootstrapValidationEngine:PerformParameterValidation:FromDateExceedingToDate',...
            ['BootstrapValidationEngine:PerformParameterValidation:FromDateExceedingToDate: ' ...
            'The value of the "from" attribute exceeds the value of the "to" attribute for validation report '...
                validationAlgorithm.reportName '. The next validation report will be processed now (if present).']);
        throw(ex);
    end
    
    % Compare the "to" and "effectiveDate" dates. The "to" date must
    % not exceed the "effectiveDate" date.
    % If it does throw and exception and move to process the
    % next validation report if present.
    if datenum(validationAlgorithm.toDate) > datenum(validationAlgorithm.effectiveDate)
        ex = MException('BootstrapValidationEngine:PerformParameterValidation:ToDateExceedingEffectiveDate',...
            ['BootstrapValidationEngine:PerformParameterValidation:ToDateExceedingEffectiveDate: ' ...
            'The value of the "to" attribute exceeds the value of the "effectiveDate" attribute for validation report '...
                validationAlgorithm.reportName '. The next validation report will be processed now (if present).']);
        throw(ex);
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[PersistValidationResults(validationResults, validationAlgorithm)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function is responsible for creating the intermediate XML file that
% will hold the validation results.
%
%   - Read the XML template for the intermediate XML file and create a
%   Document Object Model
%   - Populate the 'createdOn' attribute of the root element with the
%   current timestamp
%   - Populate all the attributes for the ValidationReportResults element
%   - For each validation result item call the createResultElement function
%   and append the result to the ValidationReportResults element
%   - Finally save the results to the file system
%
% *_Inputs_*
%
% |[validationResults]| - An object containing all validation results.
% 
% _Data Type_: object
%
% |[validationAlgorithm]| - An object containing information about the
% validation report and algorithm
% 
% _Data Type_: object
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PersistValidationResults(validationResults, validationAlgorithm)

    if (~isempty(validationResults))
        %Create the xml structure and save the results to the output directory
        dom = xmlread(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), '+prursg', '+BootstrapValidation', '+XmlTemplates', 'BootstrapValidationResults.xml'));
        root = dom.getFirstChild();

        root.setAttribute('createdOn', datestr(now, 30));

        valReport = dom.getElementsByTagName('ValidationReportResults').item(0);
        valReport.setAttribute('validationAlgorithm', validationAlgorithm.validationAlgorithm);
        valReport.setAttribute('reportTemplate', validationAlgorithm.reportTemplate);
        valReport.setAttribute('reportName', validationAlgorithm.reportName);
        valReport.setAttribute('description', validationAlgorithm.description);
        valReport.setAttribute('format', validationAlgorithm.format);
        valReport.setAttribute('effectiveDate', validationAlgorithm.effectiveDate);
        valReport.setAttribute('fromDate', validationAlgorithm.fromDate);
        valReport.setAttribute('toDate', validationAlgorithm.toDate);
        valReport.setAttribute('frequency', validationAlgorithm.frequency);
        valReport.setAttribute('multiDateReports', validationAlgorithm.multiDateReports);

        resultsKeys = keys(validationResults.resultsMap);
        customPropertiesKeys = keys(validationResults.customPropertiesMap);
        paramsElement = dom.createElement('Params');
        for i = 1:numel(customPropertiesKeys) 
              
            resultEl = createParamsElement(dom, validationResults.customPropertiesMap(customPropertiesKeys{i}), customPropertiesKeys{i});
            paramsElement.appendChild(resultEl); 

        end
        valReport.appendChild(paramsElement); 
        for i = 1:numel(resultsKeys)    

            resultEl = createResultElement(dom, validationResults.resultsMap(resultsKeys{i}), resultsKeys{i});
            valReport.appendChild(resultEl); 

        end    
            
        validationResultsContents = prursg.Xml.XmlTool.toString(dom, true);
        saveFile(fullfile(validationAlgorithm.validationResultsPath, [validationAlgorithm.reportName '.xml']), validationResultsContents);  
    else
        fprintf('No validation results have been generated for the ''%s'' report', validationAlgorithm.reportName);
    end

end


function outDataItem = createParamsElement(dom, resultElement, key)

    reKey = keys(resultElement);
    
    outDataItem = dom.createElement('Property');
    outDataItem.setAttribute('name', key);

    theValue = resultElement(reKey{1});
    outDataItem.setAttribute('type', reKey);


        switch char(reKey)
            case 'double'
                reText = putStringInXML(dom, num2str(theValue));
            otherwise
                reText = putStringInXML(dom, theValue);            
        end


    outDataItem.appendChild(reText);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[outDataItem = createResultElement(dom, resultElement, key)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function creates an OutputDataItem element for each validation
% result item:
%
%   - Create the OutputDataItem element and an attribute ('identifier')
%   - Depending on the type of the validation result item, populate each
%   OutputDataItem
%   - For all validation result items of type 'table', call the
%   createTableElement to create the internal structure for the table.
%
% *_Inputs_*
%
% |[dom]| - A Document Object Model representing the xml template to be 
% used for the validation results intermediate XML file.
% 
% _Data Type_: object
%
% |[resultElement]| - A map containing all validation results
% 
% _Data Type_: map
%
% |[key]| - The identifier of each OutputDataItem element
% 
% _Data Type_: string
% 
% *_Outputs_*
%
% |[outDataItem]| - The complete node with all the child elements populated
% for a particular validation result item
%
% _Data Type_: object
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outDataItem = createResultElement(dom, resultElement, key)

    reKey = keys(resultElement);
    
    outDataItem = dom.createElement('OutputDataItem');
    outDataItem.setAttribute('identifier', key);


    outDataItem.setAttribute('type', reKey);
    theValue = resultElement(reKey{1});


        switch char(reKey)
            case 'table'
                reText = createTableElement(dom, resultElement, key);
            case 'double'
                reText = putStringInXML(dom, num2str(theValue));
            otherwise
                reText = putStringInXML(dom, theValue);            
        end


    outDataItem.appendChild(reText);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[tableNode = createTableElement(dom, resultElement, key)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function creates the OutputDataItem element for all validation
% results that have been identified to be of type table:
%
%   - Create the Table element and an attribute ('name')
%   - Create a Row element for each row of the table and within that a
%   RowData element for each column.
%   - Each RowData element will hold the type of the value ('string' or
%   'double') and the actual value.
%   - Return the complete node to the calling function.
%
% *_Inputs_*
%
% |[dom]| - A Document Object Model representing the xml template to be 
% used for the validation results intermediate XML file.
% 
% _Data Type_: object
%
% |[resultElement]| - A map containing the element of the table
% 
% _Data Type_: map
%
% |[key]| - The name of the table which is identical to the identifier of
% the OutputDataItem element
% 
% _Data Type_: string
% 
% *_Outputs_*
%
% |[tableNode]| - The complete node with all the child elements populated
% for the table structure
%
% _Data Type_: object
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tableNode = createTableElement(dom, resultElement, key)

    tableNode = dom.createElement('Table');
    tableNode.setAttribute('name', key);

    tableId = keys(resultElement);
    tableStructure = resultElement(tableId{1});
    
    numRows = size(tableStructure, 1);
    numColumns = size(tableStructure, 2);
    
    for rowIdx = 1:numRows
        row = dom.createElement('Row');
        for rowIdy = 1:numColumns  
            theValue = tableStructure{rowIdx,rowIdy};
            if ischar(theValue)
                theType = 'string';
            else
                theType = 'double';
                theValue = num2str(theValue);
            end
            rowData = dom.createElement('RowData');
            rowData.setAttribute('type', theType);
            rowDataValue = putStringInXML(dom, theValue);
            rowData.appendChild(rowDataValue);
            row.appendChild(rowData);
        end
        tableNode.appendChild(row); 
    end
	  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% Details of Methods
% _________________________________________________________________________
%
%% |[saveFile(fileName, contents)]|
%
% '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
%
% *_Description_*
%
% This function save the validation results to an xml file.
%
% *_Inputs_*
%
% |[fileName]| - The full path including the name of the intermediate XML
% file that will hold the validation results
% 
% _Data Type_: string
%
% |[contents]| - The validation results in string format
% 
% _Data Type_: string
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveFile(fileName, contents)
    disp(fileName);
    fid = fopen(fileName, 'w');
    fwrite(fid, contents);
    fclose(fid);    
end

function [valid errorMessage] = schemaValidation(xmlFile)

    import java.io.*;
    import javax.xml.transform.Source;
    import javax.xml.transform.stream.StreamSource;
    import javax.xml.validation.*;
    
    valid = true;
    errorMessage = [];
    
    try
        factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
        schemaLocation = File(fullfile(prursg.Util.ConfigurationUtil.GetRootFolderPath(), 'Schemas', 'BootstrapValidation.xsd'));
        schema = factory.newSchema(schemaLocation);
        validator = schema.newValidator();
        source = StreamSource(xmlFile);
        validator.validate(source);
    catch e
        valid = false;
        errorMessage = e.message;
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%