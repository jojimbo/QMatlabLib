classdef SimulationEngine < prursg.Engine.Engine
    % core engine that performs Monte Carlo simulations of the risk drivers
     
    properties ( SetAccess = private )
        simTimeStepInMonths
        numSims
        nBatches
    end
    
    properties  % this is temporary fix
        simulationOutputs % a cell array of outputs per risk driver
        modelFile        
    end
    
    
    methods
        function obj = SimulationEngine(modelFile)
            % SimulationEngine - Constructor
            obj = obj@prursg.Engine.Engine();
            obj.modelFile = modelFile;
        end
        
        function simulResults = simulate( obj , simTimeStepInMonths, numSims, nBatches, corrNums, riskIndexResolver)
            
            obj.simTimeStepInMonths = simTimeStepInMonths;
            obj.numSims = numSims;
            obj.nBatches = nBatches;
            
            % set properties of included models
            for ii=1:numel(obj.risks)
                obj.risks(ii).model.simEngine = struct('simTimeStepInMonths', obj.simTimeStepInMonths);
            end
                        
        
            fprintf([datestr(now) 'SimEngine: Msg - setting up batches \n']);
            
            m = obj.modelFile;
            
            if (obj.nBatches > 1)
                [nSimsLocal corrNumsLocal obj.nBatches] = obj.splitCorrNums(obj.numSims,obj.nBatches,corrNums);
                nBatches = obj.nBatches;
            end
            
            if(m.is_in_memory)
                % create meta data file.
                fname = fullfile( 'simResults', 'simResults_meta.mat');                
                eu = m.base_set.scenarios(1).expandedUniverse;
                rows = numSims;
                cols = sum(arrayfun(@(x)(eu(x.name).getSize()), obj.risks));
                save( fname, 'nBatches', 'rows', 'cols');         
            end
            
            risks = obj.risks;            
            if ~exist(fullfile(pwd, 'tmp'), 'dir')
                mkdir(fullfile(pwd, 'tmp'));
            end
            risksFilePath = fullfile(pwd, 'tmp', sprintf('%s.mat', char(java.util.UUID.randomUUID().toString())));
            save(risksFilePath, 'risks');            
                      
            rootFolder = pwd;
            
            % organise simulation jobs for workers
            if obj.nBatches == 1
                % if one batch then simply run on local machine with 1
                % worker
                fprintf('SimEngine: Msg - single batch run started \n');                    
                simWorker = prursg.Engine.SimulationWorker(1,obj.risks, corrNums, riskIndexResolver, 0, m.is_in_memory, m.scenarioSetId, m.scenarioId, rootFolder, risksFilePath);                        
                simWorker.simulate();
                % needed as a temp fix to produce algo results [to delete]
                obj.simulationOutputs = simWorker.simOutputs;
                simulResults = [];
            else
                % if multiple batches instantiate multiple workers and
                % simulate in parallel


                % instantiate multiple simulationworkers and simulate in
                % parallel                                        
                 if prursg.Util.ConfigurationUtil.GetUseGrid()

                    parentJob = getCurrentJob();                        
                    job = CreateDistributedJob(prursg.Util.ConfigurationUtil.GetSymphonyAppProfileName(m.is_in_memory));

                    if ~isempty(parentJob)
                        set(job, 'PathDependencies', {prursg.Util.ConfigurationUtil.GetRSGSourceCodePath()});
                        job
                    end 

                    for batchIndex = 1:obj.nBatches 
                      % Create specific number of tasks within the job.
                      createTask(job, @runSimulationWorker, 0, {batchIndex,[], corrNumsLocal{batchIndex}, riskIndexResolver, (batchIndex - 1) * nSimsLocal(1), m.is_in_memory, m.scenarioSetId, m.scenarioId, rootFolder, risksFilePath});                                              
                    end

                    alltasks = get(job, 'Tasks');
                    set(alltasks, 'CaptureCommandWindowOutput', true);

                    % Submit the job.
                    submit(job);

                    % Wait for the job to finish. This client actually checks the job status
                    waitForState(job, 'finished');                        
                    outputmessages = get(alltasks, 'CommandWindowOutput');
                    
                    for message = 1:length(outputmessages)
                        disp(outputmessages{message});
                    end

                    destroy(job);                        
                 else
                    for batchIndex = 1:obj.nBatches 
                      % Create specific number of tasks within the job.
                      runSimulationWorker(batchIndex,[], corrNumsLocal{batchIndex}, riskIndexResolver, (batchIndex - 1) * nSimsLocal(1), m.is_in_memory, m.scenarioSetId, m.scenarioId, rootFolder, risksFilePath);                                              
                    end
                 end
                 
                simulResults = [];                                        

                if exist(risksFilePath, 'file')
                    delete(risksFilePath);
                end
            end
            
        end
        
        function [nSimsLocal corrNumsLocal newBatches] = splitCorrNums(obj, nSims, nBatches, corrNums)
            % split array of correlated random numbers into blocks required for each local workers
            
            if (nSims >= nBatches)
                % begin by working out number of simulations in each batch
                for batchIndex = 1:nBatches
                    if batchIndex == nBatches
                        nSimsLocal(batchIndex) = nSims - (nBatches-1)*floor(nSims/nBatches);
                    else
                        nSimsLocal(batchIndex) = floor(nSims/nBatches);
                    end
                end

                % then pick up the right number of rows of correlated random numbers
                corrNumsLocal = cell(nBatches,1);
                rowStart = 1;
                rowEnd = 0;
                for i = 1:nBatches
                    rowEnd = rowEnd + nSimsLocal(i);
                    corrNumsLocal{i} = corrNums(rowStart:rowEnd,:);
                    rowStart = rowEnd + 1;         
                end
            else
                nBatches = nSims;
                nSimsLocal = ones(1, nBatches);                
            end
            
            % then pick up the right number of rows of correlated random numbers
            corrNumsLocal = cell(nBatches,1);
            rowStart = 1;
            rowEnd = 0;
            for i = 1:nBatches
                rowEnd = rowEnd + nSimsLocal(i);
                corrNumsLocal{i} = corrNums(rowStart:rowEnd,:);
                rowStart = rowEnd + 1;         
            end
            
            newBatches = nBatches;
        end
        
    end
    
end

function runSimulationWorker(batchIndex, risks, corrNumsLocal, riskIndexResolver, mcNumber, is_in_memory, scenarioSetId, scenarioId, rootFolder, risksFilePath)    
    try
        if ~isdeployed
            addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
        end
        simWorker = prursg.Engine.SimulationWorker(batchIndex,risks, corrNumsLocal, riskIndexResolver, mcNumber, is_in_memory, scenarioSetId, scenarioId, rootFolder, risksFilePath);                                
        simWorker.simulate();                               
    catch ex
        disp(getReport(ex));
    end    
end
