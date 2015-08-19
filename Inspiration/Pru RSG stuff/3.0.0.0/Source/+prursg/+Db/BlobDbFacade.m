classdef BlobDbFacade
    % aggregation of common functionality used by all Use Cases
    
    properties ( Access = 'private')
        dao
    end
    
    methods 
        
        function obj = DbFacade()
            obj.dao = prursg.Db.RsgDao();
            obj.dao.beginTransaction();
        end
                
        function jobId = storeJob(obj, modelFile, startTime, endTime)
            rsgJob = prursg.Db.RsgJob();
            rsgJob.id = obj.dao.getNextId();
            rsgJob.job_start = startTime;
            rsgJob.job_end = endTime;
            rsgJob.basecurrency = modelFile.basecurrency;
            rsgJob.xml_model_file = prursg.Xml.XmlTool.toString(modelFile.modelFileDOM, true);
            obj.dao.insert(rsgJob);
            jobId = rsgJob.id;
        end
        
        function scenarioSetId = storeScenarioSet(obj, jobId, scenarioSet, setType, setKey, chunks)            
            rsgScenarioSet = prursg.Db.RsgScenarioSet();
            rsgScenarioSet.job_id = jobId;
            rsgScenarioSet.id = obj.dao.getNextId();
            rsgScenarioSet.scenario_set_name = scenarioSet.name;
            rsgScenarioSet.scenario_set_type = setType;
            rsgScenarioSet.scenario_type_key = setKey;
            rsgScenarioSet.number_of_chunks = 1;
            obj.dao.delete(rsgScenarioSet); % TODO do not do this in production
            obj.dao.insert(rsgScenarioSet);
            %
            scenarioSetId = rsgScenarioSet.id;
            % and the chunks
            for i = 1:numel(chunks)
                storeChunk(obj.dao, scenarioSetId, i, chunks{i})
            end            
        end
                        
        function commitTransaction(obj)
            obj.dao.commitTransaction();
            obj.dao.close();
        end        
        
        % retrieve a scenario-set xml file and its chunks out of db by
        % its unique name
        function [xmlModelFile chunks] = readScenarioSet(obj, name)
            sset = prursg.Db.RsgScenarioSet();
            sset.scenario_set_name = name;
            sset = obj.dao.read(sset);
            
            %
            xmlModelFile = [];
            chunks = [];
            if ~isempty(sset)
                chunks = cell(1, sset.number_of_chunks);
                for i = 1:sset.number_of_chunks
                    chunks{i} = readChunk(obj.dao, sset.id, i);
                end
                %
                xmlModelFile = readModelFile(obj.dao, sset.job_id);            
            end
        end        
    end
    
end

function xmlModelFile = readModelFile(dao, job_id)
    job = prursg.Db.RsgJob();
    job.id = job_id;
    job = dao.read(job);
    fileName = [ tempname() '.xml' ];
    fid = fopen(fileName, 'w');
    fwrite(fid, job.xml_model_file);
    fclose(fid);
    xmlModelFile = xmlread(fileName);
    delete(fileName);
end

function outputs = readChunk(dao, set_id, chunk_id)
    chunk = prursg.Db.RsgOutputChunk();
    chunk.scenario_set_id = set_id;
    chunk.chunk_id = chunk_id;
    chunk = dao.read(chunk);
    %
    fileName = [ tempname '.mat' ];
    fid = fopen(fileName, 'w');
    fwrite(fid, chunk.chunk, 'uint8');
    fclose(fid);
    d = load(fileName);
    outputs = d.simulationOutputs;
end

function storeChunk(dao, rsgScenarioSetId, chunkId, simulationOutputs)
    fileName = [ tempname() '.mat' ];
    save(fileName, 'simulationOutputs', prursg.Util.FileUtil.GetMatFileFormat());
    fid = fopen(fileName, 'r');
    bytes = fread(fid, '*uint8'); % mind the * infront of uint8 - arch-important!
    fclose(fid);
    chunk = prursg.Db.RsgOutputChunk();
    chunk.scenario_set_id = rsgScenarioSetId;
    chunk.chunk_id = chunkId;
    chunk.chunk = bytes;
    dao.insert(chunk);
    delete(fileName);    
end

