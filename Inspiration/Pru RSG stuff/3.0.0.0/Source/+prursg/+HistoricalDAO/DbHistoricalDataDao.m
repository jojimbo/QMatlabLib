%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef DbHistoricalDataDao < prursg.HistoricalDAO.BaseHistoricalDataDao
    
%% Properties
% *|[dataSeriesDao]|* - reference to data access class for oracle
% connection to the MDS database.
% *|[holidayCalendarDao]|* - references class for holding public holidays
%

%MATLAB CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
    properties (Access=private)
        dataSeriesDao;
        holidayCalendarDao;
    end
    
    methods
        function obj = DbHistoricalDataDao()
            cm = prursg.Configuration.ConfigurationManager();                
            dbSetting = cm.ConnectionStrings('MDS');                
                
            obj.dataSeriesDao = prursg.mds.DataSeriesDao(dbSetting.Url, dbSetting.UserName, dbSetting.Password);
            obj.holidayCalendarDao = prursg.mds.HolidayCalendarDao(dbSetting.Url, dbSetting.UserName, dbSetting.Password);            
        end
        
        function dataSeries = PopulateDataSeriesContent(obj, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)
            dataSeries = [];
            df = java.text.SimpleDateFormat('dd/MMM/yyyy');
            ed = [];
            if ~isempty(effectiveDate)
                ed = df.parse(effectiveDate);
            end
            
            if isempty(status)
                status = 0;
            end
            
            javaFromDate = [];
            if ~isempty(fromDate)
                javaFromDate = df.parse(fromDate);
            end
            
            javaToDate = [];
            if ~isempty(toDate)
                javaToDate = df.parse(toDate);
            end
            
            javaDataSeries = obj.dataSeriesDao.Select(dataSeriesName, javaFromDate, javaToDate, ed, status, purpose);
            noOfDataSeries = javaDataSeries.size();
            if noOfDataSeries > 0
                
                dataSeries = prursg.Engine.DataSeries();
                dataSeries.Name = char(javaDataSeries.get(0).Name);

                dataSeries.Status = javaDataSeries.get(0).Status;
                dataSeries.Purpose = char(javaDataSeries.get(0).Purpose);
                                               
                % set axes.
                dataSeries.axes = obj.CombineAxes(javaDataSeries);
                
                % set dynamic properties.
                properties = prursg.Engine.DynamicProperty.empty();
                for i = 1:javaDataSeries.get(0).Properties.size()
                    javaProperty = javaDataSeries.get(0).Properties.get(i - 1);                    
                    p = prursg.Engine.DynamicProperty();
                    p.Name = char(javaProperty.Name);
                    p.Type = char(javaProperty.Type);
                    
                    p.Value = char(javaProperty.Value);
                    if strcmp(p.Type, 'number') && ~isempty(p.Value)
                        p.Value = str2num(p.Value);
                    else
                        % leave it like that
                    end        
                    %p.Value = char(javaProperty.Value);
                    
                    properties(end + 1) = p;
                end                
                dataSeries.SetDynamicProperties(properties);
                
                for i = 0:noOfDataSeries-1
                    dataSeries.dates{end + 1, 1} = char(df.format(javaDataSeries.get(i).DataDate));
                    dataSeries.effectiveDates{end + 1, 1} = char(df.format(javaDataSeries.get(i).EffectiveDate));
                    
                    values = obj.CreateMergedValues(javaDataSeries.get(i), dataSeries.axes);
                    dataSeries.values{end + 1, 1} = values;
                end
            end            
        end        
        
        function calendar = PopulateHolidayCalendarContent(obj, calendarName)
               
            calendar = [];
            
            javaCalendar = obj.holidayCalendarDao.Select(calendarName);
            
            if ~isempty(javaCalendar)
                calendar = prursg.HistoricalDAO.HolidayCalendar();
                calendar.Name = char(javaCalendar.Name);
                df = java.text.SimpleDateFormat('dd/MMM/yyyy');
                for i = 1:javaCalendar.Dates.size()
                    calendarValue = prursg.HistoricalDAO.HolidayCalendarValue();
                    calendarValue.Date = char(df.format(javaCalendar.Dates.get(i - 1).CalendarDate));
                    calendarValue.Desc = char(javaCalendar.Dates.get(i - 1).Desc);
                    calendar.Values(end + 1) = calendarValue;
                end
            end
            
        end
        
        function SerialiseData(obj, dataSeries)               
            
            tf = prursg.Util.ConfigurationUtil.AllowWriteMarketData();
            if ~tf
                ex = MException('DbHistoricalDataDao:WriteData', 'Accessing to the WriteData function is disabled in the configuration file.');
                throw(ex);
            end
            
            df = java.text.SimpleDateFormat('dd/MMM/yyyy');
            for i = 1:length(dataSeries)      
                ds = dataSeries(i);
                
                noOfValues = 1;
                tempDataSeries = prursg.mds.DataSeries();
                for j = 1: length(ds.axes)
                    javaAxis = prursg.mds.DataSeriesAxis(j, ds.axes(j).title);      
                    tempDataSeries.Axes.add(javaAxis);
                    noOfValues = noOfValues * length(ds.axes(j).values);
                end
                
                dynamicProperties = dataSeries.GetDynamicProperties();
                if ~isempty(dynamicProperties)
                    for j = 1:length(dynamicProperties)
                        p = prursg.mds.DataSeriesProperty();
                        p.Name = dynamicProperties(j).Name;
                        p.Type = dynamicProperties(j).Type;
                        if strcmp(p.Type, 'number')
                            p.Value = prursg.Util.FormatNumber(dynamicProperties(j).Value, obj.NumberFormatSpecifier);
                        else
                            p.Value = dynamicProperties(j).Value;
                        end
                        tempDataSeries.Properties.add(p);
                    end
                end
                                    
                for j = 1: length(ds.dates)
                    javaDataSeries = prursg.mds.DataSeries();
                    javaDataSeries.Name = ds.Name;                    
                    javaDataSeries.Purpose = ds.Purpose;
                    javaDataSeries.DataDate = df.parse(ds.dates{j});
                    if ~isempty(ds.effectiveDates{j})
                        javaDataSeries.EffectiveDate = df.parse(ds.effectiveDates{j});
                    end
                    javaDataSeries.Axes = tempDataSeries.Axes;
                    javaDataSeries.Properties = tempDataSeries.Properties;
                    
                    values = ds.values{j};
                    
                    if ~isempty(ds.axes)                                              
                        switch length(ds.axes)
                            case 1
                                for j1 = 1:length(ds.axes(1).values)
                                    if ~isnan(values(j1))
                                        javaDataSeries.Values.add(prursg.mds.DataSeriesValue(str2double(prursg.Util.FormatNumber(values(j1), obj.NumberFormatSpecifier)), prursg.Util.FormatNumber(ds.axes(1).values{j1}, obj.NumberFormatSpecifier), [], [], [], []));                                    
                                    end                                                                       
                                end
                            case 2                                
                                for j1 = 1:length(ds.axes(1).values)
                                    for j2 = 1:length(ds.axes(2).values)     
                                        if ~isnan(values(j1, j2))
                                            javaDataSeries.Values.add(prursg.mds.DataSeriesValue(str2double(prursg.Util.FormatNumber(values(j1, j2), obj.NumberFormatSpecifier)), prursg.Util.FormatNumber(ds.axes(1).values{j1}, obj.NumberFormatSpecifier), prursg.Util.FormatNumber(ds.axes(2).values{j2}, obj.NumberFormatSpecifier), [], [], []));                                    
                                        end                                        
                                    end
                                end
                            case 3                                
                                for j1 = 1:length(ds.axes(1).values)
                                    for j2 = 1:length(ds.axes(2).values)
                                        for j3=1:length(ds.axes(3).values)    
                                            if ~isnan(values(j1, j2, j3))
                                                javaDataSeries.Values.add(prursg.mds.DataSeriesValue(str2double(prursg.Util.FormatNumber(values(j1, j2, j3), obj.NumberFormatSpecifier)), prursg.Util.FormatNumber(ds.axes(1).values{j1}, obj.NumberFormatSpecifier), prursg.Util.FormatNumber(ds.axes(2).values{j2}, obj.NumberFormatSpecifier), prursg.Util.FormatNumber(ds.axes(3).values{j3}, obj.NumberFormatSpecifier),  [], []));                                    
                                            end                                            
                                        end
                                    end
                                end
                        end
                    else
                        javaDataSeries.Values.add(prursg.mds.DataSeriesValue(str2double(prursg.Util.FormatNumber(values(1), obj.NumberFormatSpecifier)), [], [], [], [], []));                        
                    end
                    
                    if ~isempty(ds.Status) && int32(ds.Status) > 0
                        javaDataSeries.Status = int32(ds.Status);
                    end
                    obj.dataSeriesDao.Insert(javaDataSeries);
                end
            end                        
        end
    end
    
    methods(Access=private)
        
        function values = CreateMergedValues(obj, dataSeries, axes)

            % Depending on the number of axes, create a matrix filled up by NaN
            % values. This will be used to populate the values for each time series
            % date.            
            noAxes = length(axes);     
            if noAxes == 0
                values = obj.GetDataSeriesValues(dataSeries);
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
                            for i = 0:dataSeries.Values.size() - 1
                                [truefalse, index1] = ismember(char(dataSeries.Values.get(i).Axis1Value), axes(1).values);
                                [truefalse, index2] = ismember(char(dataSeries.Values.get(i).Axis2Value), axes(2).values);
                                subCube(index1,index2) = dataSeries.Values.get(i).Value;                     
                            end
                        case 3
                            for i = 0:dataSeries.Values.size() - 1
                                [truefalse, index1] = ismember(char(dataSeries.Values.get(i).Axis1Value), axes(1).values);
                                [truefalse, index2] = ismember(char(dataSeries.Values.get(i).Axis2Value), axes(2).values);
                                [truefalse, index3] = ismember(char(dataSeries.Values.get(i).Axis3Value), axes(3).values);
                                subCube(index1,index2,index3) = dataSeries.Values.get(i).Value;
                            end
                    end
                else
                    for i = 0:dataSeries.Values.size() - 1
                        [truefalse, index] = ismember(char(dataSeries.Values.get(i).Axis1Value), axes(1).values);
                        subCube(1, index) = dataSeries.Values.get(i).Value;
                    end
                end

                values = subCube;
            
            end
                        
        end
         
        function CheckAxis(obj, previousAxis, currentAxis)
            if ~isempty(previousAxis) && ~isempty(currentAxis)
                if (previousAxis.size() ~= currentAxis.size())
                    throw(MException('DBHistoricalDataDao:CheckAxis', 'Axis size dose not match.')); 
                end
                for i = 0:previousAxis.size() - 1
                    if ~previousAxis.get(i).Name.equals(currentAxis.get(i).Name)
                        throw(MException('DBHistoricalDataDao:CheckAxis', 'Axis hierachy dose not match.')); 
                    end
                end
            end
        end
        
        function axes = CombineAxes(obj, javaDataSeries)

            axes = [];
            previousAxis = [];
            dsAxis = [];
            noOfDataSeries = javaDataSeries.size();

            axesMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');  
            for i = 0:noOfDataSeries-1                
                dsAxis = javaDataSeries.get(i).Axes;                
                
                obj.CheckAxis(previousAxis, dsAxis);
                previousAxis = dsAxis;
                
                axisValuesMap = obj.GetAxisValuesMap(javaDataSeries.get(i).Values);                
                for j = 0:dsAxis.size() - 1                    
                    key = j + 1;
                    if isKey(axesMap, key)                       
                        axesMap(key) = [axesMap(key) axisValuesMap(j+1)];                    
                    else
                        axesMap(key) = [axisValuesMap(j+1)];
                    end
                end
            end
            
            if ~isempty(dsAxis)
                axesMapKeys = keys(axesMap);
                axes = prursg.Engine.Axis.empty(length(axesMapKeys), 0);            

                for i = 0:dsAxis.size() - 1                    
                    tempAxis = axesMap(axesMapKeys{i + 1});                
                    [junk, index] = unique(tempAxis, 'first');                
                    axes(i + 1).values = tempAxis(sort(index));                
                    axes(i + 1).title = char(dsAxis.get(i).Name);
                end
            end            
        end

        function AddJavaValues(obj, javaValues, axes, values, parentIndex, parentValue)

            for i = 1:length(axes(level).values)
                index = (parentIndex - 1) * length(axes(level)) + i;        
                if level >= length(axes) % leaf node.
                    % write values            
                    for j = 1: length(dates)                
                        javaValues.add(prursg.mds.DataSeriesValue());            
                    end            
                else                    
                    obj.AddJavaValues(javaValues, axes, values, level + 1, index, skipSize, axis1Value, axis2Value, axis3Value, axis4Value, axis5Value);
                end        
            end
        end

        % Returns a cell array of upto 5 axes of values
        function resultMap = GetAxisValuesMap(obj, javaValues)
            
            MAX_NUMBER_AXES = 5; % The database supports a maximum of 5 axes

            resultMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            axisValueMap = cell(1, MAX_NUMBER_AXES);
            numberOfValues = javaValues.size();

            for i = 1:numberOfValues
                for j = 1:MAX_NUMBER_AXES
                    axisValue = eval(['char(javaValues.get(i -1).Axis' num2str(j) 'Value);']);
                    if ~ismember(axisValue,axisValueMap{1,j})
                        axisValueMap{1,j}{end + 1} = axisValue;                    
                    end
                end
            end

            for i = 1:MAX_NUMBER_AXES
                resultMap(i) = axisValueMap{i};
            end
        end

        function values = GetDataSeriesValues(obj, javaDataSeries)

            javaValues = javaDataSeries.Values;        
            values = zeros(1, javaValues.size());
            for i = 1:javaValues.size()
                values(i) = javaValues.get(i-1).Value;
            end
        end
    end
end

