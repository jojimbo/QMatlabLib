classdef validation_schedule < prursg.Db.TableDefinition
    
    properties
        vs_scenario_set_id 
        line_number 
        ruleset_name 
        validation_item 
        validation_measure 
        validation_value 
    end
    
    methods        
        function str = getNaturalKey(obj)
            str = sprintf(' set_id: %d', obj.vs_scenario_set_id);
        end    
    end
    
    
    methods (Static)
        
        % scenarioSetId can be either ScenarioSet Natural Key(scenario_set.scenario_set_name), or Scenario
        % Set(scenario_set.scenario_set_id)
        % data is a cell array each row being:
        %    {'ruleset_name' }, {'validation_item'}, {'validation_measure'}, { validation_value } 
        function storeValidationSchedule(dao, batchIndex, scenarioSetIdOrName, data)
            v = prursg.Db.validation_schedule();
            nRows = size(data, 1);
            scenarioSetId = { locateScenarioSetId(dao, scenarioSetIdOrName) };            
            dbData = [ repmat(scenarioSetId, nRows, 1) num2cell((batchIndex * 100000 + (1:nRows))') data ];
            prursg.Db.rsg_fastinsert(dao.connection, v.getTableName(), v.getTableColumnNames(), dbData);    
        end
        
        % dao - instance of RsgDao object
        % scenarioSetId can be either ScenarioSet Natural Key(scenario_set.scenario_set_name), or Scenario
        % Set(scenario_set.scenario_set_id)
        % data is a cell array each row being:
        %    {'ruleset_name' }, {'validation_item'}, {'validation_measure'}, { validation_value } 
        function data = readValidationSchedule(dao, scenarioSetIdOrName)
            v = prursg.Db.validation_schedule();
            id = locateScenarioSetId(dao, scenarioSetIdOrName);
            sql = sprintf('select * from %s where vs_scenario_set_id = %d order by line_number', v.getTableName(), id);
            data = dao.select(sql);
            data = data(:, 3:end);            
        end
    end
    
end

function id = locateScenarioSetId(dao, idOrName)
    if isnumeric(idOrName)
        id = idOrName;
    else
        ss = prursg.Db.scenario_set();
        ss.scenario_set_name = idOrName;
        ss = dao.read(ss);
        id = ss.scenario_set_id;
    end
end
