function [UserMsg ScenSetID dataFacade] = RSGRunWhatIf(modelFile, nBatches, isInMemory)

    try
        import prursg.Xml.*;
        
        dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(isInMemory);        
        [jobId riskNameToIdMap] = dataFacade.storeJob(modelFile, now(), now());        
        
        ScenSetList = {};
        
        % locate the base scenario set 
        fprintf('Attempting to read base scenario set "%s"\n', modelFile.what_if_sets_base_set_name);
        [baseModelFile scenarioSet stoValues riskIds stochasticScenarioId job nBatches] = dataFacade.readScenarioSet(modelFile.what_if_sets_base_set_name, nBatches);        
        
        baseScenario = scenarioSet.getBaseScenario();        
        [nRiskIdsLocal riskIdsLocal] = prursg.Util.JobUtil.splitRiskIds(riskIds, nBatches);
        numSubRisks = prursg.Util.JobUtil.getSubRisks(baseModelFile.riskDrivers, baseScenario.expandedUniverse);                                                       
        nSubRisks = sum(numSubRisks(:, 1));
                   

        wiss = modelFile.what_if_sets(1);        
        noRiskScenario = scenarioSet.noRiskScenario; % we want this scenario from the base scenario stored in the database, not from the input XML file
        
        %We apply the shock to the noRiskScenario        
        stoNoRiskValues = noRiskScenario.getSimResults(baseModelFile.riskDrivers);        
        wissChunks_norisk = wiss.makeStochasticOutputs(baseModelFile.riskDrivers, baseScenario, stoNoRiskValues(:, :), numSubRisks);                
        % Copy the after shock values of noRiskScenario into the noRiskScenario
        noRiskScenario.simResults = wissChunks_norisk;  
        noRiskScenario.updateExpandedUniverse(wissChunks_norisk, baseModelFile.riskDrivers, numSubRisks);


        % loop over all specified what-if scenarios
        wissChunks = [];
        for i = 1:numel(modelFile.what_if_sets)
            wiss = modelFile.what_if_sets(i);
            whatIfDeterministicScenarioSet = wiss.makeResultScenarioSet(scenarioSet);
            whatIfDeterministicScenarioSet.noRiskScenario = noRiskScenario;
            whatIfDeterministicScenarioSet.sess_date=scenarioSet.sess_date;
                                                          
            whatIfStochasticScenario= scenarioSet.getStochasticScenarios();
                                    
            [scenarioSetId scenarioId] = dataFacade.storeScenarioSet( ...
            jobId, whatIfDeterministicScenarioSet, ...
            modelFile.scenario_set_type, modelFile.scenario_type_key, ...            
            whatIfStochasticScenario, nBatches, modelFile.riskDrivers ...
            );
            
            scenarioId=scenarioId(end);
            
            if ~exist(fullfile(pwd, 'tmp'), 'dir')
                mkdir(fullfile(pwd, 'tmp'));
            end
            
            if (nBatches > 1 && prursg.Util.ConfigurationUtil.GetUseGrid())            
                
                job = CreateDistributedJob();
                
                risks = baseModelFile.riskDrivers;      
                risksFilePath = fullfile(pwd, 'tmp', sprintf('%d_whatif_risks.mat', job.ID));
                save(risksFilePath, 'risks');
            
                for batchIndex = 1:nBatches    
                    
                    wiss = modelFile.what_if_sets(i);
                    startIndex = ((batchIndex - 1) * nRiskIdsLocal(1) + 1);
                    endIndex = ((batchIndex - 1) * nRiskIdsLocal(1) + nRiskIdsLocal(batchIndex));                                    
                    
                    createTask(job, @runWhatIf, 0, {batchIndex, wiss, baseScenario, startIndex, endIndex, scenarioSetId, scenarioId, numSubRisks, isInMemory, risksFilePath});
                    
                end      
                
                alltasks = get(job, 'Tasks');
                set(alltasks, 'CaptureCommandWindowOutput', true);

                % Submit the job.
                submit(job);                
                
                % Wait for the job to finish. This client actually checks the job status
                waitForState(job, 'finished');               
                outputmessages = get(alltasks, 'CommandWindowOutput');
                
                destroy(job);      
                
                if exist(risksFilePath, 'file')
                    delete(risksFilePath);
                end
            else                
                wissChunks = wiss.makeStochasticOutputs(baseModelFile.riskDrivers, baseScenario, stoValues(:, :), numSubRisks);                
                saveResults(1, baseModelFile.riskDrivers, scenarioSetId, scenarioId, mat2cell(wissChunks, size(wissChunks, 1), numSubRisks(:, 1)'), 0, isInMemory);
            end
            
            dataFacade.convertScenarioSet(scenarioSetId);
        end              
                
        
        % return the unique scenario set identifier(s)
        for i = 1:numel(modelFile.what_if_sets)
            ScenSetList(i) = {modelFile.what_if_sets(i).name};
        end
        
        ScenSetID = ScenSetList{1,1};
        UserMsg = 'Main - Msg: RSG What-If run complete';
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSG What-If run:\n%s', getReport(ME));

    end
end


function saveResults(batchIndex, riskDrivers, scenarioSetId, scenarioId, data, mcNumber, isInMemory)          
    disp([ datestr(now) ' - Saving results(BatchId-' num2str(batchIndex)  ')...']);            
    % utility function
    % used for saving simulation results of a batch onto file
    % system
    
    dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(isInMemory);
    r = prursg.Db.DataFacadeFactory.CreateRiskFactor(isInMemory);
    dataFacade.riskNameToIdResolver = r.makeRiskNameToIdResolver(dataFacade.dao);

    dataFacade.storeScenarioChunk( ...
    mcNumber, ...
    riskDrivers, scenarioSetId, scenarioId, ...
    data ...
    );

    disp([ datestr(now) ' - Saved results(BatchId-' num2str(batchIndex)  ')...']);
end
 
function runWhatIf(batchIndex, wiss, baseScenario, startIndex, endIndex, scenarioSetId, scenarioId, numSubRisks, isInMemory, risksFilePath)    

    prursg.Xml.configureJava(true);                            
    
    inData = load(risksFilePath);
    baseModelRiskDrivers = inData.risks(startIndex:endIndex);
            
    fileName = fullfile(pwd(), 'Cache', ['chunk' num2str(batchIndex) '.mat']);
    chunks = load(fileName);                        

    matData = cell2mat(chunks.chunks);                
    matData = matData(:, :);

    wissChunks = wiss.makeStochasticOutputs(baseModelRiskDrivers, baseScenario, matData, numSubRisks(startIndex:endIndex));                    
    saveResults(batchIndex, baseModelRiskDrivers, scenarioSetId, scenarioId, mat2cell(wissChunks, size(wissChunks, 1), numSubRisks(startIndex:endIndex, 1)'), 0, isInMemory);    
end
