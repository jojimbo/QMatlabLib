classdef InMemoryFacade < prursg.Db.IDataFacade
    % aggragation of common functionality used by all Use Cases
    
    properties 
        dao
        jobId
        job
                
        scenarioSet                        
        lastScenairoSetId = 0;                
    end
    
    properties
        ModelFile
        ScenarioSetResultsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    end
    
    methods 
                                  
        function obj = InMemoryFacade()
            obj.dao = prursg.Cache.RsgDao();                    
        end       
                
        % persist job definition and participating risk drivers
        function [job_id riskNameToIdMap] = storeJob(obj, modelFile, startTime, endTime)
            db = prursg.Db.DbFacade();
            dbJob = prursg.Db.rsg_job(modelFile);                        
            dbJob.rsg_job_id = db.dao.getNextId(dbJob);
            dbJob.job_start = startTime;
            dbJob.job_end = endTime;
            db.dao.insert(dbJob);
            %
            obj.jobId = dbJob.rsg_job_id;
            obj.job = dbJob;
            job_id = obj.jobId;
            
            %
            riskNameToIdMap = createRiskNameToIdMap(modelFile.riskDrivers);            
            obj.dao.RiskNameToIdMap = riskNameToIdMap;
            %
            modelFile.jobId = job_id;
            obj.ModelFile = modelFile;
        end
        
        % persist a scenario set, its deterministic and stochastic
        % scenarios. if the set has no stoch. scenarios the chunks cell
        % array  and stochasticScenario must be empty
        function [scenarioSetId scenarioId] = storeScenarioSet(obj, jobId, scenarioSet, setType, setKey, stochasticScenario, noOfChunks, risks)            
            
            obj.lastScenairoSetId = obj.lastScenairoSetId + 1;
            scenarioSetId = obj.lastScenairoSetId;
            
            scenarioSetResult = obj.AddScenarioSetResult(scenarioSetId);
            scenarioSetResult.Id = scenarioSetId ;
            scenarioSetResult.Job = obj.job;
            scenarioSetResult.ModelFile = obj.ModelFile;
            scenarioSetResult.ScenarioSetName = scenarioSet.name;                
            scenarioSetResult.RiskNameToIdMap = obj.dao.RiskNameToIdMap;
            scenarioSetResult.RiskIds = prursg.Cache.risk_factor.getRiskFactorIds(obj.dao, scenarioSetResult.ModelFile.riskDrivers);
                                   
            scenarioSetResult.ScenarioSet = scenarioSet;
                                   
                                                                        
            % no risk scenario
            noRiskScenario = scenarioSet.noRiskScenario;
            if ~isempty(noRiskScenario)                                               
                noRiskOutputs = cell(1, numel(risks));
                for i = 1:numel(risks)                                
                    riskOutputs = []; % cannot prealocate as the number of stochastic outputs per risk is not known!

                    hyperCube = noRiskScenario.getRiskScenarioValues(risks(i).name);
                    hyperCube = prursg.Engine.HyperCube.serialise(hyperCube);
                    riskOutputs = [riskOutputs; hyperCube]; %#ok<AGROW>

                    noRiskOutputs{i} = riskOutputs;
                end
                noRiskScenario.simResults = noRiskOutputs;
                noRiskScenarioId = -1;
            end
            
            %
            stochasticScenario = scenarioSet.getStochasticScenarios();
            if ~isempty(stochasticScenario)
                scenarioCount = numel(stochasticScenario);
                scenarioIds = zeros(1, scenarioCount);
                for i = 1:scenarioCount                    
                    scenarioIds(i) = i;
                    stochasticScenario(i).id = i;
                end
                
                scenarioId = scenarioIds;                
                if (scenarioCount <= 1)
                    scenarioId = scenarioIds(1);
                end                
            end
            
        end
        
        function newChunk = storeScenarioChunk(obj, monteCarloNumber, risks, scenarioSetId, scenarioId, chunk) 
            if isKey(obj.ScenarioSetResultsMap, scenarioSetId)
                scenarioSetResult = obj.ScenarioSetResultsMap(scenarioSetId);
                stochasticScenarios = scenarioSetResult.ScenarioSet.getStochasticScenarios();
                if ~isempty(stochasticScenarios)
                    scenario = stochasticScenarios(find(cell2mat(arrayfun(@(x)(x.id == scenarioId), stochasticScenarios, 'UniformOutput', 0))));
                    
                    if iscell(chunk)
                        for i = 1:numel(chunk)
                            chunk{i} = prursg.Util.ConvertScenarioValue(chunk{i});
                        end
                    else
                        chunk = prursg.Util.ConvertScenarioValue(chunk);
                    end
                    scenario.simResults = chunk;
                end
            end
            
            newChunk = chunk;
        end
        
        
        % retrieve a scenario-set xml file and its chunks out of db by
        % its unique name
        function [xmlModelFile scenarioSet chunks riskIds stochasticScenarioId job nBatches] = readScenarioSet(obj, name, nBatches)
            
            xmlModelFile = [];
            scenarioSet = [];
            chunks = [];
            riskIds = [];
            stochasticScenarioId = [];
            job = [];
                                                
            results = values(obj.ScenarioSetResultsMap);
            if ~isempty(results)
                index = find(cellfun(@(x)(strcmpi(x.ScenarioSetName, name)), results));
                if ~isempty(index)
                    scenarioSetResult = results(index);
                    scenarioSetResult = scenarioSetResult{1};

                    xmlModelFile = scenarioSetResult.ModelFile;
                    riskIds = scenarioSetResult.RiskIds;
                    scenarioSet = scenarioSetResult.ScenarioSet;

                    if ~isempty(scenarioSet)
                        stochasticScenarios = scenarioSet.getStochasticScenarios();
                        if ~isempty(stochasticScenarios)
                            count = numel(stochasticScenarios);
                            if count > 1
                                stochasticScenarioId = zeros(1, count);                                                                
                                for i = 1:count
                                    stochasticScenarioId(1, i) = stochasticScenarios(i).id;
                                    chunk = stochasticScenarios(i).simResults;
                                    chunks = [chunks; cell2mat(chunk)];
                                end                                
                            else
                                stochasticScenarioId = stochasticScenarios.id;
                                %chunks = stochasticScenarios.simResults;
                                
                                if isempty(chunks)
                                    % load meta data.
                                     fname = fullfile( 'simResults', 'simResults_meta.mat');
                                     metaData = load(fname);
                                     chunkSize = metaData.nBatches; 
                                     rows = metaData.rows;
                                     cols = metaData.cols;
                                     chunks = zeros(rows, cols);
                                     startIndex = 0;
                                     endIndex = 0;
                                     for i = 1:chunkSize
                                         fname = fullfile( 'simResults', sprintf( 'simResults_B%d', i ) );                    
                                         chunkData = load(fname);                                         
                                         startIndex = endIndex + 1;
                                         endIndex = startIndex + size(chunkData.data{1}, 1) - 1;     
                                         chunks(startIndex:endIndex, :) = cell2mat(cellfun(@(x)(double(x)), chunkData.data, 'UniformOutput', false)); 
                                     end
                                end                                                                                                        
                            end                            
                        end                    
                    end    

                    job = scenarioSetResult.Job;
                end
            end                        
        end        
        
        function result = AddScenarioSetResult(obj, scenarioSetName)
            result = prursg.Cache.ScenarioSetResults();
            obj.ScenarioSetResultsMap(scenarioSetName) = result;
        end
        
        function storeValidationSchedule(obj, batchIndex, scenSetId, valData)
            % do nothing
        end
        
        % convert none stochastic scenario values.
        function convertScenarioSet(obj, scenarioSetId)
            if isKey(obj.ScenarioSetResultsMap, scenarioSetId)
                scenarioSetResult = obj.ScenarioSetResultsMap(scenarioSetId);
                ss = scenarioSetResult.ScenarioSet;
                
                % convert scenario values 
                % convert deterministic scenarios
                detScenarios = ss.getDeterministicScenarios();
                for i = 1:numel(detScenarios)
                     deterministicScenario = detScenarios(i);   
                     obj.ConvertScenarioValues(deterministicScenario.expandedUniverse);
                end 

                % convert shocked base scenario            
                shockedBase = ss.getShockedBaseScenario();
                if ~isempty(shockedBase)
                   obj.ConvertScenarioValues(shockedBase.expandedUniverse);
                end

                % convert no risk scenario in the deterministic scenario value table 
                noRiskScenario = ss.noRiskScenario;
                if ~isempty(noRiskScenario)               
                    obj.ConvertScenarioValues(noRiskScenario.expandedUniverse);
                end
            end
                        
        end
                                                   
    end
    
    methods(Access=private)
        function ConvertScenarioValues(obj, expandedUniverse)
            if ~isempty(expandedUniverse)
                names = keys(expandedUniverse);
                for i = 1 : length(names)
                    ds = expandedUniverse(names{i});
                    ds.values{1} = prursg.Util.ConvertScenarioValue(ds.values{1});
                end
                
            end
        end
    end
    
end


function riskNameToIdMap = createRiskNameToIdMap(risks)
    riskNameToIdMap = containers.Map();
    
    for k = 1:length(risks)
        if ~riskNameToIdMap.isKey(risks(k).name)
            riskNameToIdMap(risks(k).name) = k;
        end
    end
end

