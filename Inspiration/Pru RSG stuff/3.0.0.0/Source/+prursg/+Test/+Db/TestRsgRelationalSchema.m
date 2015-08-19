function TestRsgRelationalSchema()
    % test the rsg +Blob db schema which uses blobs to preserve rsg output.
    clc;
    clear;
    tic;
    
    %profile on;
            
    xmldom = xmlread(fullfile('+prursg','+Test', '+UseCase','T0 base run test.xml'));
    modelFile = prursg.Xml.ModelFile(xmldom);
            
    % persist risk drivers
    db = prursg.Db.DbFacade();
    %db.dao.dropTables();
    %db.dao.createTables();
    
    [job_id riskNameToIdMap ] = db.storeJob(modelFile, now(), now());
    db.commitTransaction();
    toc;    
    return;
    
    scenarioSetId = persistJobAndScenarioSet(dao, xmldom);
        
    deterministicScenario = modelFile.base_set.scenarios(end);
    riskNameToAxisResolver = persistAxes(dao, riskNameToIdMap, deterministicScenario.expandedUniverse, scenarioSetId);
    
    persistDeterministicScenario(dao, deterministicScenario, scenarioSetId, riskNameToIdMap, riskNameToAxisResolver);
    
   %{ %}
    
    dao.commitTransaction();
    dao.close();
    toc;
   % profile viewer;
end

function dump(e)
    e;
    for i = 1:numel(e)
        e.stack(i)
    end
end

function scenarioSetId = persistJobAndScenarioSet(dao, xmldom)
    % job bit    
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
        
    % scenario-set
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
    
    scenarioSetId = scenarioSet.scenario_set_id;
    
end

function riskNameToAxesResolver = persistAxes(dao, riskNameToIdMap, expandedUniverse, scenarioSetId)
    
    riskNameToAxesResolver = containers.Map();
    riskNames = keys(riskNameToIdMap);    
    for i = 1:numel(riskNames)
        
        riskId = riskNameToIdMap(riskNames{i});
        dataSeries = expandedUniverse(riskNames{i});
        prursg.Db.AxisDao.insert(dao, dataSeries.axes, scenarioSetId, riskId);
        %
        axes = prursg.Db.AxisDao.read(dao, scenarioSetId, riskId);

        % why isequal does not work with axes?
        prursg.Engine.Axis.areEqual(dataSeries.axes, axes);
        riskNameToAxesResolver(riskNames{i}) = axes;
    end    
end

function riskNameToId = persistRiskDrivers(dao, risks)
    riskNameToId = containers.Map();
    for i = 1:numel(risks)
        nyc = risks(i);    
        r = prursg.Db.risk_factor(nyc);
        %
        riskId = dao.exists(r);  
        if riskId == 0
            disp(nyc.name);
            r.risk_factor_id = dao.getNextId(r);
            dao.insert(r);
        else
            r.risk_factor_id = riskId;
        end
        
        r2 = prursg.Db.risk_factor();
        r2.risk_factor_name = r.risk_factor_name;
        r2 = dao.read(r2);
        assert(isequal(r, r2));
        %
        riskNameToId(r.risk_factor_name) = r.risk_factor_id;
    end;
end

function persistDeterministicScenario(dao, deterministicScenario, scenarioSetId, riskNameToId, riskNameToAxisResolver)

    prursg.Db.DeterministicScenarioDao.insert(...
        dao, deterministicScenario, scenarioSetId, riskNameToId ...
    );

    scenarioBack = prursg.Db.DeterministicScenarioDao.read( ...
        dao, scenarioSetId, riskNameToAxisResolver ...
    );

    assert(prursg.Engine.Scenario.areEqual(scenarioBack, deterministicScenario));

end

