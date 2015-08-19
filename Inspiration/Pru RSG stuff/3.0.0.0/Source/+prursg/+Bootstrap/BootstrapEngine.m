%% BOOTSTRAP ENGINE  
%
% This class is responsible for all bootstrapping tasks.

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef BootstrapEngine < handle
    % Engine that handles bootstrapping tasks

    properties(Access=private)        
        readDao
        writeDao        
    end
    
    properties
        NumberFormatSpecifier
    end
    
%% Methods
% *1) |[Bootstrap]|* - Invokes the boostrap from the configuration set in
% the XML control file that is specified in the |[inputXmlPath]| parameter.

%
%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 
    methods
        
        function obj = BootstrapEngine()
            addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
            import Bootstrap.*;
            factory = prursg.HistoricalDAO.HistoricalDataDaoFactory();
            obj.readDao = factory.Create();                        
            obj.writeDao = obj.readDao();
            allowWriteMarketData = prursg.Util.ConfigurationUtil.AllowWriteMarketData;
            if ~allowWriteMarketData               
               obj.writeDao = factory.Create('XML');
            end
            
            % specify number format specifiers.
            obj.NumberFormatSpecifier = prursg.Util.ConfigurationUtil.GetHistoricalDataDaoNumberFormat();
            obj.readDao.NumberFormatSpecifier =  obj.NumberFormatSpecifier;
            obj.writeDao.NumberFormatSpecifier =  obj.NumberFormatSpecifier;
            
        end
        
        % Run bootstrap algorithms.
        function Bootstrap(obj, inputXmlPath)
            import javax.xml.xpath.*;
                        
            dataSeriesCache = containers.Map('KeyType', 'char', 'ValueType', 'any');            
            xpathDoc = prursg.Xml.XPathDoc(inputXmlPath);
            nodeList = xpathDoc.Evaluate('//Item[@bootstrap="true" or not(@bootstrap)]', XPathConstants.NODESET);
                                    
            if ~isempty(nodeList)
                for i = 1:nodeList.getLength()
                    item = nodeList.item(i - 1);    
                    
                    try
                        obj.ProcessBootstrapItem(item, xpathDoc, dataSeriesCache);
                        fprintf('BootstrapEngine:Item %s is bootstrapped.\n', char(item.getAttribute('name')));
                    catch e
                       
                        fprintf('BootstrapEngine: Item no  %d, "%s" within control file %s failed to bootstrap. The error message is: %s, %s\n',...
                            i, char(item.getAttribute('name')), inputXmlPath, e.identifier, e.message);
                    end
                end
            end                     
        end
        
        % Run calibrations.
        function outputXmlPath = Calibrate(obj, inputXmlPath)
            
            import javax.xml.xpath.*;
            
            fprintf('Main - applying calibration algorithms \n');
            dataSeriesCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
            algorithmCache = containers.Map('KeyType', 'char', 'ValueType', 'any');            
            
            xpathDoc = prursg.Xml.XPathDoc(inputXmlPath);
            nodeList = xpathDoc.Evaluate('//Item[@calibrate="true" or not(@calibrate)]', XPathConstants.NODESET);
                                    
            if ~isempty(nodeList)
                for i = 1:nodeList.getLength()
                    item = nodeList.item(i - 1);                                
                    try
                        obj.ProcessCalibrationItem(item, xpathDoc, dataSeriesCache, algorithmCache);

                        fprintf('BootstrapEngine:Item %s is calibrated.\n', char(item.getAttribute('name')));
                    catch e
                        fprintf('BootstrapEngine:Item %s failed to calibrate,error is %s\n',...
                        char(item.getAttribute('name')), e.message);
                    end
                end
            end        

            % update calbiation results.
            outputXmlPath = obj.UpdateCalibrationResults(inputXmlPath, algorithmCache);            
            fprintf('Main - calibration done \n');
            
        end        
        
        % Update NumberFormatSpecfier property.
        function obj = set.NumberFormatSpecifier(obj, value)
            obj.NumberFormatSpecifier = value;
            
            if ~isempty(obj.readDao)
                obj.readDao.NumberFormatSpecifier = value;
            end
            
            if ~isempty(obj.writeDao)
                obj.writeDao.NumberFormatSpecifier = value;
            end
            
        end
            
    end
    
    methods(Access=private)
        
        %% private functions required by calibration.

        % Run a caliration for a given item.
        function  ProcessCalibrationItem(obj, item, xPathDoc, ~, algorithmCache, ~, ~)

            import javax.xml.xpath.*;
            outputName = char(item.getAttribute('name'));
            algorithmName = obj.GetAlgorithmName(xPathDoc, item);            
            
            if isempty(algorithmName)                
                ex = MException('BootstrapEngine:ProcessCalibrationItem', 'The bootstrap calibration algorithm name is not set');                
                throw(ex);            
            end
            
            if ~isKey(algorithmCache, outputName)                                                                        
                % instantiate a bootstrapping engine                
                eval(['algorithm = Bootstrap.' algorithmName '();']);                            
                
                % calibrate                
                obj.SetAlgorithmParams(xPathDoc, item, algorithm);                
                algorithm.Calibrate();                  
                algorithmCache(outputName) = algorithm;                    
            end
        end
        
        % Retreive input data series requied for the calibration.
        function dataSeries = GetCalibrationInputDataSeries(obj, item, xPathDoc, algorithmCache, dataSeriesCache, isBootstrapRequired, algorithmName)

            import javax.xml.xpath.*;

            nodeList = xPathDoc.Evaluate('./InputData/DataSeries', XPathConstants.NODESET, item);
            if ~isempty(nodeList)                
                nodeListLength = nodeList.getLength();                
                inDataSeries = prursg.Engine.DataSeries.empty(nodeListLength, 0);                
                
                for i = 1:nodeListLength                    
                    dataSeriesName = char(nodeList.item(i - 1).getAttribute('name'));                    
                    % firstly check the cache.                         
                    ds = [];                    
                    if isKey(dataSeriesCache, dataSeriesName)                        
                        ds = dataSeriesCache(dataSeriesName);                    
                    else
                        % check whether the data series is a derived one.                        
                        node = xPathDoc.Evaluate(['//Item[@name="' dataSeriesName '"]'], XPathConstants.NODE);                        
                        
                        if ~isempty(node)                            
                            ds = obj.GetCalibrationInputDataSeries(node, xPathDoc, algorithmCache, dataSeriesCache, 1, algorithmName);                        
                        else
                            %retrieve data through a dao.                            
                            ds = obj.RetrieveDataSeries(nodeList.item(i - 1));                                                    
                        end
                        
                        dataSeriesCache(dataSeriesName) = ds;                    
                    end
                    
                    if ~isempty(ds)                        
                        inDataSeries(i) = ds;
                    end                
                end
            end

            if isBootstrapRequired                                    
                % run calibration and bootstrap algorithm for a precedent item.                
                eval(['algorithm = Bootstrap.' algorithmName '();']);                        
                cacheKey = char(item.getAttribute('name'));                                    
                
                algorithm.Calibrate(inDataSeries);                
                algorithmCache(cacheKey) = algorithm;                
                dataSeries = algorithm.Bootstrap(inDataSeries);                             
                
                if ~isempty(dataSeries)                            
                    
                    dataSeries.Name = cacheKey;                    
                    dataSeries.Status = prursg.Engine.DataSeriesStatus.Bootstrapped;                                                            
                        
                    % write data                    
                    obj.WriteDataSeries(dataSeries);                
                end
            else
                dataSeries = inDataSeries;            
            end
        end
        
        % Update calibration results.        
        function outputFileName = UpdateCalibrationResults(obj, inputFileName, algorithmCache)
            import java.io.*;
            import javax.xml.parsers.*;
            import javax.xml.transform.*;
            import javax.xml.transform.dom.*;
            import org.w3c.dom.*;

            [folderName, filename] = fileparts(inputFileName);
            outputFileName = fullfile(folderName, [filename '_calibrated.xml']);

            docFactory = DocumentBuilderFactory.newInstance();
            docBuilder = docFactory.newDocumentBuilder();
            doc = docBuilder.parse(inputFileName);

            if ~isempty(doc)
                root = doc.getFirstChild();
                if ~isempty(root)
                    itemList = root.getElementsByTagName('Item');
                    if ~isempty(itemList)
                        for i = 1: itemList.getLength()
                            obj.UpdateCalibrationItem(itemList.item(i -1), algorithmCache);
                        end                    
                    end
                end

                % save updated xml.
                transformerFactory = TransformerFactory.newInstance();
                transformer = transformerFactory.newTransformer();        
                source = DOMSource(doc);
                result = javax.xml.transform.stream.StreamResult(java.io.File(outputFileName));
                transformer.transform(source, result);                       

            end

        end

        % Update calibration results for a given item.
        function UpdateCalibrationItem(obj, item, algorithmCache)      
            name = char(item.getAttribute('name'));
            calibrate = char(item.getAttribute('calibrate'));
            if isempty(calibrate) || strcmp(calibrate, 'true')
                if isKey(algorithmCache, name)
                    paramList = item.getElementsByTagName('Params');
                    if ~isempty(paramList) && paramList.getLength() > 0
                        properties = paramList.item(0).getElementsByTagName('Property');                                
                        obj.UpdateAlgorithmParams(properties, algorithmCache(name));                    
                    end
                end
            end
        end
        
        %% private functions required by bootstrapping.

        function outDataSeries = ProcessBootstrapItem(obj, item, xPathDoc, cache)

            import javax.xml.xpath.*;

            % The name and description attributes on the bootstrap control item are
            % to be set on the bootstrapped output DataSeries.
            outputName = char(item.getAttribute('name'));
            outputDescription = char(item.getAttribute('description'));

            % Grab the effective date of the Item and confirm that it is present
            % and populated. If not throw and exception and move to process the
            % next Item if present.
            itemEffectiveDate = char(item.getAttribute('effectiveDate'));
            if isempty(itemEffectiveDate)
                ex = MException('BootstrapEngine:ProcessBootstrapItem:EffectiveDateAttributeMissingFromItem',...
                    ['The "effectiveDate" attribute for Item ' outputName ' is missing or is not populated. The next item will be processed now (if present).']);
                throw(ex);
            end
    
            algorithmName = obj.GetAlgorithmName(xPathDoc, item);
            if isempty(algorithmName)
                ex = MException('BootstrapEngine:ProcessBootstrapItem', 'The bootstrap algorithm name is not set');
                throw(ex);
            end

            if ~isKey(cache, outputName)                

                % read input data series;
                nodeList = xPathDoc.Evaluate('./InputData/DataSeries', XPathConstants.NODESET, item);
                if ~isempty(nodeList)
                    nodeListLength = nodeList.getLength();            
                    inDataSeries = prursg.Engine.DataSeries.empty(nodeListLength, 0);

                    for i = 1:nodeListLength
                        dataSeriesName = char(nodeList.item(i - 1).getAttribute('name'));
                
                        % Grab the "from" date of the data series and confirm that it is present
                        % and populated. If not throw and exception and move to process the
                        % next Item if present.
                        dataSeriesFromDate = char(nodeList.item(i - 1).getAttribute('from'));
                        if isempty(dataSeriesFromDate)
                            ex = MException('BootstrapEngine:ProcessBootstrapItem:FromAttributeMissingFromDataSeries',...
                                ['The "from" attribute for Data Series ' dataSeriesName ' under Item ' outputName ' is missing or is not populated. The next item will be processed now (if present).']);
                            throw(ex);
                        end

                        % Grab the "to" date of the data series and confirm that it is present
                        % and populated. If not throw and exception and move to process the
                        % next Item if present.
                        dataSeriesToDate = char(nodeList.item(i - 1).getAttribute('to'));
                        if isempty(dataSeriesToDate)
                            ex = MException('BootstrapEngine:ProcessBootstrapItem:ToAttributeMissingFromDataSeries',...
                                ['The "to" attribute for Data Series ' dataSeriesName ' under Item ' outputName ' is missing or is not populated. The next item will be processed now (if present).']);
                            throw(ex);
                        end

                        % Compare the "from" and "to" dates. The "from" date must
                        % not exceed the "to" date.
                        % If it does throw and exception and move to process the
                        % next Item if present.
                        if datenum(dataSeriesFromDate) > datenum(dataSeriesToDate)
                            ex = MException('BootstrapEngine:ProcessBootstrapItem:FromDateExceedingToDate',...
                                ['The value of the "from" attribute exceeds the value of the "to" attribute for Data Series ' dataSeriesName ' under Item ' outputName '. The next item will be processed now (if present).']);
                            throw(ex);
                        end

                        % Compare the "to" date of the data series and the "effectiveDate" 
                        % date of the Item. The "to" date must not exceed the 
                        % "effectiveDate" date.
                        % If it does throw and exception and move to process the
                        % next Item if present.
                        if datenum(dataSeriesToDate) > datenum(itemEffectiveDate)
                            ex = MException('BootstrapEngine:ProcessBootstrapItem:ToDateExceedingEffectiveDate',...
                                ['The value of the "to" attribute of the Data Series ' dataSeriesName ' exceeds the value of the "effectiveDate" attribute of Item ' outputName '. The next item will be processed now (if present).']);
                            throw(ex);                        
                        end
                        
                        % firstly check the cache.                             
                        if isKey(cache, dataSeriesName)                            
                            ds = cache(dataSeriesName);                        
                        else
                            % check whether the data series is a derived one.
                            node = xPathDoc.Evaluate(['//Item[@name="' dataSeriesName '"]'], XPathConstants.NODE);
                            if ~isempty(node)
                                ds = obj.ProcessBootstrapItem(node, xPathDoc, cache);
                            else
                                ds = obj.RetrieveDataSeries(nodeList.item(i - 1), itemEffectiveDate);    
                            end                    
                        end
                        
                        if ~isempty(ds)                            
                            inDataSeries(i) = ds;                                                                            
                        end
                        
                        % validate retrieved data series.
                        if isempty(ds) || isempty(ds.dates)
                            ex = MException('BootstrapEngine:ProcessBootstrapItem:EmptyInputDataSeries',...
                           ['The requested input data series(' dataSeriesName ') is empty. The next item will be processed now (if present).']);
                            throw(ex);
                        end
                        
                    end
                end
        
                if ~isempty(inDataSeries)
                                                                            
                    % instantiate a bootstrapping engine        
                    algorithm = eval(['Bootstrap.' algorithmName '();']);      
                    obj.SetAlgorithmParams(xPathDoc,item,algorithm);

                    % bootstrap
                    outDataSeries = algorithm.Bootstrap(inDataSeries);

                    if ~isempty(outDataSeries)
                        outDataSeries = outDataSeries.Clone();
                        cache(outputName) = outDataSeries;
                        outDataSeries.Name = outputName;

                        % write the item description to the description field if
                        % present or add it if absent.
                        % descProp = prursg.Engine.DynamicProperty('description',outputDescription); 
                        % outDataSeries.AddReplaceDynamicProperty(descProp);

                        desc_key = 'description';  
                        % It's not necessary to test for existence as it's
                        % always safe to remove
                        outDataSeries.RemoveDynamicProperty(desc_key); 
                        outDataSeries.AddDynamicProperty(desc_key, outputDescription);
                        
                        outDataSeries.Status = prursg.Engine.DataSeriesStatus.Bootstrapped;

                        %override effective dates in the output data
                        %series.
                        obj.OverrideEffectiveDates(outDataSeries, itemEffectiveDate);
                        
                        obj.WriteDataSeries(outDataSeries);
                    end
                else

                    ex = MException('BootstrapEngine:ProcessBootstrapItem:NoDataSeriesToBootstrap',...
                        ['There are no Data Series to bootstrap for Item ' outputName '. The next item will be processed now (if present).']);
                    throw(ex);

                end
            end 
        end
        
        %% common functions.
        function value = GetAlgorithmName(obj, xPathDoc, item)
            import javax.xml.xpath.*;
            value = char(xPathDoc.Evaluate('./BootstrapAlgorithm/text()', XPathConstants.STRING, item));
        end

        % Set algorithm parameters from the parameter values defined in the xml.
        function SetAlgorithmParams(obj, xPathDoc,item,algorithm)
            import javax.xml.xpath.*;

            nodeList = xPathDoc.Evaluate('./Params/Property', XPathConstants.NODESET, item);
            if ~isempty(nodeList)
                for i = 1:nodeList.getLength()
                    item = nodeList.item(i - 1);
                    name = char(item.getAttribute('name'));
                    type = char(item.getAttribute('type'));
                    value = char(item.getTextContent());

                    if ~isempty(type) && strcmp(type, 'number') && ~isempty(value)
                        value = str2num(value);
                    end

                    eval(['algorithm.' name '= value;']);
                end
            end
        end

        % Update algorithm params.
        function UpdateAlgorithmParams(obj, properties, algorithm)

            if ~isempty(properties) && ~isempty(algorithm)
                for i = 1: properties.getLength()
                    name = char(properties.item(i-1).getAttribute('name'));
                    type = char(properties.item(i-1).getAttribute('type'));

                    eval(['value = algorithm.' name ';']);
                    if strcmp(type, 'number')
                        properties.item(i-1).setTextContent(prursg.Util.FormatNumber(value, obj.NumberFormatSpecifier));
                    else
                        properties.item(i-1).setTextContent(value);
                    end            
                end
            end
        end
        
        %Retrieve a data series.
        function dataSeries = RetrieveDataSeries(obj, item, varargin)
            dataSeriesName = char(item.getAttribute('name'));
            from = char(item.getAttribute('from'));
            to = char(item.getAttribute('to'));
            frequency = char(item.getAttribute('frequency'));
            dateOfMonth = char(item.getAttribute('dateOfMonth'));
            holidayCalendar = char(item.getAttribute('holidayCalendar'));
            missingDataTreatmentRule = char(item.getAttribute('missingDataTreatmentRule'));
            status = char(item.getAttribute('status'));
            if ~isempty(status)
                status = str2num(status);
            end
            purpose = char(item.getAttribute('purpose'));

            if ~isempty(varargin)
                effectiveDate = varargin{1};
            else
                effectiveDate = [];
            end
            dataSeries = obj.readDao.PopulateData(dataSeriesName, from, to, effectiveDate, status, purpose, frequency, dateOfMonth, holidayCalendar, missingDataTreatmentRule);
        end
        
        % Write dataseries by a DAO object.
        function WriteDataSeries(obj, dataSeries)     
            if strcmpi(class(obj.writeDao), 'prursg.HistoricalDAO.XmlHistoricalDataDao')
                obj.writeDao.OutputFileName = [dataSeries.Name '.xml'];
            end
            obj.writeDao.WriteData(dataSeries);
        end
        
        % Overrides effective dates in the given data series.
        function OverrideEffectiveDates(obj, outDataSeries, effectiveDate)
            for i = 1:length(outDataSeries)
                outDataSeries(i).effectiveDates = {};
                for j = 1 : length(outDataSeries(i).dates)
                    outDataSeries(i).effectiveDates{j, 1} = effectiveDate;
                end
            end
        end
        
    end
end
