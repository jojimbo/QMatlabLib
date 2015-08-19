classdef BaseHistoricalDataDao < prursg.HistoricalDAO.IHistoricalDataDao
    %BASEHISTORICALDATADAO 
    %   
    
    properties(Access = public)
        CacheDataSeries
        CacheHolidayCalendar
    end
    
    properties(Access = private)
        dataSeriesMap
        holidayCalendarMap
        missingDataTreatmentRuleFactory
    end
    
       
    methods(Abstract)
        dataSeries = PopulateDataSeriesContent(obj, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose)
        holidayCalendar = PopulateHolidayCalendarContent(obj, calendarName)
        SerialiseData(obj, dataSeries)
    end
    
    methods(Access = public)
        
        function obj = BaseHistoricalDataDao()
            obj.CacheDataSeries = 1; % by default, enable caching.
            obj.CacheHolidayCalendar = 1;
            obj.dataSeriesMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.holidayCalendarMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.missingDataTreatmentRuleFactory = prursg.HistoricalDAO.MissingDataTreatmentRule.MissingDataTreatmentRuleFactory;
        end
                
        function dataSeries = PopulateData(obj, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose, frequency, dateOfMonth, holidayCalendarName, missingDataTreatmentRuleName)
            
            if ~obj.CacheDataSeries
                % remove data from the cache.
                remove(obj.dataSeriesMap, keys(obj.dataSeriesMap));              
            end
            
            %build cache key.
            %key = lower(sprintf(repmat('~%s~', 1, 10), dataSeriesName, fromDate, toDate, effectiveDate, num2str(status), purpose, frequency, num2str(dateOfMonth), holidayCalendarName, missingDataTreatmentRuleName));            
            %if isKey(obj.dataSeriesMap, key)
            %    dataSeries = obj.dataSeriesMap(key);
            %else
                dataSeries = obj.PopulateDataSeriesContent(dataSeriesName, fromDate, toDate, effectiveDate, status, purpose);                
                if ~isempty(dataSeries)
                    dataSeries = obj.SortDataSeries(dataSeries);
                    dataSeries.axes = obj.ConvertAxes(dataSeries.axes);
                    dataSeries = obj.ProcessMissingData(dataSeries, fromDate, toDate, frequency, dateOfMonth, holidayCalendarName, missingDataTreatmentRuleName);
                    %obj.dataSeriesMap(key) = dataSeries;
                end
            %end            
        end                  
        
        function holidayCalendar = PopulateHolidayCalendar(obj, calendarName)
            if ~obj.CacheHolidayCalendar
                % remove data from the cache.               
                remove(obj.holidayCalendarMap, keys(obj.holidayCalendarMap));                           
            end
            
            key = lower(calendarName);
            
            if isKey(obj.holidayCalendarMap, key)
                holidayCalendar = obj.holidayCalendarMap(key);
            else
                holidayCalendar = obj.PopulateHolidayCalendarContent(calendarName);
                obj.holidayCalendarMap(key) = holidayCalendar;
            end            
        end
        
        function WriteData(obj, dataSeries)        
            obj.CheckNaNValues(dataSeries);
            obj.SerialiseData(dataSeries);
        end
        
    end
     
    
    methods(Access=private)
        
        function outDataSeries = ProcessMissingData(obj, inDataSeries, fromDate, toDate, frequency, dateOfMonth, holidayCalendarName, treatmentRuleName)
                outDataSeries = inDataSeries;
                name = 'Skip'; % default value if the rule is not set.                
                holidayCalendar = [];
                if ~isempty(treatmentRuleName)
                    name = treatmentRuleName;
                end
                
                if ~isempty(holidayCalendarName)
                    holidayCalendar = obj.PopulateHolidayCalendar(holidayCalendarName);
                end
                                
                rule = obj.missingDataTreatmentRuleFactory.Create(name);
                if ~isempty(rule)                    
                    outDataSeries = rule.Run(inDataSeries, fromDate, toDate, frequency, dateOfMonth, holidayCalendar);
                end
                
        end
        
        function newAxes = ConvertAxes(obj, axes)

            newAxes = prursg.Engine.Axis.empty();

            for i = 1:length(axes)
                newAxis = axes(i).Convert();       
                newAxes(end + 1) = newAxis;
            end    
        end


        function sortedDataSeries = SortDataSeries(obj, dataSeries)
            nums = cellfun(@(x)(datenum(x)), dataSeries.dates, 'UniformOutput', false);
            nums = cell2mat(nums);
            [v indexes] = sort(nums);
            sortedDataSeries = dataSeries.Clone();
            sortedDataSeries.dates = cell(length(dataSeries.dates), 1);
            sortedDataSeries.effectiveDates = cell(length(dataSeries.dates), 1);
            sortedDataSeries.values = cell(length(dataSeries.dates), 1);

            for i = 1:length(indexes)
                sortedDataSeries.dates{i} = dataSeries.dates{indexes(i)};
                sortedDataSeries.effectiveDates{i} = dataSeries.effectiveDates{indexes(i)};
                sortedDataSeries.values{i} = dataSeries.values{indexes(i)};
            end
        end
        
        %Check whether data series to be serialised contain any NaN values.        
        function CheckNaNValues(obj, dataSeries)
            for i = 1: length(dataSeries)
                values = dataSeries(i).values;
                if ~isempty(values)
                    indexes = find(isnan(values{1}));
                    if ~isempty(indexes)
                        throw(MException('BaseHistoricalDataDao:CheckNaNValues', 'The data series must not contain any NaN values to be serialised.'));
                    end
                end
            end
        end
                
    end
    
    
end
