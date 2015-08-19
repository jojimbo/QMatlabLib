classdef deterministic_scenario_value < prursg.Db.TableDefinition
    
    properties
        dsv_scenario_id 
        dsv_risk_factor_id
        output_number
        dsv_value
    end
    
    
    methods
                                                
        % delete all values per given scenario_id
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where dsv_scenario_id=%d', obj.getTableName(), obj.dsv_scenario_id) ...
            );
            close(q);
        end
            
    end
end

