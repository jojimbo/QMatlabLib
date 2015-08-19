function TestRsgBlobSchema()
    % test the rsg +Blob db schema which uses blobs to preserve rsg output.
    clc;
    clear all;
    dao = prursg.Db.RsgDao('Use blobs, please!');
    dao.beginTransaction();
    dao.dropTables();    
    dao.createTables();
    
    % job bit
    xmldom = xmlread('model-file.xml');
    
    job = prursg.Db.rsg_job();
    job.rsg_job_id = dao.getNextId(job);
    job.job_start = now();
    job.job_end = now();
    job.basecurrency = 'GBP';
    job.xml_model_file = prursg.Xml.XmlTool.toString(xmldom, true);
    job.retain_flag = 'Y';
    job.persist_until = job.job_start + 365 * 10;
    dao.insert(job);
    
    job2 = prursg.Db.rsg_job();
    job2.rsg_job_id = job.rsg_job_id;
    job2 = dao.read(job2);
    datestr(job2.job_start,'dd.mm.yyyy HH:MM:SS.FFF');
    datestr(job2.job_start, 'dd.mm.yyyy HH:MM:SS.FFF');
    assert(isequal(job2, job));    
        
    % insert scenario outputs
    scenarioSet = prursg.Db.scenario_set();
    
    scenarioSet.scenario_set_id = dao.getNextId(scenarioSet);
    scenarioSet.ss_rsg_job_id = job.rsg_job_id;
    scenarioSet.scenario_set_name = 'Very Nice Scenario';
    scenarioSet.scenario_set_type = 'Alabala Scenario';
    scenarioSet.scenario_type_key = 1;
    scenarioSet.number_of_chunks = 1;
    
    dao.insert(scenarioSet);
        
    ss2 = prursg.Db.scenario_set();
    ss2.scenario_set_name = scenarioSet.scenario_set_name; % search via natural key
    ss2 = dao.read(ss2);
    assert(isequal(ss2, scenarioSet));    
    
    
    % test a chunk:
    chunk = prursg.Db.scenario_set_output();    
    chunk.sso_scenario_set_id = scenarioSet.scenario_set_id;
    chunk.chunk_id = 44;
    chunk.chunk = typecast(1:100, 'uint8');      
    dao.insert(chunk);
    
    chunk2 = prursg.Db.scenario_set_output();
    chunk2.sso_scenario_set_id = chunk.sso_scenario_set_id;
    chunk2.chunk_id = chunk.chunk_id;
    
    chunk2 = dao.read(chunk2);
    assert(isequal(chunk, chunk2));
    dbls = typecast(chunk2.chunk, 'double');
    assert(isequal(dbls, 1:100));
       
    dao.commitTransaction();
    dao.close();
end

