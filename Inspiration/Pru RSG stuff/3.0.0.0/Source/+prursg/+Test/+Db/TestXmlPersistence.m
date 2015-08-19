function TestXmlPersistence()    
    clc;
    clear
    tic;
    conn = makeConnection();
    createTable(conn);
    xmlString = insertData(conn);
    readData(conn, xmlString);
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
    create = 'create table BLOB_TEST (id varchar2(30) primary key, raw_output blob)';
    close(exec(conn, create));
end

function str = insertData(conn)

    dom = xmlread('model-file.xml');
    str = prursg.Xml.XmlTool.toString(dom, true);
    rawOutput = unicode2native(str);
    columns = { 'id', 'raw_output'};
    data = { 'Cucolanka!', rawOutput }; 
    fastinsert(conn, 'BLOB_TEST', columns, data);

end

function readData(conn, originalString)
    q = exec(conn,'SELECT * FROM blob_test');
    q = fetch(q);
    [ rows(q) cols(q)]
    blob = q.Data{2};
    binary = blob.getBytes(1, blob.length());
    str = native2unicode(binary);
    assert(isequal(str', originalString)); 
    close(q);
end

