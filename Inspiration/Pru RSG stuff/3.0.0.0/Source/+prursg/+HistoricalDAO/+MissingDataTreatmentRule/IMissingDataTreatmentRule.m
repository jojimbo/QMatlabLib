classdef IMissingDataTreatmentRule < handle
    %IMISSINGDATATREATMENTRULE Summary of this function goes here
    %   Detailed explanation goes here
   
    properties
        
    end
    
    methods(Abstract)
        outDataSeries = Run(obj, inDataSeries, from, to, frequency, dateOfMonth, holidayCalendar)
    end
    
end

