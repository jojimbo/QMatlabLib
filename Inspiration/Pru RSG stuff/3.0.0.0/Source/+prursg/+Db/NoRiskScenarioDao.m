classdef NoRiskScenarioDao
    % persist the no risk Scenarios and their expandedUniverses in tables
    % scenario and noRisk_scenario_values.
    
    methods (Static)
        function insert(dao, scenarios, scenarioSetId, riskNameToIdResolver)
            for i = 1:numel(scenarios)                
                insertScenario(dao, scenarios(i), scenarioSetId, riskNameToIdResolver);
            end
        end
        
        % riskNameToAxisResolver = map<riskrequired to build the 
        function scenario = read(dao, scenarioSetId, riskNameToAxisResolver)
            sql = sprintf(...
                'select * from scenario where s_scenario_set_id = %d and scen_name=''__noriskscr'' order by SCEN_STEP, scenario_id ' ...
                , scenarioSetId ...
            );
            scenario=[];
            dbRows = dao.select(sql);
            if(~isempty(dbRows))
                dbRow = dbRows(1, :);
                scenario = readScenario(dao, dbRow, riskNameToAxisResolver);
                scenario.isNoRiskScenario = 1;
            end
        end
    end
         
end

function scenario = readScenario(dao, dbRow, riskNameToAxisResolver)
    scenario = prursg.Engine.Scenario();
    scenario.name = dbRow{3};
    scenario.scen_step  = dbRow{4};
    scenario.date  = prursg.Db.Dto.toDate(dbRow{5});
    scenario.number  = dbRow{6};
    scenario.expandedUniverse = readExpandedUniverse( ...
        dao, dbRow{1}, scenario.date, riskNameToAxisResolver ...
    );    
end


function eu = readExpandedUniverse(dao, scenario_id, scenario_date, riskNameToAxisResolver)
    eu = containers.Map();
    sql = sprintf('select r.risk_factor_id, r.risk_factor_name, v.output_number, v.nsv_value from risk_factor r, norisk_scenario_value v where v.nsv_scenario_id=%d and r.risk_factor_id = v.nsv_risk_factor_id order by v.nsv_risk_factor_id, v.output_number', scenario_id);
    dbData = dao.select(sql);
    %
    nRows = size(dbData, 1);
    
    currentRiskId = -1; % guaranteed no such risk id exists            
    values = [];
    if nRows > 0
        currentRiskId = dbData{1, 1};
    end            
    for i = 1:nRows  
        riskId = dbData{i, 1};
        if riskId ~= currentRiskId                    
            deserialiseScenarioValues(dbData{i - 1, 2});
            values = dbData{i, 4};                    
            currentRiskId = riskId;
        else
            values = [values dbData{i, 4} ]; %#ok<AGROW>
        end
    end
    if nRows > 0
        deserialiseScenarioValues(dbData{end, 2});
    end
    
    function deserialiseScenarioValues(riskName)
        dataSeries = prursg.Engine.DataSeries();
        dataSeries.dates = scenario_date;
        dataSeries.axes = riskNameToAxisResolver(riskName);
        dataSeries.values = { ...
            prursg.Engine.HyperCube.deserialise(dataSeries.axes, values) ...
        };    
        eu(riskName) = dataSeries;            
    end
end

%=== insert
function insertScenario(dao, scenario, scenarioSetId, riskNameToIdResolver)
    s = prursg.Db.scenario(scenario);
    s.scenario_id = dao.getNextId(s); % PK
    s.s_scenario_set_id = scenarioSetId; % FK
    dao.insert(s);
    % and the lovely values
    insertExpandedUniverse(...
        dao.connection, scenario.expandedUniverse, s.scenario_id, riskNameToIdResolver ...
    );
end

% THE VALUES ARE STORED IN THE ORDER OF THE EXPANDEDUNIVERSE!
function insertExpandedUniverse(connection, expandedUniverse, scenario_id, riskNameToIdResolver)
    data = cell(...
        prursg.Engine.Scenario.getExpandedUniverseSize(expandedUniverse), 4 ...
    );
    riskNames = keys(expandedUniverse);
    tableRow = 1;
    for i = 1:numel(riskNames)
        if ~isKey(riskNameToIdResolver, riskNames{i})
        end
        riskId = riskNameToIdResolver(riskNames{i});
        values = expandedUniverse(riskNames{i});
        values = values.values{1};
        values = prursg.Engine.HyperCube.serialise(values);
        for j = 1:numel(values)
           data{tableRow, 1} = scenario_id;
           data{tableRow, 2} = riskId;
           data{tableRow, 3} = j; % output_number
           data{tableRow, 4} = prursg.Util.ConvertScenarioValue(values(j)); 
           tableRow = tableRow + 1;
        end                
    end
    %
    nsv = prursg.Db.norisk_scenario_value();
    prursg.Db.rsg_fastinsert(connection, nsv.getTableName(), nsv.getTableColumnNames(), data);
end
