classdef scenario_set < prursg.Db.Dto
    
    properties
        scenario_set_id
        ss_rsg_job_id
        scenario_set_name
        scenario_set_type
        scenario_type_key
        sess_date        
        number_of_chunks
    end
    
    methods (Static)
        function sset = getScenarioSetByName(dao, name)
            sset = prursg.Db.scenario_set();
            sset.scenario_set_name = name;
            sset = dao.read(sset);            
        end        
    end
        
    
    methods

        function set.sess_date(obj, t)
            obj.sess_date = obj.floorToSecond(t);
        end
        
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where scenario_set_name=''%s''', obj.getTableName(), obj.scenario_set_name) ...
            );
            close(q);
        end
        
        % search by natural key
        function obj = read(obj, connection)
            sqlSelect = sprintf('select * from %s where scenario_set_name=''%s''', obj.getTableName(), obj.scenario_set_name);
            obj.selectAndPopulateProperties(connection, sqlSelect)
        end

        function id = getNaturalKey(obj)
            id = obj.scenario_set_name;
        end
        
    
    end
end

