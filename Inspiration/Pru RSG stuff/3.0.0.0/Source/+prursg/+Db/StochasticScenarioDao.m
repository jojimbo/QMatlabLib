classdef StochasticScenarioDao
    % persist the stochastic Scenarios(the chunks) in tables
    % scenario and stochastic_scenario_values.
    
    methods (Static)
        
        % insert scenario        
        function scenario_id = insertScenario(dao, scenarioObj, scenarioSetId)
            ss = prursg.Db.scenario(scenarioObj);
            ss.is_stochastic = 'Y';
            ss.scenario_id = dao.getNextId(ss);
            ss.s_scenario_set_id = scenarioSetId;
            dao.insert(ss);    
            scenario_id = ss.scenario_id;
        end
                
        
        % insert stochastic scenario values.        
        function insertSSV(monteCarloNumber, dao, risks, chunk, scenarioSetId, scenarioId, riskNameToIdResolver)                        
            ssv = prursg.Db.stochastic_scenario_value();
            ssv.ssv_scenario_set_id = scenarioSetId;
            ssv.ssv_scenario_id = scenarioId;
            
            ssv.monte_carlo_number = monteCarloNumber;
            
            insertChunk(...
                dao.connectionInfo, ssv, risks, chunk, riskNameToIdResolver...
            );                        
        end
        
        % chunks is a cell array of cell arrays of risks stochastic outputs
        % risks - give the order of results within a chunk
        function insert(dao, scenarioObj, risks, chunks, scenarioSetId, riskNameToIdResolver)
            ss = prursg.Db.scenario(scenarioObj);
            ss.is_stochastic = 'Y';
            ss.scenario_id = dao.getNextId(ss);
            ss.s_scenario_set_id = scenarioSetId;
            dao.insert(ss);            
            %
            ssv = prursg.Db.stochastic_scenario_value();
            ssv.ssv_scenario_id = ss.scenario_id;
            ssv.monte_carlo_number = 0;
            for i = 1:size(chunks, 1)
                ssv = insertChunk(...
                    dao.connectionInfo, ssv, risks, chunks{i}, riskNameToIdResolver...
                );
                ssv.monte_carlo_number = ssv.monte_carlo_number + size(chunks{i}{1}, 1);
            end
        end

        % Read a chunk of the stochastic outputs of a stochastic scenario
        % identified by stochasticScenarioId, starting fromMcNumber sample up to
        % and includin toMcNumber monte carlo sample.
        % The chunk is a cell array, each cell having the mc samples of one
        % risk driver. The ordering of the cells in the chunk, follows the
        % ordering in riskIds, which contains the risks identifiers taken from 
        % risk_factor.risk_factor_id
        %
        %
        function chunk = readChunk(dao, stochasticScenarioId, riskIds, fromMcNumber, toMcNumber)
            chunk = cell(1, numel(riskIds));
            sql = sprintf(['select output_number, ssv_value from stochastic_scenario_value ' ...
                           ' where ssv_scenario_id = %d and ssv_risk_factor_id = %s ' ...
                           ' and monte_carlo_number between %d and %d order by output_number, monte_carlo_number' ], ...
                           stochasticScenarioId, '%d', fromMcNumber, toMcNumber);                       
            for i = 1:numel(riskIds)
                 chunk(i) = { readRiskStochasticOutputs(dao, sql, riskIds(i)) };                 
            end            
        end
        
        function chunks = readChunks(connection, batchId, stochasticScenarioSetId, riskIds)
            chunks = cell(1, numel(riskIds));
            
            javaDao = db.StochasticSamples();
            javaDao.Connect(connection.url, connection.username, connection.password);

            for i = 1:numel(riskIds)
                disp([ 'batch id-' num2str(batchId) ', risk id-' num2str(riskIds(i)) ]);
                chunks(i) = { readRiskStochasticOutputsJava(javaDao.readStochasticScenarioValues(stochasticScenarioSetId, riskIds(i))) };                                 
            end
            javaDao.Disconnect();
                
        end
        
        function dso = getRiskFactorStochasticValues(dao, riskName, scenarioSetName, varargin)
            dso = [];
            sset = prursg.Db.scenario_set.getScenarioSetByName(dao, scenarioSetName);            
            risk = prursg.Db.risk_factor.getRiskFactorByName(dao, riskName);
            if isempty(sset) || isempty(risk)
                return;
            end
            % one single stochastic scenario per scenario set
            stochasticScenarioId = prursg.Db.scenario.getStochasticScenarioId(dao, sset.scenario_set_id);                        
            if isempty(stochasticScenarioId)
                return;
            end
            %
            switch numel(varargin)
                case 2                    
                    fromMcNumber = varargin{1}; toMcNumber = varargin{2};
                case 0
                    fromMcNumber = 1; 
                    toMcNumber = getNumberOfMonteCarloRuns(dao, stochasticScenarioId, risk.risk_factor_id);
                otherwise
                    error('wrong number of optional varargin arguments')
            end
            chunk = prursg.Db.StochasticScenarioDao.readChunk( ...
                dao, stochasticScenarioId, risk.risk_factor_id, fromMcNumber, toMcNumber ...
            );
            if ~isempty(chunk)
                dso = prursg.Engine.DataSeries();
                dso.axes = prursg.Db.AxisDao.read(dao, sset.scenario_set_id, risk.risk_factor_id);
                %
                dso.dates = (fromMcNumber : toMcNumber);
                %                
                outputs = chunk{1};
                nRows = size(outputs, 1);
                dso.values = cell(1,  nRows);
                for i = 1:nRows
                    dso.values{i} = prursg.Engine.HyperCube.deserialise(dso.axes, outputs(i, :));
                end
            end
            
        end
        
        
        function scenarios = read(dao, scenarioSetId, riskNameToAxisResolver)
            sql = sprintf(...
                'select * from scenario where s_scenario_set_id = %d and is_stochastic=''Y'' order by SCEN_STEP, scenario_id ' ...
                , scenarioSetId ...
            );
            dbRows = dao.select(sql);
            scenarios = [];
            for i = 1:size(dbRows, 1)
                dbRow = dbRows(i, :);
                scenario = readScenario(dao, dbRow, riskNameToAxisResolver);
                scenario.isStochasticScenario = 1;
                scenarios = [scenarios scenario];
            end
        end  
        
        function eu = readExpandedUniverse(dao, scenario_set_id, scenario_id, scenario_date, riskNameToAxisResolver)
            eu = containers.Map();
            sql = sprintf('select r.risk_factor_id, r.risk_factor_name, v.output_number, v.ssv_value from risk_factor r, stochastic_scenario_value v where v.ssv_scenario_set_id = %d and v.ssv_scenario_id=%d and r.risk_factor_id = v.ssv_risk_factor_id order by v.ssv_risk_factor_id, v.output_number', scenario_set_id, scenario_id);
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



    end         
end

function stochasticOutputs = readRiskStochasticOutputs(dao, sql, riskId)
     data = cell2mat(dao.select(sprintf(sql, riskId)));
     nOutputs = numel(unique(data(:, 1)));
     nMcSamples = size(data, 1) / nOutputs;
     assert(isNatural(nMcSamples));

     stochasticOutputs = zeros(nMcSamples, nOutputs);
     for i = 1:nOutputs
         endRow = i * nMcSamples;
         stochasticOutputs(:, i) = data(endRow - nMcSamples + 1 : endRow, 2);
     end                 
end

function stochasticOutputs = readRiskStochasticOutputsJava(data)
     %data = cell2mat(data);
     nOutputs = numel(unique(data(:, 1)));
     nMcSamples = size(data, 1) / nOutputs;
     assert(isNatural(nMcSamples));

     stochasticOutputs = zeros(nMcSamples, nOutputs);
     for i = 1:nOutputs
         endRow = i * nMcSamples;
         stochasticOutputs(:, i) = data(endRow - nMcSamples + 1 : endRow, 2);
     end                 
end

function yesNo = isNatural(n)
    yesNo = (n == round(n));
end

% ssv holds the current monte carlo number
function ssv = insertChunk(connection, ssv, risks, chunk, riskNameToIdResolver)

    javaDao = db.StochasticSamples();
    javaDao.Connect(connection.url, connection.username, connection.password);
        
    for i = 1:numel(risks)
        ssv.ssv_risk_factor_id = riskNameToIdResolver(risks(i).name);
        
        ssv = splitInsert(javaDao, ssv, chunk{i}, 1000000);
        %ssv = insertStochasticOutputs(connection, ssv, chunk{i});
    end
    javaDao.Disconnect();
end

function ssv = splitInsert(javaDao, ssv, outputs, maxBatchInsertSize)
    rowsPerBatch = round(maxBatchInsertSize / size(outputs, 2));
    nRows = size(outputs, 1);
    oldMcn = ssv.monte_carlo_number;
    startRow = 1;
    while startRow <= nRows
        endRow = min(startRow + rowsPerBatch - 1, nRows);
        %ssv = insertStochasticOutputs(connection, ssv, outputs(startRow:endRow, :));        
        javaBulkInsertStochasticOutputs(javaDao, ssv, outputs(startRow:endRow, :));        
        ssv.monte_carlo_number = ssv.monte_carlo_number + rowsPerBatch;
        startRow = startRow + rowsPerBatch;        
    end
    ssv.monte_carlo_number = oldMcn;
end

function javaBulkInsertStochasticOutputs(javaDao, ssv, outputs)    
        
     data = zeros(numel(outputs), 5);        
     data(:, 1) = ssv.ssv_scenario_id;
     data(:, 2) = ssv.ssv_risk_factor_id;
     output_numbers = [1:size(outputs, 2)];
     output_numbers = repmat(output_numbers, size(outputs, 1), 1);
     output_numbers = output_numbers';
     output_numbers = reshape(output_numbers, [], 1);
     data(:, 3) = output_numbers;
     mc_numbers = [ssv.monte_carlo_number + 1:ssv.monte_carlo_number + size(outputs, 1)]';
     mc_numbers = repmat(mc_numbers, 1, size(outputs, 2));    
     mc_numbers = reshape(mc_numbers', [], 1);
     data(:, 4) = mc_numbers;     
     data(:, 5) = prursg.Util.ConvertScenarioValue(reshape(outputs', [], 1));
     
     
    
                       
    sqlInsert = java.lang.String( ...    
        ['insert into stochastic_scenario_value ' ... 
          ' (ssv_scenario_set_id, ssv_scenario_id, ssv_risk_factor_id, output_number, monte_carlo_number, ssv_value)' ...
          ' values(?, ?, ?, ?, ?, ?)' ] ...
    );

    javaDao.insert(sqlInsert, ssv.ssv_scenario_set_id, data);
    
end


function ssv = insertStochasticOutputs(connection, ssv, outputs)    
    data = cell(numel(outputs), 5);
    tableRow = 1;
        
    for i = 1:size(outputs, 1)
        for output_number = 1:size(outputs, 2);
            data{tableRow, 1} = ssv.ssv_scenario_id;
            data{tableRow, 2} = ssv.ssv_risk_factor_id;
            data{tableRow, 3} = output_number;
            data{tableRow, 4} = ssv.monte_carlo_number + i;
            data{tableRow, 5} = prursg.Util.ConvertScenarioValue(outputs(i, output_number));
            tableRow = tableRow + 1;
        end
    end
    prursg.Db.rsg_fastinsert(connection, ssv.getTableName(), ssv.getTableColumnNames(), data);
end


function nMcRuns = getNumberOfMonteCarloRuns(dao, stochasticScenarioId, risk_factor_id)
    sql = [ 'select max(MONTE_CARLO_NUMBER) from STOCHASTIC_SCENARIO_VALUE ' ...
            'where SSV_SCENARIO_ID = %d and SSV_RISK_FACTOR_ID = %d ' ];
    data = dao.select(sprintf(sql, stochasticScenarioId, risk_factor_id));
    nMcRuns = 0;
    if ~isempty(data)
        nMcRuns = data{1};
    end
end

function scenario = readScenario(dao, dbRow, riskNameToAxisResolver)
    scenario = prursg.Engine.Scenario();
    scenario.id = dbRow{1};
    scenario.name = dbRow{3};
    scenario.scen_step  = dbRow{4};
    scenario.date  = prursg.Db.Dto.toDate(dbRow{5});
    scenario.number  = dbRow{6};            
end

