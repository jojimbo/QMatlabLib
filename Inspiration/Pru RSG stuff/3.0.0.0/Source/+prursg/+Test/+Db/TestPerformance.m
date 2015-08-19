function TestPerformance()    
    clc;
    clear;
    prursg.Xml.configureJava(true);
    for i = 1:5
        runOnePass(i);
    end
end


function runOnePass(passNumber)
    fprintf('run %d\n', passNumber);
    
    conn = makeConnection();
    
    dropTables(conn)   
    
    createTables(conn);
    
    nSimulations = 100;
    nSamples = 700 * 7 * nSimulations;

    tic;
    insertScenarioSet(conn, 1);
    insertRiskDrivers(conn, 700);
    %insertSamples2(conn, 1, 700, 7, nSimulations);
    bulkInsertSamples(conn, 1, 700, 7, nSimulations);
    commit(conn);

    t = toc;
    speed = nSamples / t;
    close(conn);
    
    fprintf('writing %d samples takes %f seconds speed is %f samples/second \n', nSamples, t, speed);    
    
    conn = makeConnection();
    tic;
    readSamples(conn, 1);
    t = toc;
    speed = nSamples / t;
    fprintf('reading %d samples takes %f seconds speed is %f samples/second \n', nSamples, t, speed);
    close(conn);
end


function bulkInsertSamples(conn, setId, nRisks, nOutputs, nSamples) 
    sqlInsert = java.lang.String( ...
        [ 'insert into mc_sample (scenario_set_id, risk_factor_id, output_number, mc_number, sample)' ...
          ' values(?, ?, ?, ?, ?)' ] ...
    );
    bulk = zeros(nOutputs * nSamples, 5);
    for i = 1:nRisks
        row = 1;
        for j = 1:nOutputs
            for k = 1:nSamples
                bulk(row, 1) = setId;
                bulk(row, 2) = i;     % risk factor id
                bulk(row, 3) = j;     % risk factor output number
                bulk(row, 4) = k;     % monte carlo run
                bulk(row, 5) = k * j; % sample
                row = row + 1;
            end
        end
        db.StochasticSamples.insert(conn.Handle, sqlInsert, bulk);
    end
end


function insertSamples(conn, setId, nRisks, nOutputs, nSamples)        
    sql = ['insert into mc_sample (scenario_set_id, risk_factor_id, output_number, ' ...
           'mc_number, sample) values(?, ?, ?, ?, ?)' ];
    jdbcConn = conn.Handle;
    for i = 1:nRisks        
        pst = jdbcConn.prepareStatement(sql);
        for j = 1:nOutputs
            for k = 1:nSamples
                pst.setInt(1, setId);
                pst.setInt(2, i);
                pst.setInt(3, j);
                pst.setInt(4, k);
                pst.setBinaryDouble(5, k * j);
                pst.addBatch();                
            end
        end
        pst.executeBatch();
        pst.close();
       % disp(i);
    end
end

function insertSamples2(conn, setId, nRisks, nOutputs, nSamples)
    cols = { 'scenario_set_id', 'risk_factor_id', 'output_number', 'mc_number', 'sample' };
    data = cell(nOutputs * nSamples, 5);
    for i = 1:nRisks
        r = 1;
        for j = 1:nOutputs
            for k = 1:nSamples
                data{r, 1} = setId; data{r, 2} = i; data{r,3} = j; data{r, 4} = k;
                data{r, 5} = k * j;
                r = r + 1;
            end
        end
        %disp(i);
        prursg.Db.rsg_fastinsert(conn,'mc_sample', cols, data);        
    end
end

function readSamples(conn, setId)
    sql = sprintf('select * from mc_sample where scenario_set_id = %d order by risk_factor_id, output_number, mc_number', setId);
    q = exec(conn, sql);
    q = fetch(q);    
    resultset = q.Data;
    samples = zeros(1, size(resultset, 1));
    for i = 1:numel(samples)
        samples(i) = resultset{i, 5};
    end        
    close(q);
end

function insertRiskDrivers(conn, maxId)
    data = cell(maxId, 2);
    for i = 1:maxId
        data{i, 1} = i; data{i, 2} = ['nice risk ' num2str(i)];
    end
    cols = { 'id', 'name' };
    prursg.Db.rsg_fastinsert(conn,'risk_factor', cols, data);
end

function insertScenarioSet(conn, id)
    data = { id, 'nice set' };
    cols = { 'id', 'name' };
    prursg.Db.rsg_fastinsert(conn,'scenario_set', cols, data);
end


function createTables(conn) 
     create = {
        ['create table scenario_set ( id integer, name varchar2(255), ' ...
         ' CONSTRAINT pk_scenario_set PRIMARY KEY (id), CONSTRAINT nk_scenario_set UNIQUE (name))'], ...

        ['create table risk_factor ( id integer, name varchar2(255), ' ...
        'CONSTRAINT pk_risk_factor PRIMARY KEY (id), CONSTRAINT nk_risk_factor UNIQUE (name))'], ...

        ['create table mc_sample (scenario_set_id integer, risk_factor_id integer, ' ...
        ' output_number integer, mc_number integer, sample binary_double, ' ...
        ' CONSTRAINT pk_mc_sample PRIMARY KEY (scenario_set_id, risk_factor_id, output_number, mc_number),' ...
        ' CONSTRAINT fk_scenario_set_id FOREIGN KEY (scenario_set_id) REFERENCES scenario_set(id) ON DELETE CASCADE, ' ...
        ' CONSTRAINT fk_risk_factor_id FOREIGN KEY (risk_factor_id) REFERENCES risk_factor(id) ON DELETE CASCADE)' ...
        ' ORGANIZATION INDEX' ] ...
    };
    execSql(conn, create);
end

function conn = makeConnection()
    conn = database('c0224','RSG','RSG','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@c0224:1521:');
    get(conn, 'autocommit');
    set(conn, 'autocommit', 'off');
    ping(conn);
end


function execSql(conn, sql)
    for i = 1:numel(sql)        
        q = exec(conn, sql{i});     
    end
end

function dropTables(conn) 
    drop = [ ...
        {'drop table mc_sample'}, {'drop table scenario_set'}, {'drop table risk_factor'} ...
    ];
    execSql(conn, drop);
end	

