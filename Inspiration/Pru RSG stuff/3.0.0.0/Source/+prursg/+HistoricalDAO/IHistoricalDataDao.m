classdef IHistoricalDataDao < handle
    %IHISTORICALDATADAO 
    %   IHistoricalDataDao interface.
    
    properties
        NumberFormatSpecifier
    end
    
        
    methods(Abstract)        
        dataSeries = PopulateData(obj, dataSeriesName, fromDate, toDate, effectiveDate, status, purpose, frequency, dateofMonth, holidayCalendarName, missingDataTreatmentRuleName)
        holidayCalendar = PopulateHolidayCalendar(obj, calendarName)
        WriteData(obj, dataSeries)        
    end                
    
end

