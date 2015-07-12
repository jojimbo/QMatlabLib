classdef HistoricalDAO_DynamicV3
    % DAO that reads data from historical data database
    
    properties
        folderPath = '' % folder path of the input data files
    end
    
    methods
        function obj = HistoricalDAO_DynamicV3(folderPath)
            % HistoricalDAO - Constructor
            obj.folderPath = folderPath;
        end
        function dataObj = populateData(obj, dataName, dateStart, dateEnd)
            % main method that populates a DataSeries obj given a data name
            % in the database and relevant dates
            
            import prursg.Engine.*;
            % pull out raw data
            [rawNumbers rawText] = obj.getRawData(dataName);
            % determine dimensionality of data
            cont = true;
            i = 0;
            while cont == true
                i = i + 1;
                if obj.checkIsDate(rawText{i}) == 1
                    cont = false;
                end
            end
            numDim = i-1;
            % format into a DataSeries object
            dataObj = obj.createDataObj(rawNumbers, rawText, numDim, dateStart, dateEnd);
        end
        
        function writeData(obj, fileName, dataSeries)
            import prursg.Engine.*;
            fid = fopen(fullfile(pwd, obj.folderPath, [fileName '.csv']),'w');
            if fid < 0
                disp('HistoricalDAO - Warning: cannot create or open specified file');
                return
            end
            obj.writeSeries(fid,dataSeries);
            fclose(fid);
        end
        
        function writeSeries(obj, fid, dataSeries)
            obj.writeHeader(fid, dataSeries);
            % write actual data
            for i=1:numel(dataSeries.dates)
                fprintf(fid, '%s', dataSeries.dates{i});
                data = dataSeries.getFlatData(i);
                for j=1:numel(data)
                    fprintf(fid, ',%g', data(j));
                end
                fprintf(fid, '\r\n');
            end
        end
        
        function writeHeader(obj, fid, dataSeries)
            % write headers
            width = dataSeries.getSize();
            numDim = length(dataSeries.axes);
            switch numDim
                case 0
                    headerNames = [];
                case 1
                    headerNames = cell(numDim,1);
                    for i = 1:numDim
                        headerNames{i} = dataSeries.axes(i).title;
                    end
                    k = 0;
                    for i1 = 1:length(dataSeries.axes(1).values)
                        k = k + 1;
                        headerValues(1,k) = dataSeries.axes(1).values(i1);
                    end
                case 2
                    headerNames = cell(numDim,1);
                    for i = 1:numDim
                        headerNames{i} = dataSeries.axes(i).title;
                    end
                    k = 0;
                    for i1 = 1:length(dataSeries.axes(1).values)
                        for i2 = 1:length(dataSeries.axes(2).values)
                            k = k + 1;
                            headerValues(1,k) = dataSeries.axes(1).values(i1);
                            headerValues(2,k) = dataSeries.axes(2).values(i2);
                        end
                    end
                case 3
                    headerNames = cell(numDim,1);
                    for i = 1:numDim
                        headerNames{i} = dataSeries.axes(i).title;
                    end
                    k = 0;
                    for i1 = 1:length(dataSeries.axes(1).values)
                        for i2 = 1:length(dataSeries.axes(2).values)
                            for i3 = 1:length(dataSeries.axes(3).values)
                                k = k + 1;
                                headerValues(1,k) = dataSeries.axes(1).values(i1);
                                headerValues(2,k) = dataSeries.axes(2).values(i2);
                                headerValues(3,k) = dataSeries.axes(3).values(i3);
                            end
                        end
                    end
            end
            
            % write headers
            if ~isempty(headerNames)
                for i = 1:numDim
                    fprintf(fid, '%s', headerNames{i});
                    for j = 1:width
                        fprintf(fid, ',%g', headerValues(i,j));
                    end
                    fprintf(fid, '\r\n');
                end
            end
        end
        
        function dataObj = createDataObj(obj,rawNumbers, rawText, numDim, dateStart, dateEnd)
            % format data and then instantiate a DataSeries object
            allAxis = [];
            for i = 1:numDim
                axis = Axis();
                axis.title = rawText{i,1};
                axis.values = obj.getUniqueElements(rawNumbers(i,:));
                allAxis = [allAxis axis];
            end
            datesAll = cell(size(rawText,1)-numDim,1);
            for i = numDim+1:size(rawText,1)
                datesAll{i-numDim} = rawText{i,1};
            end
            
            % remove dates for which data not requested
            startPos = 1;
            endPos = length(datesAll);
            cont = true;
            j = 0;
            while cont == true
                j = j + 1;
                if obj.date2Num(datesAll{j}) <= obj.date2Num(dateEnd)
                    cont = false;
                    startPos = j;
                end
            end
            cont = true;
            j = 0;
            while cont == true
                j = j + 1;
                if obj.date2Num(datesAll{j}) <= obj.date2Num(dateStart)
                    cont = false;
                    endPos = j;
                end
            end
            j = 0;
            dates = cell(endPos-startPos+1,1);
            for i = startPos:endPos
                j = j + 1;
                dates{j} = datesAll{i};
            end
            rawNumbers = rawNumbers(numDim+startPos:numDim+endPos,:);
            
            % generate data cubes
            numDates = size(dates,1);
            switch numDim
                case 0
                    values = obj.generate0DData(numDates, rawNumbers, allAxis);
                case 1
                    values = obj.generate1DData(numDates, rawNumbers, allAxis);
                case 2
                    values = obj.generate2DData(numDates, rawNumbers, allAxis);
                case 3
                    values = obj.generate3DData(numDates, rawNumbers, allAxis);
            end

            % instantiate a DataSeries object and populate properties
            dataObj = obj.populateDataObj(allAxis,dates,values);
            
            import prursg.Engine.*;
           % dataObj = DataSeries();
            dataObj = DataSeries_DynamicV3();
            dataObj.axes = allAxis;
            dataObj.values = values;
            dataObj.dates = dates;
        end
        
        function [rawNumbers rawText] = getRawData(obj,dataName)
            % pulls raw data out of input data files, to be replaced by a
            % query into the Cadis database
            
            % [rawNumbers rawText] = xlsread([ pwd '\' obj.folderPath '\' dataName '.csv']);
            % rawData = csvread([ pwd '\' obj.folderPath '\' dataName '.csv']);
            fid = fopen(fullfile(pwd, obj.folderPath, [dataName '.csv']));
            rawData = textscan(fid,'%s','delimiter','\n');
            fclose(fid);
            rawText = cell(length(rawData{1}),1);
            rawNumbers = [];
            for i = 1:length(rawData{1})
                dataString = cell2mat(rawData{1}(i));
                [someText someNumbers] = obj.convertDataString(dataString);
                rawText{i} = someText;
                rawNumbers = [rawNumbers ; someNumbers];
            end
        end
        
        function elements = getUniqueElements(obj, anArray)
            % given anArray, generate an array of unique elements
            anArray = sort(anArray);
            elements(1) = anArray(1);
            for i = 2:length(anArray)
                if anArray(i) ~= elements(end)
                    elements = [elements anArray(i)];
                end
            end
        end
        
        function values = generate0DData(obj, numDates, rawNumbers, allAxis)
            values = cell(numDates,1);
            for i1 = 1:numDates
                values{i1} = rawNumbers(i1);
            end
        end
        
        function values = generate1DData(obj, numDates, rawNumbers, allAxis)
            values = cell(numDates,1);
            for i1 = 1:numDates
                subCube = [];
                j = 0;
                for i2 = 1:length(allAxis(1).values)
                   j = j + 1;
                   subCube(i2) = rawNumbers(i1,j);
                end
                values{i1} = subCube;
            end
        end
        
        function values = generate2DData(obj, numDates, rawNumbers, allAxis)
            values = cell(numDates,1);
            for i1 = 1:numDates
                subCube = [];
                j = 0;
                for i2 = 1:length(allAxis(1).values)
                    for i3 = 1:length(allAxis(2).values)
                        j = j + 1;
                        subCube(i2,i3) = rawNumbers(i1,j);
                    end
                end
                values{i1} = subCube;
            end
        end
        
        function values = generate3DData(obj, numDates, rawNumbers, allAxis)
            values = cell(numDates,1);
            for i1 = 1:numDates
                subCube = [];
                j = 0;
                for i2 = 1:length(allAxis(1).values)
                    for i3 = 1:length(allAxis(2).values)
                        for i4 = 1:length(allAxis(3).values)
                            j = j + 1;
                            subCube(i2,i3,i4) = rawNumbers(i1,j);
                        end
                    end
                end
                values{i1} = subCube;
            end
        end
        
        function dataObj = populateDataObj(obj, allAxis,dates,values)
            % given axis, dates and values, instantiate a DataSeries object
            import prursg.Engine.*;
            % dataObj = DataSeries();
            dataObj = DataSeries_DynamicV3();
            dataObj.axes = allAxis;
            dataObj.values = values;
            dataObj.dates = dates;
        end
        
        function [rawText rawNumbers] = convertDataString(obj, s)
            % convert dataString into text and array of numbers
            Pos = findstr(s,',');
            rawText = s(1:Pos(1)-1);
            rawNumbers = [];
            if length(Pos) == 1
                rawNumbers = str2num(s(Pos(1)+1:end));
            else
                for i = 2:length(Pos)
                    rawNumbers(i-1) = str2num(s(Pos(i-1)+1:Pos(i)-1));
                end
                rawNumbers(i) = str2num(s(Pos(i)+1:end));
            end
        end
        
        function check = checkIsDate(obj, s)
            check = 1;
            try
                datenum(s);
            catch
                check = 0;
            end
        end
        
        function num = date2Num(obj, dateString)
            % convert dataString into text and array of numbers
            Pos = findstr(dateString,'/');
            day = str2num(dateString(1:Pos(1)-1));
            month = str2num(dateString(Pos(1)+1:Pos(2)-1));
            year = str2num(dateString(Pos(2)+1:end));
            num = year - 1900 + month/12 + day/365.25;
        end
    end
end