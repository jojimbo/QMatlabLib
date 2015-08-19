classdef BaseScenarioShock
    % corresponds to the <shock_base_scenario> xml model file tag
    properties
        name
        date
        shiftCoefficients 
        stretchCoefficients
        manualShiftCoefficients
        floorCoefficients
        multishock %
    end
    
    methods
        function obj = BaseScenarioShock()
            obj.shiftCoefficients = containers.Map(); %map<riskname, shock DataSeries>
            obj.stretchCoefficients = containers.Map(); %map<riskname, stretch DataSeries>
            obj.manualShiftCoefficients = containers.Map(); %map<riskname, stretch DataSeries>
            obj.floorCoefficients = containers.Map(); %map<riskname, stretch DataSeries>
            obj.multishock =containers.Map(); %map<riskname, boolean flag>
        end
    end
    
end

