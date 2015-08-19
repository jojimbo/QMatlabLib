classdef HolidayCalendar
    %HOLIDAYCALENDAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name;
        Values
    end
    
    methods
        function obj = HolidayCalendar()   
            obj.Values = prursg.HistoricalDAO.HolidayCalendarValue.empty();
        end   
        
        function tf = IsHoliday(obj, inputDate)
            tf = false;
            for i = 1:length(obj.Values)
                holiday = obj.Values(i).Date;
                if datenum(inputDate) == datenum(holiday)
                    tf = true;
                    break;
                end
            end
        end
    end
    
end

