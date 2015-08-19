classdef IAraReportDAO < handle        
    % ARA Report DAO interface.
    properties
    end
    
    methods(Abstract)
        data = Load(obj)
    end
    
end

