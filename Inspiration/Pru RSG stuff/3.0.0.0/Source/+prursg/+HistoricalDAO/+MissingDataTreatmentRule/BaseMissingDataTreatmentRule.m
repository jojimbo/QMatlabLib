classdef BaseMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.IMissingDataTreatmentRule
    %BASEMISSINGDATATREATMENTRULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        scheduleGenerator;
    end
    
    methods(Abstract, Access=protected)
        outDataSeries = Generate(obj, inDataSeries, schedules, holidayCalendar)
    end
    
    methods(Access=protected)
        function dataSeriesMap = GenerateDataSeriesMap(obj, inDataSeries)
            dataSeriesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');            
            for i = 1:length(inDataSeries.dates)
                dataSeriesMap(datenum(inDataSeries.dates{i})) = inDataSeries.values{i};
            end
        end
    end
    
    methods
        function obj= BaseMissingDataTreatmentRule()
            obj.scheduleGenerator = prursg.HistoricalDAO.MissingDataTreatmentRule.ScheduleGenerator;
        end
        
        function outDataSeries = Run(obj, inDataSeries, fromDate, toDate, frequency, dateOfMonth, holidayCalendar)
            schedules = {};
            if isempty(frequency)
                schedules = cell(1, length(inDataSeries.dates));
                for i = 1:length(inDataSeries.dates)
                    schedules{i} = datenum(inDataSeries.dates{i});
                end
            else
                schedules = obj.scheduleGenerator.GenerateSchedules(fromDate, toDate, frequency, dateOfMonth);    
            end
                        
            outDataSeries = obj.Generate(inDataSeries, schedules, holidayCalendar);            
        end
    end
    
end

