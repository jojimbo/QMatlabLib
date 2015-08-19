classdef SkipMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %SKIPMISSINGDATATREATMENTRULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Access=protected)
        function outDataSeries = Generate(obj, inDataSeries, schedules, holidayCalendar)
            %ignore schedules and holiday calendar.
            outDataSeries = inDataSeries;
        end
    end
    
end

