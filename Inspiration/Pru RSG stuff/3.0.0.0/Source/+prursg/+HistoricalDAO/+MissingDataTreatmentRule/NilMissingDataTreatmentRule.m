classdef NilMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %NILMISSINGDATATREATMENTRULE Summary of this class goes here
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
                    outDataSeriesMap(schedules{i}) = [];
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

