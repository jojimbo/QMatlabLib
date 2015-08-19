function TestDatetimePersistence()    
    clc;
    clear
    tic;
    conn = makeConnection();
    createTable(conn);
    xmlString = insertData(conn);
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
    drop = 'DROP TABLE "BLOB_TEST"';
    close(exec(conn, drop));
    create = 'create table BLOB_TEST (id varchar2(30) primary key, job_start date)';
    close(exec(conn, create));
end

function str = insertData(conn)
    columns = { 'id', 'job_start'};
    dateStr = now;
    %dateStr = '{ts ''2002-10-03 22:12:44''}';
    data = { 'Cucolanka!', dateStr }; 
    fastinsert(conn, 'BLOB_TEST', columns, data);
    str = '';
end

function readData(conn, originalString)
    q = exec(conn,'SELECT * FROM blob_test');
    q = fetch(q);
    [ rows(q) cols(q)]
    t = q.Data{2};
    whos t;
    disp(t);
    %blob = q.Data{2};
    close(q);
end

