classdef ExceptionMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %EXCEPTIONMISSINGDATATREATMENTRULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Access=protected)
        function outDataSeries = Generate(obj, inDataSeries, schedules, holidayCalendar)
            outDataSeries = [];            
            dataSeriesMap = obj.GenerateDataSeriesMap(inDataSeries);
            
            for i = 1:length(schedules)
                if ~isKey(dataSeriesMap, schedules{i})                    
                    ex = MException('ExceptionMissingDataTreatmentRule:Generate', 'The data series for %s is not found.', datestr(schedules{i}));
                    throw(ex);
                end
            end            
            outDataSeries = inDataSeries;
        end
    end
    
end

