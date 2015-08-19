classdef DbFacade < prursg.Db.IDataFacade
    % aggragation of common functionality used by all Use Cases
    
    properties 
        dao
        jobId        
    end
    
    methods 
        
        function obj = DbFacade()
            obj.dao = prursg.Db.RsgDao();
            %obj.dao.beginTransaction();
            prursg.Xml.configureJava(true); % fast java insertion of stochastic samples
        end
        
        function clearTables(obj)
            obj.dao.dropTables();
            obj.dao.createTables();            
        end        
        
        function clearMdsTables(obj)
            obj.dao.recreateMdsTables();
        end
                
        % persist job definition and participating risk drivers
        function [job_id riskNameToIdMap ] = storeJob(obj, modelFile, startTime, endTime)
            job = prursg.Db.rsg_job(modelFile);                        
            job.rsg_job_id = obj.dao.getNextId(job);
            job.job_start = startTime;
            job.job_end = endTime;            
            obj.dao.insert(job);
            %
            obj.jobId = job.rsg_job_id; 
            job_id = obj.jobId;
            %
            riskNameToIdMap = persistRiskDrivers(obj.dao, modelFile.riskDrivers);
            obj.riskNameToIdResolver = riskNameToIdMap;            
        end
        
        % persist a scenario set, its deterministic and stochastic
        % scenarios. if the set has no stoch. scenarios the chunks cell
        % array  and stochasticScenario must be empty
        function [scenarioSetId scenarioId] = storeScenarioSet(obj, jobId, scenarioSet, setType, setKey, stochasticScenario, noOfChunks, risks)            
            % store scenario set.
            rsgScenarioSet = prursg.Db.scenario_set();
            rsgScenarioSet.scenario_set_id = obj.dao.getNextId(rsgScenarioSet);
            scenarioSetId = rsgScenarioSet.scenario_set_id;
            rsgScenarioSet.ss_rsg_job_id = jobId;
            rsgScenarioSet.scenario_set_name = scenarioSet.name;
            rsgScenarioSet.scenario_set_type = setType;
            rsgScenarioSet.scenario_type_key = setKey;
            rsgScenarioSet.sess_date = scenarioSet.sess_date;
            
            rsgScenarioSet.number_of_chunks = noOfChunks;
            obj.dao.insert(rsgScenarioSet);
            
            % add partition
            sqlPartition = ['begin execute immediate ''ALTER TABLE STOCHASTIC_SCENARIO_VALUE ADD PARTITION P' num2str(scenarioSetId) ' VALUES LESS THAN (' num2str(scenarioSetId + 1) ')''; end; ' ];            
            if (scenarioSetId > 1)
                partitionResults = exec(obj.dao.connection, sqlPartition);                
                if ~isempty(partitionResults.Message)
                    throw(MException('DbFacade:storeScenarioSet', ['Failed to add partition:' partitionResults.Message]));
                end
            end
            
            % store axis
            baseScenario = scenarioSet.getBaseScenario();
            if ~isempty(baseScenario)                
                 nAxes = baseScenario.getTotalNumberOfAxes(baseScenario.expandedUniverse);
                 persistAxes(obj.dao, obj.riskNameToIdResolver, ...
                            baseScenario.expandedUniverse, scenarioSetId, nAxes);
            end
            
            % store deterministic scenarios
            detScenarios = scenarioSet.getDeterministicScenarios();
            for i = 1:numel(detScenarios)
                 deterministicScenario = detScenarios(i);                 
                 prursg.Db.DeterministicScenarioDao.insert(...
                     obj.dao, deterministicScenario, scenarioSetId, obj.riskNameToIdResolver ...
                 );                                  
            end 
            
            % store shocked base scenario            
            shockedBase = scenarioSet.getShockedBaseScenario();
            if ~isempty(shockedBase)
               prursg.Db.DeterministicScenarioDao.insert(...
                     obj.dao, shockedBase, scenarioSetId, obj.riskNameToIdResolver ...
                 );     
            end
            
            % store no risk scenario in the deterministic scenario value table 
            noRiskScenario = scenarioSet.noRiskScenario;
            if ~isempty(noRiskScenario)
               prursg.Db.NoRiskScenarioDao.insert(...
                     obj.dao, noRiskScenario, scenarioSetId, obj.riskNameToIdResolver);    
            
            end
            
            % store stochastic scenarios chunk by chunk
            %make a dummy 'stochastic scenario'
            
            if ~isempty(stochasticScenario)
                scenarioCount = numel(stochasticScenario);
                scenarioIds = zeros(1, scenarioCount);
                for i = 1:scenarioCount
                    sId = prursg.Db.StochasticScenarioDao.insertScenario( ...
                    obj.dao, stochasticScenario(i), scenarioSetId ...                    
                    );    
                    scenarioIds(i) = sId;
                end
                
                scenarioId = scenarioIds;
                
                if (scenarioCount <= 1)
                    scenarioId = scenarioIds(1);
                end                
            end
            
        end
        
        function newChunk = storeScenarioChunk(obj, monteCarloNumber, risks, scenarioSetId, scenarioId, chunk)            
                        
            % store stochastic scenarios
            %make a dummy 'stochastic scenario'
            prursg.Db.StochasticScenarioDao.insertSSV( ...
                monteCarloNumber, obj.dao, risks, chunk, scenarioSetId, scenarioId, obj.riskNameToIdResolver ...
            );
        
            newChunk = chunk;
            
        end
        
        function commitTransaction(obj)
            obj.dao.commitTransaction();
            obj.dao.close();
        end        
        
        % retrieve a scenario-set xml file and its chunks out of db by
        % its unique name
        function [xmlModelFile scenarioSet chunks riskIds stochasticScenarioId job nBatches] = readScenarioSet(obj, name, nBatches)
            
            if ~exist('Cache', 'dir')
                mkdir('Cache');
            end
            
            sset = prursg.Db.scenario_set();
            sset.scenario_set_name = name;
            sset = obj.dao.read(sset);            
            %            
            xmlModelFile = [];
            scenarioSet  = [];
            chunks = [];
            if ~isempty(sset)
                % sset.scenario_set_type defines different types of
                % scenario sets
                scenarioSet = makeScenarioSet(obj.dao, sset);

                %
                [xmlModelFile job] = readModelFile(obj.dao, sset.ss_rsg_job_id);            
                %                
                % read deterministic bits
                riskNameToAxisResolver = prursg.Db.AxisDao.makeRiskNameToAxesResolver(...
                    obj.dao, sset.scenario_set_id ...
                );
                scenarioSet.scenarios = prursg.Db.DeterministicScenarioDao.read(...
                    obj.dao, sset.scenario_set_id, riskNameToAxisResolver ...
                );
                %
                
                % read stochastic chunks
                stochasticScenarios = prursg.Db.StochasticScenarioDao.read(...
                    obj.dao, sset.scenario_set_id, riskNameToAxisResolver ...
                );
                %read Norisk scenario
                scenarioSet.noRiskScenario = prursg.Db.NoRiskScenarioDao.read(...
                    obj.dao, sset.scenario_set_id, riskNameToAxisResolver ...
                );
                stochasticScenarios = stochasticScenarios(find(cell2mat(arrayfun(@(x)(x.isStochasticScenario == 1), stochasticScenarios, 'UniformOutput', 0))));
                
                scenarioSet.scenarios = [scenarioSet.scenarios stochasticScenarios];
                
                riskIds = prursg.Db.risk_factor.getRiskFactorIds(obj.dao, xmlModelFile.riskDrivers);                
                stochasticScenarioId = prursg.Db.scenario.getStochasticScenarioId(...
                    obj.dao, sset.scenario_set_id  ...
                ); 

            
                disp('Loading stochastic scenario data...');    
                
                scenarioSetId = sset.scenario_set_id;
                
                if isempty(nBatches)
                    nBatches = 1;
                end
                                
                import prursg.Configuration.*;
                useGrid = 'false';
                useCache = 'false';
                schedulerType = 'local';
                
                cm = prursg.Configuration.ConfigurationManager();
                
                dbSetting = cm.ConnectionStrings(cm.AppSettings('DefaultDB'));
                connectionInfo = struct('url', dbSetting.Url, 'username', dbSetting.UserName, 'password', dbSetting.Password);
                            
                if isKey(cm.AppSettings, 'UseCache')
                    useCache = cm.AppSettings('UseCache');
                end
                
                if isKey(cm.AppSettings, 'UseGrid')
                    useGrid = cm.AppSettings('UseGrid');
                end

                if (isdeployed && strcmpi(useGrid, 'true'))
                    setmcruserdata('ParallelConfigurationFile', fullfile(pwd(), 'ParallelConfig.mat'));
                    schedulerType = 'LSF';
                end
                
                
                chunkInfoFileName = fullfile(pwd(), 'Cache', 'chunkinfo.mat');
                
                ci = prursg.Db.ChunkInfo();
                if (strcmpi(useCache, 'true') && exist(chunkInfoFileName, 'file'))
                    
                    disp('Cached data access enabled. Skipping database access...');
                    
                    chunkInfo = load(chunkInfoFileName);
                    ci = chunkInfo.ci;                                        
                    
                else
                                        
                    [nRiskIdsLocal riskIdsLocal nBatches] = prursg.Util.JobUtil.splitRiskIds(riskIds, nBatches);
                    
                    if (nBatches > 1 && strcmpi(useGrid, 'true'))
                        
                        disp(['Grid enabled. No of Batches-' num2str(nBatches)]);                           

                        fileNames = cell(1, nBatches);
                        numSubRisks = zeros(1, nBatches);
                        chunkSizes = zeros(1, nBatches);
                        numRows = zeros(1, nBatches);
                                                
                        job = CreateDistributedJob();

                        for batchIndex = 1:nBatches
                          % Create specific number of tasks within the job.
                          createTask(job, @retrieveData, 0, {connectionInfo, batchIndex, scenarioSetId, riskIdsLocal{batchIndex}});
                        end
                        
                        alltasks = get(job, 'Tasks');
                        set(alltasks, 'CaptureCommandWindowOutput', true);
    
                        % Submit the job.
                        submit(job);

                        % Wait for the job to finish. This client actually checks the job status
                        waitForState(job, 'finished');     
                        outputmessages = get(alltasks, 'CommandWindowOutput');

                        destroy(job);      
                        

                        ci.NumSimulations = numRows(1);
                        ci.FileNames = fileNames;
                        ci.NumSubRisks = numSubRisks;
                        ci.ChunkSizes = chunkSizes;
                    else                                                
                        chunks = prursg.Db.StochasticScenarioDao.readChunks(...
                                        connectionInfo, 1, scenarioSetId, cell2mat(riskIdsLocal') ...
                                    );   

                        % Save the retrieved data to the file system.
                        fileName = fullfile(pwd(), 'Cache', ['chunk' num2str(1) '.mat']);                    
                        ci.NumSimulations = size(chunks{1}, 1);
                        ci.FileNames{1} = fileName;
                        ci.NumSubRisks(1) = numel(riskIdsLocal);                        
                        ci.ChunkSizes(1) = sum(cellfun(@(x)size(x, 2), chunks));
                        parsave(fileName, chunks);
                    end  

                    %save chunk info file.
                    fileName = fullfile(pwd(), 'Cache', 'chunkinfo.mat');
                    save(fileName, 'ci', prursg.Util.FileUtil.GetMatFileFormat());
                end

                %load chunks.
                chunks = obj.loadChunks(ci);
            end            
        end        
        
        % return a DataSeriesObject containing all deterministic hypercubes
        % of the RiskFactor represented by its riskName within a given
        % ScenarioSet designated by scenarioSetName
        %
        % The value of the risk factor in each deterministic scenario forms
        % a separate hyper cube in dso.values cell array.
        function dso = getRiskFactorDeterministicValues(obj, riskName, scenarioSetName)
            dso = prursg.Db.DeterministicScenarioDao.getRiskFactorDeterministicValues( ...
                obj.dao, riskName, scenarioSetName ...
            );
        end
        
        % return a DataSeriesObject containing all stochastic hypercubes
        % of the RiskFactor represented by its riskName within a given
        % ScenarioSet designated by scenarioSetName
        %
        % The value of the risk factor in each monte carlo simulation run
        % forms a separate hyper cube in dso.values cell array.
        %
        % dso.dates(i) holds the number of the monte carlo simulation instead
        % of a date
        %
        % 2 optional arguments fromMonteCarloSample, toMonteCarloSample can
        % be used to limit the range of stochastic samples being processed.
        % By default all monte carlo simulated samples are returned by the
        % function
        function dso = getRiskFactorStochasticValues(obj, riskName, scenarioSetName, varargin)
            switch numel(varargin)
                case 2                   
                    dso = prursg.Db.StochasticScenarioDao.getRiskFactorStochasticValues( ...
                        obj.dao, riskName, scenarioSetName, varargin{1},  varargin{2} ...
                    );

                case 0
                    dso = prursg.Db.StochasticScenarioDao.getRiskFactorStochasticValues( ...
                        obj.dao, riskName, scenarioSetName ...
                    );                    
                otherwise
                    error('wrong number of optional arguments');
            end            
        
        end
                    
    
        % load chunk data from the disk.
        function stoValues = loadChunks(obj, chunkInfo)           
            stoValues = zeros(chunkInfo.NumSimulations, sum(chunkInfo.ChunkSizes));

            startIndex = 0;
            endIndex = 0;      

            for batchIndex = 1:numel(chunkInfo.FileNames)
                fileName = fullfile(pwd(), 'Cache', ['chunk' num2str(batchIndex) '.mat']);
                chunks = load(fileName);

                for j = 1:size(chunks.chunks, 2)
                    startIndex = endIndex + 1;
                    matData = chunks.chunks{j};
                    endIndex = startIndex + size(matData, 2) - 1;                
                    stoValues(:, startIndex:endIndex) = matData;
                end                        
            end       
        end
        
        % read model file for the given scenario set name.
        function [modelFile] = readModelFile(obj, name)
            sset = prursg.Db.scenario_set();
            sset.scenario_set_name = name;
            sset = obj.dao.read(sset);
            
            [modelFile job] = readModelFile(obj.dao, sset.ss_rsg_job_id); 
            
        end
        
        function storeValidationSchedule(obj, batchIndex, scenSetId, valData)
            prursg.Db.validation_schedule.storeValidationSchedule(obj.dao, batchIndex, scenSetId, valData);  
        end  
        
        function convertScenarioSet(obj, scenarioSet)
            %do nothing.
        end
    end
        
end

function scenarioSet = makeScenarioSet(dao, sset)
    switch sset.scenario_set_type
        case 4
            scenarioSet = prursg.Engine.UserDefinedScenarioSet();
        otherwise
            scenarioSet = prursg.Engine.ScenarioSet();
    end
    scenarioSet.name = sset.scenario_set_name;
    scenarioSet.sess_date = sset.sess_date;

end

function [ xmlModelFile job ] = readModelFile(dao, job_id)
    job = prursg.Db.rsg_job();
    job.rsg_job_id = job_id;
    job = dao.read(job);
    fileName = [ tempname() '.xml' ];
    fid = fopen(fileName, 'w');
    fwrite(fid, job.xml_model_file);
    fclose(fid);
    % rerun configureJava for command line apps as otherwise can't seem to find Java
    % apps
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
   
    xmlModelFile = ControlFile.ControlFileFactory.create(fileName);
 
    delete(fileName);
end

% risk drivers having same NK may already exist in the database.
function riskNameToId = persistRiskDrivers(dao, risks)
    %
    r = prursg.Db.risk_factor();
    riskNameToId = r.makeRiskNameToIdResolver(dao);
    newRows = 0;
    for i = 1:numel(risks)
        if ~isKey(riskNameToId, risks(i).name)
            newRows = newRows + 1;
        end
    end
    %
    if newRows > 0
        riskIdentifiers = dao.getNextId(r, newRows);
        data = cell(newRows, numel(r.getTableColumnNames()));
        currentRow = 0;
        %
        for i = 1:numel(risks)
            if ~isKey(riskNameToId, risks(i).name)
                r = r.populate(risks(i));
                %fprintf('persisting %s %d %d\n', risks(i).name, i, currentRow);
                currentRow = currentRow + 1;
                r.risk_factor_id = riskIdentifiers(currentRow);
                data(currentRow, :) = r.getTableRow();
                riskNameToId(r.risk_factor_name) = r.risk_factor_id;
            end
        end;
        prursg.Db.rsg_fastinsert( ...
            dao.connection, r.getTableName(), r.getTableColumnNames(), data(1:currentRow, :)...
        );
    end
end

function persistAxes(rsgDao, riskNameToIdMap, expandedUniverse, scenarioSetId, nAxes)    
    if nAxes > 0
        
        %
        dbAxis = prursg.Db.axis();
        dao = prursg.Db.BulkInsertDao(rsgDao, dbAxis, nAxes);
        %
        
        riskNames = keys(riskNameToIdMap);    
        for i = 1:numel(riskNames)        
            riskId = riskNameToIdMap(riskNames{i});
            if isKey(expandedUniverse,riskNames{i})
                dataSeries = expandedUniverse(riskNames{i});
                prursg.Db.AxisDao.insert(dao, dataSeries.axes, scenarioSetId, riskId);
            end
        end    
        %
        dao.bulkInsert();
    end
end

% allow saving data from the parfor.
function parsave(fname, chunks)
    %disp(['In the parsave method and the current file format from configuration is: ' prursg.Util.FileUtil.GetMatFileFormat()]);
    save(fname, 'chunks', prursg.Util.FileUtil.GetMatFileFormat());
end

function retrieveData(connectionInfo, batchIndex, scenarioSetId, riskIdsLocal)
    try
        prursg.Xml.configureJava(true);                            
        chunks = prursg.Db.StochasticScenarioDao.readChunks(...
                connectionInfo, batchIndex, scenarioSetId, riskIdsLocal ...
            );   

        % Save the retrieved data to the file system.
        fileName = fullfile(pwd(), 'Cache', ['chunk' num2str(batchIndex) '.mat']);
        fileNames{batchIndex} = fileName;
        numSubRisks(batchIndex) = length(riskIdsLocal);
        chunkSizes(batchIndex) = sum(cellfun(@(x)size(x, 2), chunks));
        numRows(batchIndex) = size(chunks{1}, 1);

        parsave(fileName, chunks);

    catch ME
        disp(['Error occurred in the batch ' num2str(batchIndex) '. \r\n' getReport(ME)]);
    end     
end
