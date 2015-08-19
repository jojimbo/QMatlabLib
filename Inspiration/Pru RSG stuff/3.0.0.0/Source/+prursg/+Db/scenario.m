classdef scenario < prursg.Db.Dto
    
    properties
        scenario_id
        s_scenario_set_id
        scen_name
        scen_step
        scen_date
        scen_number
        is_stochastic % 'N' - deterministic scenario, 'Y' - stochastic scenario        
        is_shockedBase
    end
        
    methods (Static)
        function id = getStochasticScenarioId(dao, scenarioSetId)
            sql = sprintf('select scenario_id from scenario where s_scenario_set_id = %d and is_stochastic = ''Y''' ...
                        , scenarioSetId);
            data = dao.select(sql);            
            if numel(data) == 1
                id = data{1};
            else
                id = data;
            end
        end
    end
    
    methods
        
        function obj = scenario(varargin)
            %optional initialisation with a prursg.Engine.Scenario object
            if(numel(varargin) == 1)
                s = varargin{1};
                obj.scen_name = s.name;
                obj.scen_step = s.scen_step;
                obj.scen_date = s.date;
                obj.scen_number = s.number;
            end
            obj.is_stochastic = 'N';
            obj.is_shockedBase = 0;
        end
        
        function set.scen_date(obj, t)
            obj.scen_date = obj.floorToSecond(t);
        end
           
        function delete(obj, connection)
            q = exec(connection, ...
                sprintf('delete from % where scenario_id=%d', obj.getTableName(), obj.scenario_id) ...
            );
            close(q);
        end
        
        % search by natural key
        function obj = read(obj, connection)
            sqlSelect = sprintf('select * from %s where scenario_id=%d order by SCEN_STEP', obj.getTableName(), obj.scenario_id);
            obj.selectAndPopulateProperties(connection, sqlSelect)
        end
                                       
    end
end

