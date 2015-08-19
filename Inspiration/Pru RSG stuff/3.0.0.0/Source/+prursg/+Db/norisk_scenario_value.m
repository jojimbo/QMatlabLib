classdef norisk_scenario_value < prursg.Db.TableDefinition
    
    properties
        nsv_scenario_id 
        nsv_risk_factor_id
        output_number
        nsv_value
    end
    
    
    methods
                                                
        % delete all values per given scenario_id
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where nsv_scenario_id=%d', obj.getTableName(), obj.dsv_scenario_id) ...
            );
            close(q);
        end
            
    end
end

