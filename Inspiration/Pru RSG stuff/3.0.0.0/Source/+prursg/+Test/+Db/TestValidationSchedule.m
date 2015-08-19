function TestValidationSchedule()
    % test the prursg.Db.ValidationSchedule API
    clc;
    clear;
    tic;
    
    dao = prursg.Db.RsgDao();
    dao.beginTransaction();
    dao.dropTables();
    dao.createTables();
    
    setId = persistJobAndScenarioSet(dao);
    
    data = [ { 'rulesetName' }, { 'item' }, { 'measure' } ];
    data = [ repmat(data, 10, 1) num2cell((1:10)' .* 0.1) ];
    prursg.Db.validation_schedule.storeValidationSchedule(dao, setId, data);
    
    data2 = prursg.Db.validation_schedule.readValidationSchedule(dao, 'Very Nice Scenario');
    
    assert(isequal(data, data2));
    
    dao.commitTransaction();
    dao.close();
    toc;
end

function scenarioSetId = persistJobAndScenarioSet(dao)
    % job bit    
    job = prursg.Db.rsg_job();
    job.rsg_job_id = dao.getNextId(job);
    job.job_start = now();
    job.job_end = now();
    job.basecurrency = 'GBP';
    job.num_simulations = 100000;
    job.xml_model_file = 'This is not XML content!';
    job.retain_flag = 'Y';
    job.persist_until = job.job_start + 365 * 10;
    dao.insert(job);
            
    % scenario-set
    scenarioSet = prursg.Db.scenario_set();
    
    scenarioSet.scenario_set_id = dao.getNextId(scenarioSet);
    scenarioSet.ss_rsg_job_id = job.rsg_job_id;
    scenarioSet.scenario_set_name = 'Very Nice Scenario';
    scenarioSet.scenario_set_type = 'Alabala Scenario';
    scenarioSet.scenario_type_key = 1;
    scenarioSet.sess_date = now();
    scenarioSet.number_of_chunks = 1;
    
    dao.insert(scenarioSet);   
    scenarioSetId = scenarioSet.scenario_set_id;    
end


