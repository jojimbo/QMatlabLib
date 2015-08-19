function TestJavaBlob()    
    clc;
    clear
    tic;
    conn = makeConnection();
    createTable(conn);
    testJava(conn.Handle, [tempname '.mat']);
    close(conn);
    toc;
end


function testJava(connection, fileName)
    %a = rand(1, 1024 * 1024 * 20); % 160 megs
    a = rand(1, 10); % 8k
    save(fileName, 'a');
    d = load(fileName);
    assert(isequal(d.a, a));
    % write
    inStream = java.io.BufferedInputStream(java.io.FileInputStream(fileName));
    pst = connection.prepareStatement('insert into BLOB_TEST values(?, ?)');
    pst.setString(1, 'alabalanica');
    pst.setBinaryStream(2, inStream);
    pst.execute();
    pst.close();
    inStream.close();    
    % read back
    delete(fileName);
    outStream = java.io.BufferedOutputStream(java.io.FileOutputStream(fileName));
    pst = connection.prepareStatement('select raw_output from BLOB_TEST where id = ?');
    pst.setString(1, 'alabalanica');
    rst = pst.executeQuery();
    rst.next();
    
    blobStream = java.io.BufferedInputStream(rst.getBinaryStream(1));    
    buffer = cast(zeros(256, 1), 'uint8');    
    %buffer = javaArray('java.lang.Double', 256);
    nBytes = blobStream.read(buffer);
    while nBytes > 0        
        outStream.write(buffer, 0, nBytes - 1);
        nBytes = blobStream.read(buffer);
    end
    outStream.close();
    blobStream.close();
    rst.close();
    pst.close();
    %
    delete(fileName);    
end


function conn = makeConnection()
    conn = database('c0224','RSG','RSG','oracle.jdbc.driver.OracleDriver','jdbc:oracle:thin:@c0224:1521:');
    %conn = database('rsg','','','sun.jdbc.odbc.JdbcOdbcDriver','jdbc:odbc:');
    get(conn, 'autocommit')
    ping(conn);
end

function createTable(conn)
    drop = 'DROP TABLE "BLOB_TEST"';
    exec(conn, drop);
    create = 'create table BLOB_TEST (id varchar2(30) primary key, raw_output blob)';
    exec(conn, create);
end


