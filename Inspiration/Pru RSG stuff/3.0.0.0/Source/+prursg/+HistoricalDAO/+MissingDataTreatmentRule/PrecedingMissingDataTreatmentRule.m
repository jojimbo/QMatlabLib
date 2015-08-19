classdef PrecedingMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %PRECEDINGMISSINGDATATREATMENTRULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Access=protected)
        function outDataSeries = Generate(obj, inDataSeries, schedules, holidayCalendar)
            outDataSeries = [];            
            dataSeriesMap = obj.GenerateDataSeriesMap(inDataSeries);
            outDataSeriesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for i = 1:length(schedules)
                if ~isKey(dataSeriesMap, schedules{i})       
                    precedingDate = FindPrecedingDate(schedules{i}, holidayCalendar, schedules{1});
                    if ~isKey(dataSeriesMap, precedingDate)       
                        ex = MException('PrecedingMissingDataTreatmentRule:Generate', 'The preceding date(%s)''s data series for the requested date %s is not found.', datestr(precedingDate), datestr(schedules{i}));
                        throw(ex);
                    else
                        outDataSeriesMap(schedules{i}) = dataSeriesMap(precedingDate);
                    end
                else
                    outDataSeriesMap(schedules{i}) = dataSeriesMap(schedules{i});
                end
            end            
            outDataSeries = prursg.Engine.DataSeries();
            outDataSeries.Name = inDataSeries.Name;
            outDataSeries.Status = inDataSeries.Status;
            outDataSeries.Purpose = inDataSeries.Purpose;
            outDataSeries.axes = inDataSeries.axes;
            properties = inDataSeries.GetDynamicProperties();
            outDataSeries.SetDynamicProperties(properties);
            dataSeriesKeys = keys(outDataSeriesMap);
            noOfKeys = length(dataSeriesKeys);
            outDataSeries.dates = cell(noOfKeys, 1);
            outDataSeries.values = cell(noOfKeys, 1);
            
            for i = 1:noOfKeys
                outDataSeries.dates{i} = datestr(dataSeriesKeys{i}, 'dd/mmm/yyyy');
                outDataSeries.values{i} = outDataSeriesMap(dataSeriesKeys{i});
            end
            
        end
    end
    
end

function precedingDate = FindPrecedingDate(pivotDate, holidayCalendar, startDate)
    precedingDate = [];
    if isempty(holidayCalendar)
        precedingDate = addtodate(pivotDate, -1, 'day');
    else
        precedingDate = addtodate(pivotDate, -1, 'day');
        while (true)            
            if precedingDate <= startDate
                break;
            else
                if weekday(precedingDate) > 1 && weekday(precedingDate) < 7 && ~holidayCalendar.IsHoliday(precedingDate)
                    break;
                end    
            end     
            precedingDate = addtodate(precedingDate, -1, 'day');
        end               
    end
end

