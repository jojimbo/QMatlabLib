%% XML HISTORICAL DATA DAO  
%
% Deriving from the |[BasehistoricalDataDao]| which provides the RSG with
% read/write access to historical time series data. This class is used for
% accessing time series data from XML files.

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef XmlHistoricalDataDao < prursg.HistoricalDAO.BaseHistoricalDataDao

%% Properties
% *|[InputDir]|* - Input directory for the XML files that is specified in
% the app.config file.
%
% *|[OutputDir]|* - Output directory that is specified in the app.config
% file.
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    properties(Access = public)
        DataSource;
        InputDir;
        OutputDir
        InputFileName;
        OutputFileName;
    end
    
    properties(Access = private)
        dataSeriesCache;        
    end
    
%% Methods
% *1) |[populateData]|* - Loads a DataSeries object with the data from the
% XML file.
%
% *2) |[writeData]|* - Writes the data out to file.
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    
    methods
        function obj = XmlHistoricalDataDao()                        
            obj.DataSource = prursg.HistoricalDAO.XmlDataSource.Directory;      
            obj.InputDir = pwd();
            obj.OutputDir = pwd();    
            obj.dataSeriesCache = containers.Map('KeyType', 'char', 'ValueType', 'any'); 
        end
        
        function dataSeries = PopulateDataSeriesContent(obj, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)
            dataSeries = [];
            
            dataSeriesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');            
            
            if obj.DataSource == prursg.HistoricalDAO.XmlDataSource.Directory
                tic;
                
                disp(['Searching for data series ' dataSeriesName ' has started!']);
                
                if isKey(obj.dataSeriesCache, lower(dataSeriesName))
                    
                    xmlFilesString = obj.dataSeriesCache(lower(dataSeriesName)); 
                    
                else
                    
                    if (isunix)
                        searchStatement = ['cd "' obj.InputDir '" && grep -lir --include=*.xml "'  dataSeriesName '" .'];
                    else
                        searchStatement = ['cd "' obj.InputDir '" && findstr /s /i /p /m "' dataSeriesName '" *.* ' ];
                    end

                    xmlFilesString = evalc('system(searchStatement)');  
                    
                    obj.dataSeriesCache(lower(dataSeriesName)) = xmlFilesString;
                    
                end
                
                disp(['Searching for data series ' dataSeriesName ' has finished!']);
                
                toc; 
                
                filesExist = strfind(xmlFilesString, 'xml');
                if ~isempty(filesExist)
                    fileNames = regexp(xmlFilesString,'\n','split');    
                    fileNames = cellfun(@(x)fullfile(obj.InputDir, x), fileNames, 'UniformOutput', false);
                    disp(['Processing data series ' dataSeriesName 'from input file(s):']);
                    if ~isempty(fileNames)
                        for i = 1:length(fileNames)
                           xmlFile = fileNames{i};
                            [~, ~, ext] = fileparts(xmlFile);
                            if (exist(xmlFile, 'file') && strcmpi(strtrim(ext), '.xml'))
                                try
                                    disp(xmlFile);
                                    obj.ParseDataSeries(xmlFile, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose);
                                catch ex
                                    switch ex.identifier
                                        case 'XMLHistoricalDataDao:HandleDates:EffectiveDateAttributeMissingFromDataSeries'
                                            ex = MException(ex.identifier,...
                                                ['XMLHistoricalDataDao:HandleDates:EffectiveDateAttributeMissingFromDataSeries: The effective date attribute of the Data Series "' dataSeriesName '" within ' xmlFile ' is missing.']);                    
                                    end
                                    throw(ex)

                                end   
                            end
                        end                        
                    end
                else
                    
                    ex = MException('XmlHistoricalDataDao:PopulateDataSeriesContent:NoFilesFoundForDataSeries',...
                        ['Data for the Data Series "'  dataSeriesName '" could not be found. The next item will be processed now (if present).']);
                    throw(ex);
                    
                end
            else
                if isempty(obj.InputFileName) || ~exist(obj.InputFileName, 'file')
                    ex = MException('XmlHistoricalDataDao:PopulateDataSeriesContent', 'The input Xml file is either not specfied or does not exist. FileName-%s', obj.InputFileName);
                    throw(ex);
                end
                obj.ParseDataSeries(obj.InputFileName, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose);
            end
            
            % combine data.
            dataSeriesKeys = keys(dataSeriesMap);            
            if ~isempty(dataSeriesKeys) 
                dataSeries = prursg.Engine.DataSeries;
                dataSeries.Name = dataSeriesMap(dataSeriesKeys{1}).DataSeries.Name;
                dataSeries.axes = dataSeriesMap(dataSeriesKeys{1}).DataSeries.axes;

                combinedAxes = obj.CombineAxes(dataSeriesMap); 
                dataSeries.axes = combinedAxes;
                
                % set dynamic properties.
                dataSeries.SetDynamicProperties(dataSeriesMap(dataSeriesKeys{1}).Properties);                
                
                for i = 1:length(dataSeriesKeys)

                    dataSeries.dates{end + 1, 1} = dataSeriesKeys{i};
                    dataSeries.effectiveDates{end + 1, 1} = dataSeriesMap(dataSeriesKeys{i}).DataSeries.effectiveDates{1};
                    
                    values = obj.CreateMergedValues(dataSeriesMap(dataSeriesKeys{i}).DataSeries, combinedAxes, dataSeriesMap(dataSeriesKeys{i}).ValuesToAxes);
                    dataSeries.values{end + 1, 1} = values;                         
                end
            end
        end
        
        function calendar = PopulateHolidayCalendarContent(obj, calendarName)            
            calendar = [];                        
            fileNames = obj.GetXmlFileNames();            
            
            if ~isempty(fileNames)                
                for i = 1:length(fileNames)                   
                    calendar = obj.ParseCalendar(fileNames{i}, calendarName);                   
                    if ~isempty(calendar)                       
                        break; % exit the code as soon as it finds a matching calendar. We don't allow multiple versions of calendars.                   
                    end
                end
            end
            
        end
        
        function SerialiseData(obj, dataSeries)        
            
            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;
                        
                
            if ~isempty(dataSeries)               
                                                
               if isempty(obj.OutputFileName) 
                    obj.OutputFileName = [dataSeries.Name '.xml'];
               end
               
                outputFileName = obj.OutputFileName;
                if isempty(fileparts(outputFileName))
                    outputFileName = fullfile(obj.OutputDir, outputFileName);
                end
                                           
                fw = FileWriter(outputFileName);
                factory = XMLOutputFactory.newInstance();
                writer = factory.createXMLStreamWriter(fw);
                writer.writeStartDocument('ISO-8859-1', '1.0');                                
                writer.writeStartElement('DataSeriesSet');               
                writer.writeAttribute('name', '');
                writer.writeAttribute('date',  datestr(now, 'dd/mmm/yyyy'));                
                for i = 1:length(dataSeries)
                    obj.WriteDataSeries(writer, dataSeries(i));
                end
                writer.writeEndElement();
                writer.writeEndDocument();
                writer.flush();
                writer.close();
                fw.close();                              
            end            
        end
    end
    
    methods(Access=private)
        function fileNames = GetXmlFileNames(obj)
            fileNames = {};
            
            files = dir(obj.InputDir);
            if ~isempty(files)
                for i = 1:length(files)
                    if ~files(i).isdir && ~isempty(strfind(lower(files(i).name), '.xml'))
                        fileNames{end + 1} = fullfile(obj.InputDir, files(i).name);
                    end
                end
            end            
        end
        
                       
                        
        function holidayCalendar = ParseCalendar(obj, fileName, calendarName)
            holidayCalendar = [];
            
            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;
            
            inputFactory = XMLInputFactory.newInstance();
            fileReader = FileReader(fileName);
            xmlReader = inputFactory.createXMLStreamReader(fileReader);
            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if ~strcmp(elementName, 'StaticData')
                            break;
                        else
                            holidayCalendar = obj.HandleStaticData(xmlReader, calendarName);
                        end                
                end
            end                                  
            xmlReader.close();
            fileReader.close();
        end
        
        function holidayCalendar = HandleStaticData(obj, xmlReader, calendarName)
            holidayCalendar = [];
            
            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;
                        
            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if ~strcmp(elementName, 'Calendars')
                            break;
                        else
                            holidayCalendar = obj.HandleCalendars(xmlReader, calendarName);
                        end                
                end
            end     
        end
        
        function holidayCalendar = HandleCalendars(obj, xmlReader, calendarName)
            holidayCalendar = [];
            
            
            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;
            
            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'Calendar')                            
                            if strcmp(obj.GetAttributeValue(xmlReader, 'name'), calendarName)                                
                                holidayCalendar = obj.HandleCalendar(xmlReader, calendarName);    
                            end                                                        
                        end                
                end
            end     
        end
        
        function holidayCalendar = HandleCalendar(obj, xmlReader, calendarName)
            
            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;
            
            holidayCalendar = prursg.HistoricalDAO.HolidayCalendar();            
            holidayCalendar.Name = calendarName;
            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'Date')
                            desc = obj.GetAttributeValue(xmlReader, 'desc');                            
                            while(xmlReader.hasNext())
                                eventType = xmlReader.next();
                                switch(eventType)
                                    case XMLEvent.CHARACTERS  
                                        if ~xmlReader.isWhiteSpace()
                                            calendarDate = prursg.HistoricalDAO.HolidayCalendarValue();
                                            calendarDate.Desc = desc;
                                            calendarDate.Date = char(xmlReader.getText());
                                            holidayCalendar.Values(end + 1) = calendarDate;
                                        end
                                    break;
                                end
                            end
                            
                            
                        end
                end
            end                 
            
        end
                       
        function values = CreateMergedValues(obj, dataSeries, axes, valuesToAxes)

            % Depending on the number of axes, create a matrix filled up by NaN
            % values. This will be used to populate the values for each time series
            % date.
            noAxes = length(axes);            
            if noAxes == 0
                values = dataSeries.values;
            else
                
                if noAxes == 1
                    subCubeStr = sprintf('NaN(1,%d', length(axes(1).values));
                elseif noAxes >= 2
                    subCubeStr = sprintf('NaN(%d', length(axes(1).values));
                    for i = 2:noAxes
                        subStr = sprintf(',length(axes(%d).values)', i);
                        subCubeStr = [subCubeStr subStr];
                    end
                end
                subCubeStr = [subCubeStr ');'];
                subCube = eval(subCubeStr);
                
            
                % Loop through the axes and populate the respective positions in the
                % matrix
                if noAxes >= 2
                    switch noAxes
                        case 2
                            for i = 1:length(dataSeries.values)
                                [truefalse, index1] = ismember(valuesToAxes{i}{1}, axes(1).values);
                                [truefalse, index2] = ismember(valuesToAxes{i}{2}, axes(2).values);
                                subCube(index1,index2) = dataSeries.values(i);                                    
                            end                                                        
                        case 3
                            for i = 1:length(dataSeries.values)
                                [truefalse, index1] = ismember(valuesToAxes{i}{1}, axes(1).values);
                                [truefalse, index2] = ismember(valuesToAxes{i}{2}, axes(2).values);
                                [truefalse, index3] = ismember(valuesToAxes{i}{3}, axes(3).values);
                                subCube(index1,index2,index3) = dataSeries.values(i);
                            end                            
                    end
                else
                    for i = 1:length(dataSeries.values)
                        [truefalse, index] = ismember(dataSeries.axes.values{i}, axes(1).values);
                        subCube(1,index) = dataSeries.values(i);
                    end
                end

                values = subCube;
                
            end
                                    
        end
              

        function CheckAxis(obj, previousAxis, currentAxis)
            if ~isempty(previousAxis) && ~isempty(currentAxis)
                if (length(previousAxis) ~= length(currentAxis))
                    throw(MException('XmlHistoricalDataDao:CheckAxis', 'Axis size dose not match.')); 
                end
                for i = 1:length(previousAxis)
                    if ~strcmpi(previousAxis(i).title, currentAxis(i).title)
                        throw(MException('XmlHistoricalDataDao:CheckAxis', 'Axis hierachy dose not match.')); 
                    end
                end
            end
        end
        
        function axes = CombineAxes(obj, dataSeriesMap)

            axes = [];
            previousAxis = [];
            dsAxis = [];
            dataSeriesKeys = keys(dataSeriesMap); 

            axesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');  

            for i = 1:length(dataSeriesKeys)
                dsAxis = dataSeriesMap(dataSeriesKeys{i}).DataSeries.axes;
                
                obj.CheckAxis(previousAxis, dsAxis);
                previousAxis = dsAxis;

                for j = 1:length(dsAxis)                    
                    if isKey(axesMap, j)
                       axesMap(j) = [axesMap(j) dsAxis(j).values];
                    else
                        axesMap(j) = [dsAxis(j).values];
                    end
                end        
            end
            
            if ~isempty(dsAxis)
                axesMapKeys = keys(axesMap);            
                axes = prursg.Engine.Axis.empty(length(axesMapKeys), 0);            
                for i = 1:length(dsAxis)
                    tempAxis = axesMap(axesMapKeys{i});
                    [junk, index] = unique(tempAxis, 'first');
                    axes(i).values = tempAxis(sort(index));                
                    axes(i).title = dsAxis(i).title;            
                end
            end
        end
        
        function value = GetAttributeValue(obj, xmlReader, attributeName)            
            value = '';

            for i = 1:xmlReader.getAttributeCount()
                if strcmp(attributeName, char(xmlReader.getAttributeName(i - 1)))
                    value = char(xmlReader.getAttributeValue(i - 1));
                    break;
                end
            end
        end

        function key = GetValueMapKey(obj, dataSeriesDate)
            key = [dataSeriesDate.AsAtDate '_' dataSeriesDate.EffectiveDate];
        end

        function ParseDataSeries(obj, fileName, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;

            inputFactory = XMLInputFactory.newInstance();
            fileReader = FileReader(fileName);
            xmlReader = inputFactory.createXMLStreamReader(fileReader);

            % retrieve root element name.

            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'DataSeriesSet')
                            obj.HandleDataSeriesSet(xmlReader, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose);
                        end
                        break;                        
                end
            end                        
            xmlReader.close();            
            fileReader.close();            
            fileReader = [];            
            inputFactory = [];        
        end
        
        function HandleDataSeriesSet(obj, xmlReader, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;

            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'DataSeries')                                                                                                
                            obj.HandleDataSeries(xmlReader, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose);
                        end       
                    case XMLEvent.END_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'DataSeriesSet')                                                                                                
                            break;
                        end
                end
            end
        end

        function HandleDataSeries(obj, xmlReader, dataSeriesMap, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)            

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;            
            
            if ~strcmpi(obj.GetAttributeValue(xmlReader, 'name'), dataSeriesName)                  
                return;
            end

            if ~isempty(status) && status > 0 && ~strcmpi(obj.GetAttributeValue(xmlReader, 'status'), num2str(status))   
                return;            
            end

            if ~isempty(purpose) && ~strcmpi(obj.GetAttributeValue(xmlReader, 'purpose'), purpose)   
                return;
            end
            properties = prursg.Engine.DynamicProperty.empty();    
            dates = [];
            indexes = [];
            valueMap = containers.Map('KeyType', 'char', 'ValueType', 'any');      

            axesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

            axesIndexMap = containers.Map('KeyType', 'int32', 'ValueType', 'char');

            valuesToAxesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');      
            
                while(xmlReader.hasNext())
                    eventType = xmlReader.next();
                    switch(eventType)
                        case XMLEvent.START_ELEMENT
                            elementName = char(xmlReader.getName());
                            switch(elementName)      
                                case 'DynamicProperties'
                                    properties = obj.HandleDynamicProperties(xmlReader);
                                case 'Dates'
                                    [dates indexes] = obj.HandleDates(xmlReader, fromDate, toDate, effectiveDate);
                                case 'Axis'
                                    obj.HandleAxes(xmlReader, axesMap, dates, indexes, 0, valueMap, axesIndexMap, valuesToAxesMap, []);
                                case 'Values'
                                    obj.HandleValues(xmlReader, dates, indexes, valueMap, valuesToAxesMap, []);
                            end
                        case XMLEvent.END_ELEMENT                
                            elementName = char(xmlReader.getName());
                            if strcmp(elementName, 'DataSeries')
                                break;                            
                            end
                    end
                end            

                %axesKeys = keys(axesMap);                
                axes = prursg.Engine.Axis.empty(length(axesIndexMap), 0);
                for i = 1:length(axesIndexMap)                                        
                    %axes(i) = axesMap(axesKeys{i});                    
                    axes(i) = axesMap(axesIndexMap(i));                
                end
                
                for i = 1:length(dates)                    
                    if indexes(i)                        
                        ds = [];                        
                        if isKey(dataSeriesMap, dates(i).AsAtDate)                           
                            ds = dataSeriesMap(dates(i).AsAtDate);                        
                        end
                        
                        if (~isempty(ds) && strcmp(ds.DataSeries.dates{1}, dates(i).AsAtDate)...                              
                                && strcmp(ds.DataSeries.effectiveDates{1}, dates(i).EffectiveDate))                              
                            ex = MException('XMLHistoricalDataDao:HandleDataSeries:DuplicateDataSeriesFound',...                            
                                'XMLHistoricalDataDao:HandleDataSeries: A duplicate data series has been found. The next item will be processed now (if present).');                            
                            throw(ex);                        
                        end
                        
                        if isempty(ds) || datenum(dates(i).EffectiveDate) >= datenum(ds.DataSeries.effectiveDates{1})                            
                            dsMapItem = prursg.HistoricalDAO.DataSeriesMapItem();                                             
                            dsMapItem.DataSeries = prursg.Engine.DataSeries();                            
                            dsMapItem.DataSeries.Name = dataSeriesName;                            
                            dsMapItem.DataSeries.dates = {dates(i).AsAtDate};                            
                            dsMapItem.DataSeries.effectiveDates = {dates(i).EffectiveDate};                            
                            dsMapItem.DataSeries.axes = axes;                            
                            dsMapItem.DataSeries.values = valueMap(obj.GetValueMapKey(dates(i)));                            
                            dsMapItem.Properties = properties;  
                            dsMapItem.ValuesToAxes = valuesToAxesMap(obj.GetValueMapKey(dates(i)));
                            dataSeriesMap(dates(i).AsAtDate) = dsMapItem;                        
                        end
                    end
                end
        end
        
        function [dates indexes] = HandleDates(obj, xmlReader, fromDate, toDate, effectiveDate)            
            dates = prursg.Engine.DataSeriesDate.empty();
            indexes = [];
            import java.io.*;            
            import javax.xml.stream.*;            
            import javax.xml.stream.events.*;

            i = 0;

            if isempty(effectiveDate)
                effectiveDate = '01/Jan/1900';
            end

            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'Date')        
                            i = i + 1;                             
                            indexes(i) = 0; % set to 0 by default.
                            dates(i) = prursg.Engine.DataSeriesDate();
                            eDate = obj.GetAttributeValue(xmlReader, 'effectiveDate');
                            if isempty(eDate)
                                %eDate = '01/Jan/1900';
                                ex = MException('XMLHistoricalDataDao:HandleDates:EffectiveDateAttributeMissingFromDataSeries',...
                                'XMLHistoricalDataDao:HandleDates:EffectiveDateAttributeMissingFromDataSeries');
                                throw(ex);
                            end                            

                            while(xmlReader.hasNext())
                                eventType = xmlReader.next();
                                switch(eventType)
                                    case XMLEvent.CHARACTERS
                                        if ~xmlReader.isWhiteSpace()
                                            asAtDate = char(xmlReader.getText());

                                            if (isempty(fromDate) || datenum(asAtDate) >= datenum(fromDate))...
                                                    && (isempty(toDate) || datenum(asAtDate) <= datenum(toDate))...
                                                    && (isempty(effectiveDate) || datenum(eDate) <= datenum(effectiveDate))...
                                                    && obj.isClosestEffectiveDate(asAtDate, eDate, effectiveDate, dates, indexes)
                                                dates(i).AsAtDate = asAtDate;                                                
                                                dates(i).EffectiveDate = eDate;
                                                indexes(i) = 1;
                                            end
                                        end
                                    case XMLEvent.END_ELEMENT 
                                        elementName = char(xmlReader.getName());
                                        if strcmp(elementName, 'Date')
                                            break;                        
                                        end
                                end
                            end
                        end
                    case XMLEvent.END_ELEMENT                        
                        elementName = char(xmlReader.getName());                        
                        if strcmp(elementName, 'Dates')                            
                            break;                                                
                        end
                end
            end
        end

        function flag = isClosestEffectiveDate(obj, asAtDate, eDate, effectiveDate, dates, indexes)

            flag = 1;

            for i = 1:length(dates)
                if strcmp(dates(i).AsAtDate, asAtDate) 
                    if strcmp(dates(i).EffectiveDate, eDate) 
                        ex = MException('XMLHistoricalDataDao:isClosestEffectiveDate',...
                            'A duplicate data series has been found. The next item will be processed now (if present).');
                        throw(ex);
                    elseif (strcmp(effectiveDate, eDate) || datenum(dates(i).EffectiveDate) < datenum(eDate))
                            indexes(i) = 0;
                            dates(i).EffectiveDate = [];
                            dates(i).AsAtDate = [];
                            break;
                    else
                        flag = 0;
                    end
                end
            end
        end

        function HandleValues(obj, xmlReader, dates, includeIndexes, valueMap, valuesToAxesMap, theAxes)                        

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;

            i = 0;            
            while(xmlReader.hasNext())
                eventType = xmlReader.next();                
                switch(eventType)                    
                    case XMLEvent.START_ELEMENT                        
                        elementName = char(xmlReader.getName());                        
                        if strcmp(elementName, 'V')                                    
                            i = i + 1;                                            
                            if includeIndexes(i)                                
                                while(xmlReader.hasNext())                                    
                                    eventType = xmlReader.next();                                    
                                    switch(eventType)                                        
                                        case XMLEvent.CHARACTERS
                                            if ~xmlReader.isWhiteSpace()
                                                values = [];
                                                if isKey(valueMap, obj.GetValueMapKey(dates(i)))
                                                    values = valueMap(obj.GetValueMapKey(dates(i)));
                                                end                                                
                                                value = char(xmlReader.getText());
                                                values = [values str2num(value)];
                                                
                                                axesValues = [];
                                                if isKey(valuesToAxesMap, obj.GetValueMapKey(dates(i)))
                                                    axesValues = valuesToAxesMap(obj.GetValueMapKey(dates(i)));
                                                end           
                                                
                                                axesValues{end + 1} = theAxes;                                                
    
                                                valueMap(obj.GetValueMapKey(dates(i))) = values;
                                                valuesToAxesMap(obj.GetValueMapKey(dates(i))) = axesValues;
                                            end
                                        case XMLEvent.END_ELEMENT 
                                            elementName = char(xmlReader.getName());
                                            if strcmp(elementName, 'V')
                                                break;                        
                                            end
                                    end
                                end            
                            end
                        end
                    case XMLEvent.END_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'Values')
                            break;                        
                        end                        
                end
            end
        end

        function properties = HandleDynamicProperties(obj, xmlReader)

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;

            properties = prursg.Engine.DynamicProperty.empty();

            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'Property')
                            property = prursg.Engine.DynamicProperty();                            
                            property.Name = obj.GetAttributeValue(xmlReader, 'name');                            
                            type = obj.GetAttributeValue(xmlReader, 'type');                            
                            if isempty(type)
                                property.Type = 'string';
                            else
                                property.Type = type;
                            end                         

                            while(xmlReader.hasNext())                                
                                eventType = xmlReader.next();                                
                                switch(eventType)                                    
                                    case XMLEvent.CHARACTERS                                          
                                        if ~xmlReader.isWhiteSpace()
                                            value = char(xmlReader.getText());
                                            if strcmp(property.Type, 'number') && ~isempty(value)
                                                property.Value = str2num(value);
                                            else
                                                property.Value = value;
                                            end                                            
                                        end
                                    case XMLEvent.END_ELEMENT
                                        elementName = char(xmlReader.getName());
                                        if strcmp(elementName, 'Property')
                                            break;
                                        end
                                end
                            end

                            properties(end +1) = property;
                        end
                    case XMLEvent.END_ELEMENT
                        elementName = char(xmlReader.getName());
                        if strcmp(elementName, 'DynamicProperties')
                            break;
                        end
                end
            end        
        end                


        function HandleAxes(obj, xmlReader, axesMap, dates, indexes, parentIndex, valueMap, axesIndexMap, valuesToAxesMap, theAxes)

            import java.io.*;
            import javax.xml.stream.*;
            import javax.xml.stream.events.*;

            axis = [];

            name = obj.GetAttributeValue(xmlReader, 'name');
            value = obj.GetAttributeValue(xmlReader, 'value');

            if isKey(axesMap, name)
                axis = axesMap(name);
            else
                axis = prursg.Engine.Axis();
                axesMap(name) = axis;
                axis.title = name;
                axis.Index = parentIndex + 1;
                axesIndexMap(axis.Index) = name;
            end
            
            theAxes{end + 1} = [value];        
            axis.addValue(value);

            while(xmlReader.hasNext())
                eventType = xmlReader.next();
                switch(eventType)
                    case XMLEvent.START_ELEMENT
                        elementName = char(xmlReader.getName());
                        switch(elementName)
                            case 'Axis'
                                obj.HandleAxes(xmlReader, axesMap, dates, indexes, axis.Index, valueMap, axesIndexMap, valuesToAxesMap, theAxes);
                            case 'Values'                                
                                obj.HandleValues(xmlReader, dates, indexes, valueMap, valuesToAxesMap, theAxes);                        
                        end
                    case XMLEvent.END_ELEMENT                        
                        elementName = char(xmlReader.getName());                        
                        if strcmp(elementName, 'Axis')                            
                            break;                                                
                        end
                end
            end
        end


        function WriteDataSeries(obj, writer, dataSeries)
            writer.writeStartElement('DataSeries');
            writer.writeAttribute('name', dataSeries.Name);

            if ~isempty(dataSeries.Status)
                writer.writeAttribute('status', num2str(int32(dataSeries.Status)));
            end
            
            if ~isempty(dataSeries.Purpose)                
                writer.writeAttribute('purpose', dataSeries.Purpose);            
            end
            % write dynamic properties.
            dynamicProperties = dataSeries.GetDynamicProperties();
            if ~isempty(dynamicProperties)
                writer.writeStartElement('DynamicProperties');
                for i = 1:length(dynamicProperties)
                    writer.writeStartElement('Property');
                    writer.writeAttribute('name', dynamicProperties(i).Name);
                    type = dynamicProperties(i).Type;
                    if isempty(type)
                        type = 'string';
                    end
                    writer.writeAttribute('type', type);
                    if strcmp(type, 'number')
                        writer.writeCharacters(prursg.Util.FormatNumber(dynamicProperties(i).Value ,obj.NumberFormatSpecifier));
                    else
                        writer.writeCharacters(dynamicProperties(i).Value);
                    end
                    writer.writeEndElement();
                end
                writer.writeEndElement();
            end
                        

            % write dates.
            writer.writeStartElement('Dates')            
            % effective dates are now mandatory, Therefore, the length of
            % effective dates must match with the length of dates.
            if ~isempty(dataSeries.dates)
                if length(dataSeries.dates) ~= length(dataSeries.effectiveDates)
                    throw(MException('XmlHistoricalDataDao:WriteDataSeries', 'Lengths of dates and effective dates do not match.'));
                end
            end            

            for i = 1: length(dataSeries.dates)
                writer.writeStartElement('Date');
                writer.writeAttribute('effectiveDate', dataSeries.effectiveDates{i});                
                writer.writeCharacters(dataSeries.dates{i});
                writer.writeEndElement();
            end
            writer.writeEndElement();

            if ~isempty(dataSeries.axes)
                % write axes.                
                % WriteAxis(writer, dataSeries.dates, dataSeries.axes, dataSeries.values, 1, []);
                obj.WriteAxis(writer, dataSeries.dates, dataSeries.axes, dataSeries.values);
            else
                % write values.
                if ~isempty(dataSeries.values)
                    writer.writeStartElement('Values');
                    for i = 1:length(dataSeries.values)
                        writer.writeStartElement('V');                        
                        writer.writeCharacters(prursg.Util.FormatNumber(dataSeries.values{i} ,obj.NumberFormatSpecifier));                        
                        writer.writeEndElement();                    
                    end
                    writer.writeEndElement();                
                end
            end

            writer.writeEndElement();
        end

        function WriteAxis(obj, writer, dates, axes, values)

            noOfAxes = length(axes);

            switch noOfAxes
                case 1                    
                    obj.WriteSingleAxis(writer, axes(1), dates, values, 1);                
                case 2                    
                    for i = 1:length(axes(1).values)                         
                        obj.WriteAxisOpeningElement(writer, axes(1).title, axes(1).values{i})                        
                        obj.WriteSingleAxis(writer, axes(2), dates, values, i);

                        writer.writeEndElement(); 
                    end
                case 3                    
                    for i = 1:length(axes(1).values)                         
                        obj.WriteAxisOpeningElement(writer, axes(1).title, axes(1).values{i})
                        for j = 1:length(axes(2).values)                         
                            obj.WriteAxisOpeningElement(writer, axes(2).title, axes(2).values{j}) 
                            obj.WriteSingleAxis(writer, axes(3), dates, values, [i j]);
                            writer.writeEndElement(); 
                        end
                        
                        writer.writeEndElement();
                    end
            end
        end

        function WriteSingleAxis(obj, writer, axes, dates, values, parentIndex)
            
            noOfAxes = length(axes);
            noOfParentIndexValues = length(parentIndex);

            for j = 1:length(axes(1).values) 
                obj.WriteAxisOpeningElement(writer, axes(1).title, axes(1).values{j})

                writer.writeStartElement('Values');            
                for h = 1: length(dates)
                    writer.writeStartElement('V');
                    data = values{h};
                    switch noOfParentIndexValues
                        case 1
                            writer.writeCharacters(prursg.Util.FormatNumber(data(parentIndex,j),obj.NumberFormatSpecifier)); 
                        case 2
                            writer.writeCharacters(prursg.Util.FormatNumber(data(parentIndex(1), parentIndex(2), j),obj.NumberFormatSpecifier));
                    end
                    writer.writeEndElement();                                        
                end

                writer.writeEndElement(); 
                writer.writeEndElement(); 
            end

        end

        function WriteAxisOpeningElement(obj, writer, name, value)

            writer.writeStartElement('Axis');
            if isempty(name)
                name = '';
            end
            writer.writeAttribute('name', name);
            
            writer.writeAttribute('value', prursg.Util.FormatNumber(value,obj.NumberFormatSpecifier));            
            
        end
        
        

    end
end
