classdef axis < prursg.Db.TableDefinition
    
    properties
        axis_id
        axis_scenario_set_id 
        axis_risk_factor_id 
        axis_number
        axis_name
    end
    
    methods
        
        function str = getNaturalKey(obj)
            str = sprintf(' set_id: %d risk_id: %d axis_name: %s', ...
                  obj.axis_scenario_set_id, obj.axis_risk_factor_id, obj.axis_name);
        end
    
    end
end

