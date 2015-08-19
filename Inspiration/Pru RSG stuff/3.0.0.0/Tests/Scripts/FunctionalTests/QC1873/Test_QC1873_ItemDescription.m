%% Test_QC1873_01_default 
%
% SUMMARY: These tests take the value of the name and description from the
% Item tag on the control file and compares them against the name on the
% data series output and the description on the dynamic propery tag. If
% they are both the same as those on the Item tag then the test is
% successful.
%
%%

function test_suite = Test_QC1873_ItemDescription()
    disp('Initialising Test_QC1873_ItemDescription')
    
    initTestSuite;        
end

function Test_OneItem()
    % Test that the Item description in the control file
    % feeds through to the bootstrapped data series

    disp('Starting: Test_OneItem...')
   	
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    inputDir = strcat(pathstr, filesep,'BootstrapInput', filesep);
 
    control = RunBootstrap('bootstrapOneItem.xml');
    numItemDescriptions = 1;
    CompareNameAndDescrption(control, 'A', numItemDescriptions);
end

function Test_OneItemNoItemDescription()
    % Test that a missing Item description in the control file
    % feeds through as an empty but present description in the bootstrapped 
    % data series

    disp('Starting: OneItemNoItemDescription...')

    control = RunBootstrap('bootstrapOneItemNoItemDescription.xml');
    numItemDescriptions = 0;
    CompareNameAndDescrption(control, 'B', numItemDescriptions);
end

function Test_OneItemEmptyItemDescription()
    % Test hat an empty (but present) Item description in the control file
    % feeds through to the bootstrapped data series

    disp('Starting: Test_OneItemEmptyItemDescription...')

    control = RunBootstrap('bootstrapOneItemEmptyItemDescription.xml');
    numItemDescriptions = 1;
    CompareNameAndDescrption(control, 'C', numItemDescriptions);
end

function Test_TwoItems()
    % Test that multiple items behave as expected i.e no differently
    % to a single item

    disp('Starting: Test_TwoItems...')
    
    control = RunBootstrap('bootstrapTwoItems.xml');
    numItemDescriptions = 1;
    CompareNameAndDescrption(control, 'D', numItemDescriptions);
    CompareNameAndDescrption(control, 'E', numItemDescriptions);
end

% Helpers
% The caller should convert the returned value as required
 function value = UsingMDS()           
   import prursg.Configuration.*;                            
   cm = prursg.Configuration.ConfigurationManager();
   value = false;
   
   daoName = strfind(cm.DefaultDaoName, 'DB');

   if (~isempty(daoName))
       value = true;
   end
 end
 
 % The caller should convert the returned value as required
 function value = GetValue(key)           
   import prursg.Configuration.*;                            
   cm = prursg.Configuration.ConfigurationManager();
   value = '';

   if isKey(cm.AppSettings, key)
       value = cm.AppSettings(key);
   end
 end
 
function bootstrapControlFilePath = RunBootstrap(controlFile)
    disp('Starting the boostrap process...')
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));

    % Set file paths
    bootstrapControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    bootstrapEngine = prursg.Bootstrap.BootstrapEngine();
    disp('Starting the bootstrap process');
    tic
    bootstrapEngine.Bootstrap(bootstrapControlFilePath);
    toc
    disp('Bootstrap complete');
    
    if (UsingMDS())
        bootstrapOutputFilePath = strcat(pathstr, filesep,'BootstrapOutput');
        fromMDStoFS(bootstrapControlFilePath, bootstrapOutputFilePath)
    end
end

function fromMDStoFS(controlFilePath, outputDir)
    controlItemNames = getAttributeValues(controlFilePath, 'Item', 'name');
    for i = 1:length(controlItemNames)
        dso = mdsToDataSeries(controlItemNames(i), '02/Jan/2000', '02/Jan/2030', '02/Jan/2040');
        dataSeriesToXML(dso, outputDir)
    end
end

function dataSeries = mdsToDataSeries(dataSeriesName, fromDate, toDate, eDate)
	dbDao = prursg.HistoricalDAO.DbHistoricalDataDao();
    
    % PopulateData(dataSeriesName, fromDate, toDate, effectiveDate, 
    %              status, purpose, frequency, dateOfMonth, holidayCalendarName,
    %              missingDataTreatmentRuleName)
    dataSeries = dbDao.PopulateData(dataSeriesName, fromDate, toDate, eDate,...
                                    [],[], [], [], [], []);
end

function dataSeriesToXML(dso, outputDir)
	xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
	xmlDao.InputDir = '';
	xmlDao.OutputDir = outputDir;
	xmlDao.WriteData(dso);
end

function CompareNameAndDescrption(bootstrapControlFilePath, itemName, ...
    numItemDescriptions) % num descriptions per item i.e. 1 or 0
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));

    % Set file paths
    bootstrapOutputFilePath = strcat(pathstr, filesep,'BootstrapOutput', filesep, [itemName '.xml']);
    
    disp(['Inspecting the ''description'' in the bootstrapped output for name: "' itemName '"'])   
    assertTrue(numItemDescriptions == 1 || numItemDescriptions == 0);
    
    compareItemandDataSeriesNames(bootstrapControlFilePath, bootstrapOutputFilePath,...
        itemName, numItemDescriptions);
    compareItemandDataSeriesDescriptions(bootstrapControlFilePath, bootstrapOutputFilePath,...
        itemName, numItemDescriptions);
end

function compareItemandDataSeriesNames(controlFilePath, bootstrappedFilePath,...
    nameFilter, numItemDescriptions) % num descriptions per item i.e. 1 or 0
    disp('Inspecting the bootstrapped output for ''name''');
    
    % Every Item must have a name. Here we're really confirming that the
    % control file has an Item with the name we're expecting in the output
    controlItemNames = getAttributeValuesWhereName(controlFilePath, 'Item', 'name', nameFilter);
    assertEqual(1, length(controlItemNames));
    
    % Every DataSeries must have a name and there are as many output
    % DataSeries as Items but we're only looking at one at a time
    bootstrappedName = getAttributeValues(bootstrappedFilePath, 'DataSeries', 'name');
    assertEqual(1, length(bootstrappedName));
    
    % Use setdif to check for differences between the cell arrays
    assertEqual(bootstrappedName(1), controlItemNames(1),...
            ['Item.name (input): "' char(controlItemNames(1)) '" and DataSeries.name (output): "' ... 
            char(bootstrappedName(1)) '" differ']);
end

function compareItemandDataSeriesDescriptions(controlFilePath, bootstrappedFilePath,...
    itemFilter, numItemDescriptions) % num descriptions per item i.e. 1 or 0
    disp('Inspecting the bootstrapped output for ''description''');
    
    controlDescription = getAttributeValuesWhereName(controlFilePath, 'Item', 'description', itemFilter);   
    % Item description is optional. Here we're confirming that the control
    % file has the description we're expecting
    assertEqual(numItemDescriptions, length(controlDescription));
    
    bootstrappedDescription = getElementTextValuesWhereHasAttribute(bootstrappedFilePath, ...
	'Property', 'name', 'description');   
    % Expect a description even if missing or empty in the input
    assertEqual(1, length(bootstrappedDescription));
    
    if (numItemDescriptions == 1)
          assertEqual(bootstrappedDescription(1), controlDescription(1),...
            ['Item.name (input): "' char(controlDescription(1)) '" and DataSeries.name (output): "' ... 
            char(bootstrappedDescription(1)) '" differ']);
    else
        % all we need check here is that there is one description in the 
        % datseries and this test was performed in the assertion above.
        % If the desc is missing from the Item then it should be empty in
        % the data series
        assertTrue(strcmp('', bootstrappedDescription(1)));
    end
end 

function values = getAttributeValuesWhereName(filePath, elem, attr,... 
    nameFilter) % use nameFiler where control file has more than one item
   
    xDoc = xmlread(filePath);
    elements = xDoc.getElementsByTagName(elem);
    values = {};
    for i = 0:elements.getLength() - 1
        attribute = elements.item(i).getAttributes().getNamedItem('name');
        % filter out values where not for specified name
        if (~isempty(attribute) && strcmp(char(attribute.getNodeValue), nameFilter))
            attribute = elements.item(i).getAttributes().getNamedItem(attr);
            if (~isempty(attribute))
                values{end+1} = char(attribute.getNodeValue);
            end
        end
    end
end

function values = getAttributeValues(filePath, elem, attr)
    xDoc = xmlread(filePath);
    elements = xDoc.getElementsByTagName(elem);
    values = {};
    for i = 0:elements.getLength() - 1
        attribute = elements.item(i).getAttributes().getNamedItem(attr);
        if (~isempty(attribute))
            values{end+1} = char(attribute.getNodeValue);
        end
%        for j = 0:elements.item(i).getAttributes().getLength() - 1
%            char(elements.item(i).getAttributes.item(j))
%             if (strcmp(char(elements.item(i).getAttributes.item(j)), attr))
%                vals = [vals elements.item(i).getAttributes().item(j)]
%            end
%        end
    end
end

function values = getElementTextValuesWhereHasAttribute(filePath, elem, attr, value)
% This is required because dyn props all have name attribues, its the
% name's value that defines the property
    xDoc = xmlread(filePath);
    elements = xDoc.getElementsByTagName(elem);
    values = {};
    for i = 0:elements.getLength() - 1
        % Get the name attribute
        attribute = elements.item(i).getAttributes().getNamedItem(attr);
        if (~isempty(attribute))
            % Check the value to see if it's the dyn prop we want
            if (strcmp(attribute.getNodeValue, value))
                values{end+1} = char(elements.item(i).getTextContent);
            end
        end
    end
end
