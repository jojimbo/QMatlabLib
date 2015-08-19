classdef DataSeriesDate
    %DATASERIESDATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        AsAtDate
        EffectiveDate        
    end
    
    methods
        function obj = DataSeriesDate
            obj.EffectiveDate = '1/Jan/1900';            
        end
    end
    
end

