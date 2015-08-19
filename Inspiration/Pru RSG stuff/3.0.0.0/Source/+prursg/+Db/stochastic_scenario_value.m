classdef stochastic_scenario_value < prursg.Db.TableDefinition
    
    properties
        ssv_scenario_set_id
        ssv_scenario_id  
        ssv_risk_factor_id 
        output_number 
        monte_carlo_number
        ssv_value 
    end
    
    
    methods                                               
        % delete all values per given scenario_id
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where ssv_scenario_id=%d', obj.getTableName(), obj.ssv_scenario_set_id) ...
            );
            close(q);
        end            
    end
end

