function TestBlob()    
    clc;
    clear

    dbl = 0:0.2:1;
    bs = typecast(dbl,'uint8');
    dbl2 = typecast(bs, 'double');
    assert(isequal(dbl, dbl2));
    
    % write speed
    conn = makeConnection();
    createTable(conn);
    tic;
    insertData(conn);
    close(conn);
    toc;
    
    % read spead
    conn = makeConnection();
    tic;
    readData(conn);
    close(conn);
    toc;
end

function conn = makeConnection()
    conn = database('c0224','RSG','RSG','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@c0224:1521:');
    set(conn, 'autocommit', 'off');    
    get(conn, 'autocommit'); 
    ping(conn);
end

function createTable(conn)
    drop = 'DROP TABLE "BLOB_TEST"';
    exec(conn, drop);
    create = 'create table BLOB_TEST (id varchar2(30) primary key, raw_output blob)';
    exec(conn, create);
end

function insertData(conn)

    dbls = 1:4900000; 
    rawOutput = typecast(dbls, 'uint8');
    %numel(rawOutput)
    columns = { 'id', 'raw_output'};
    data = { 'Cucolanka!', rawOutput }; 
    fastinsert(conn, 'BLOB_TEST', columns, data);
end

function readData(conn)
    q = exec(conn,'SELECT * FROM blob_test');
    q = fetch(q);
    blob = q.Data{2};
    binary = blob.getBytes(1, blob.length());
    numel(binary);
    dbls = typecast(binary, 'double');    
    assert(isequal(dbls, (1:4900000)'));
    close(q);
end

