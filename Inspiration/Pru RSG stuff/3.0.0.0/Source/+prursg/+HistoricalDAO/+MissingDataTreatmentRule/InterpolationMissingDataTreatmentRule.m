classdef InterpolationMissingDataTreatmentRule < prursg.HistoricalDAO.MissingDataTreatmentRule.BaseMissingDataTreatmentRule
    %INTERPOLATIONMISSINGDATATREATMENTRULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Access=protected)
        function outDataSeries = Generate(obj, inDataSeries, schedules, holidayCalendar)
            outDataSeries = [];            
            dataSeriesMap = obj.GenerateDataSeriesMap(inDataSeries);
            dataSeriesKeys = keys(dataSeriesMap);
            outDataSeriesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            for i = 1:length(schedules)
                if ~isKey(dataSeriesMap, schedules{i})       
                    leftDataSeries = FindLeftDataSeries(dataSeriesKeys, schedules{i}, dataSeriesMap);
                    rightDataSeries = FindRightDataSeries(dataSeriesKeys, schedules{i}, dataSeriesMap);
                    outDataSeriesMap(schedules{i}) = Interpolate(leftDataSeries, rightDataSeries);
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


function values = Interpolate(leftValues, rightValues)
    values = [];
    if ~isempty(leftValues) && isempty(rightValues)
        values = leftValues;
    elseif isempty(leftValues) && ~isempty(rightValues)
        values = rightValues;
    elseif ~isempty(leftValues) && ~isempty(rightValues)
        values = (leftValues + rightValues) ./ 2;
    end
end

function dataSeries = FindLeftDataSeries(dataSeriesKeys, pivotDate, dataSeriesMap)

    dataSeries = [];
    results = find(cell2mat(cellfun(@(x)(x < pivotDate), dataSeriesKeys, 'UniformOutput', false)));
    if ~isempty(results)
        key = dataSeriesKeys{results(end)};
        dataSeries = dataSeriesMap(key);
    end        

end

function dataSeries = FindRightDataSeries(dataSeriesKeys, pivotDate, dataSeriesMap)
    dataSeries = [];
    results = find(cell2mat(cellfun(@(x)(x > pivotDate), dataSeriesKeys, 'UniformOutput', false)));
    if ~isempty(results)
        key = dataSeriesKeys{results(1)};
        dataSeries = dataSeriesMap(key);
    end
end

