classdef Timestep
    %TIMESTEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        date % the date of the timestep in datenum format
        expandedUniverse % a container.Map(risk.name, risk expanded values)
    end
    
    methods
        function obj = Timestep(atDate, values)
            obj.date = atDate;
            obj.expandedUniverse = values;
        end
    end
    
    
end

