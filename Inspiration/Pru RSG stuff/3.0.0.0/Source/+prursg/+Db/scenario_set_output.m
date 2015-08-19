classdef scenario_set_output < prursg.Db.Dto
    
    properties        
        sso_scenario_set_id
        chunk_id 
        chunk       
    end
    
    methods
                        
        function obj = read(obj, connection)
            sqlSelect = sprintf('select * from %s where sso_scenario_set_id=%d and chunk_id = %d', ...
                obj.getTableName(), obj.sso_scenario_set_id, obj.chunk_id ...
            );
            obj.selectAndPopulateProperties(connection, sqlSelect);            
        end
        
        function delete(obj, connection)
            q = exec(connection, sprintf('delete from %s where sso_scenario_set_id = %d and chunk_id=%d', ...
                obj.getTableName(), obj.sso_scenario_set_id, obj.chunk_id)...
            );
            close(q);
        end
                       
        % optionally convert blobs to byte arrays
        function set.chunk(obj, value)
            if strcmp(class(value), 'uint8')
                obj.chunk = value;
            else
                obj.chunk = obj.getBytes(value);
            end
        end
        
        function id = getNaturalKey(obj)
            id = sprintf('set id: %d chunk_id: %d', obj.sso_scenario_set_id, obj.chunk_id);
        end
        
    end
        
end

