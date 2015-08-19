function TestDatetimePersistence()    
    clc;
    clear
    tic;
    conn = makeConnection();
    createTable(conn);
    insertData(conn);
    readData(conn, []);
    close(conn);
    toc;
end

function conn = makeConnection()
    conn = database('c0224','RSG','RSG','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@c0224:1521:');
    %conn = database('rsg','','','sun.jdbc.odbc.JdbcOdbcDriver','jdbc:odbc:');
    get(conn, 'autocommit')
    ping(conn);
end

function createTable(conn)
    drop = 'DROP TABLE "BIN_DOUBLE_TEST"';
    q = exec(conn, drop);
    create = 'create table BIN_DOUBLE_TEST (id varchar2(30) primary key, value binary_double)';
    q = exec(conn, create); close(q);
end

function insertData(conn)
    columns = { 'id', 'value'};
    value = 2e-300;
    data = { 'Cucolanka!', value }; 
    prursg.Db.rsg_fastinsert(conn, 'BIN_DOUBLE_TEST', columns, data);    
end

function readData(conn, originalString)
    q = exec(conn,'SELECT * FROM BIN_DOUBLE_TEST');
    q = fetch(q);
    [ rows(q) cols(q)]
    t = q.Data{2};
    whos t;
    disp(t);
    %blob = q.Data{2};
    close(q);
end

