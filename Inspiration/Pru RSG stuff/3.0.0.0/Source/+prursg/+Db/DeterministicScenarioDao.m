classdef DeterministicScenarioDao
    % persist the deterministic Scenarios and their expandedUniverses in tables
    % scenario and deterministic_scenario_values.
    
    methods (Static)
        function insert(dao, scenarios, scenarioSetId, riskNameToIdResolver)
            for i = 1:numel(scenarios)                
                insertScenario(dao, scenarios(i), scenarioSetId, riskNameToIdResolver);
            end
        end
        
        % riskNameToAxisResolver = map<riskrequired to build the 
        function scenarios = read(dao, scenarioSetId, riskNameToAxisResolver)
            sql = sprintf(...
                'select * from scenario where s_scenario_set_id = %d and is_stochastic=''N'' and scen_name<>''__noriskscr'' order by SCEN_STEP, scenario_id ' ...
                , scenarioSetId ...
            );
            dbRows = dao.select(sql);
            scenarios = [];
            for i = 1:size(dbRows, 1)
                dbRow = dbRows(i, :);
                scenario = readScenario(dao, dbRow, riskNameToAxisResolver);
                scenarios = [scenarios scenario];
            end
        end
                
        
        function dso = getRiskFactorDeterministicValues(dao, riskName, scenarioSetName)
            sset = prursg.Db.scenario_set.getScenarioSetByName(dao, scenarioSetName);            
            risk = prursg.Db.risk_factor.getRiskFactorByName(dao, riskName);
            dso = [];
            
            if ~isempty(sset) && ~isempty(risk)
                % 
                dso = prursg.Engine.DataSeries();
                dso.axes = prursg.Db.AxisDao.read(dao, sset.scenario_set_id, risk.risk_factor_id);
                %
                scenarios = getDeterministicScenarios(dao, sset.scenario_set_id); % id, date
                nRows = size(scenarios, 1);
                dso.dates = zeros(1, nRows);
                dso.values = cell(1, nRows);
                for i = 1:nRows
                    dso.dates(i) = prursg.Db.Dto.toDate(scenarios{i, 2});
                    dso.values(i) = { readRiskCube(dao, risk.risk_factor_id, scenarios{i, 1}, dso.axes) };
                end
            end
        end
 
        
    end
         
end

function id_and_date = getDeterministicScenarios(dao, scenarioSetId)
    sql = [ 'select scenario_id, scen_date from SCENARIO ' ...
            'where S_SCENARIO_SET_ID = %d and IS_STOCHASTIC = ''N'' ' ...
            'order by scenario_id'];
    id_and_date =  dao.select(sprintf(sql, scenarioSetId));    
end

function cube = readRiskCube(dao, riskId, scenarioId, axes)
    sql = [ 'select dsv_value from DETERMINISTIC_SCENARIO_VALUE ' ...
            'where DSV_SCENARIO_ID = %d and dsv_risk_factor_id = %d ' ...
            'order by output_number '];
    cube = cell2mat(dao.select(sprintf(sql, scenarioId, riskId)));
    cube = prursg.Engine.HyperCube.deserialise(axes, cube);
end

function scenario = readScenario(dao, dbRow, riskNameToAxisResolver)
    scenario = prursg.Engine.Scenario();
    scenario.name = dbRow{3};
    scenario.scen_step  = dbRow{4};
    scenario.date  = prursg.Db.Dto.toDate(dbRow{5});
    scenario.number  = dbRow{6};
    scenario.isShockedBase = dbRow{8};
    scenario.expandedUniverse = readExpandedUniverse( ...
        dao, dbRow{1}, scenario.date, riskNameToAxisResolver ...
    );
end

function eu = readExpandedUniverse(dao, scenario_id, scenario_date, riskNameToAxisResolver)
    eu = containers.Map();
    sql = sprintf('select r.risk_factor_id, r.risk_factor_name, v.output_number, v.dsv_value from risk_factor r, deterministic_scenario_value v where v.dsv_scenario_id=%d and r.risk_factor_id = v.dsv_risk_factor_id order by v.dsv_risk_factor_id, v.output_number', scenario_id);
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
    s.is_shockedBase = scenario.isShockedBase;
    dao.insert(s);
    % and the lovely values
    insertExpandedUniverse(...
        dao.connection, scenario.expandedUniverse, s.scenario_id, riskNameToIdResolver ...
    );
end

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
    dsv = prursg.Db.deterministic_scenario_value();
    prursg.Db.rsg_fastinsert(connection, dsv.getTableName(), dsv.getTableColumnNames(), data);
end



