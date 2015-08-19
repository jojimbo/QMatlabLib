classdef FollowingMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %FOLLOWINGMISSINGDATATREATMENTRULE Summary of this class goes here
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
                    followingDate = FindFollowingDate(schedules{i}, holidayCalendar, schedules{end});
                    if ~isKey(dataSeriesMap, followingDate)       
                        ex = MException('FollowingMissingDataTreatmentRule:Generate', 'The following date(%s)''s data series for the requested date %s is not found.', datestr(followingDate), datestr(schedules{i}));
                        throw(ex);
                    else
                        outDataSeriesMap(schedules{i}) = dataSeriesMap(followingDate);
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

function followingDate = FindFollowingDate(pivotDate, holidayCalendar, endDate)
    followingDate = [];
    if isempty(holidayCalendar)
        followingDate = addtodate(pivotDate, 1, 'day');
    else
        followingDate = addtodate(pivotDate, 1, 'day');
        while (true)            
            if followingDate >= endDate
                break;
            else
                if weekday(followingDate) > 1 && weekday(followingDate) < 7 && ~holidayCalendar.IsHoliday(followingDate)
                    break;
                end    
            end     
            
            followingDate = addtodate(followingDate, 1, 'day');
        end               
    end
end

