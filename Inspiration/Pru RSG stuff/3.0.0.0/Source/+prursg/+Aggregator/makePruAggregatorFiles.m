function makePruAggregatorFiles(fileID, scenarioType, whatIfFlag, dates, riskUniverse, detValues, stoValues, noRiskValues, nBatches, scenarioSet, shockDate, shockValues, pruFilesPath, isInMemory)

    % Inputs:
    % fileID = string that gets appended at the front of each output file
    % dates = cell array of dates
    % riskUniverse = info on risk driver names row 1 = risk factor name, row 2
    %              = expanded risk name, row 3 = risk driver type
    % detValues = array of deterministic values, there should be as many det value rows as there are dates
    % stoValues = array of stochastic values, the rest are all stochastic scenario values
    
    % Note:
    % 1) assume that XML model file respects some ordering rule of credit
    % and volatility risk factor (in general ordering is first ratings or moneyness then term then
    % tenor)
    % 2) ScenName hard coded until XML contains such info
      
    
    % retrieve scenario value format.
    SCENARIO_VALUE_FORMAT = prursg.Util.ConfigurationUtil.GetScenarioValueNumberFormat();
            
    % define set of main risk groups in aggregator
    riskTypes = {'creditspreads' 'fxrates' 'indexvols' 'indices' 'swaptionvols' 'yieldcurves'};
    
    % define file path for results of each risk group
    for i = 1:length(riskTypes)
        fname{i} = fullfile(pruFilesPath, [fileID riskTypes{i} '.csv']);
    end
    
    % determine number of det and sto values
    numDet = size(detValues,1);
    numNoRisk = ~isempty(scenarioSet.noRiskScenario);
    numSto = size(stoValues,1);
    
    nSims = numDet + whatIfFlag + numNoRisk + numSto;
    nSimsLocal = zeros(1, nBatches);    
    for batchIndex = 1:nBatches
        if batchIndex == nBatches
            nSimsLocal(batchIndex) = nSims - (nBatches-1)*floor(nSims/nBatches);
        else
            nSimsLocal(batchIndex) = floor(nSims/nBatches);
        end
    end
    
    startIndex = 0;
    endIndex = 0;
    % create first 4 columns which are common to all files
    Prefixes = cell(4, nSims);
    Prefixes(1, 1:numDet) = mat2cell(zeros(1, numDet), 1, ones(1, numDet));
    Prefixes(2, 1:numDet) = {'"assets"'}; 
    if whatIfFlag
        if scenarioType == 2
            startIndex = startIndex + 1;
        end
        Prefixes(1, numDet + 1) = {startIndex};
        Prefixes{2, numDet + 1} = '"__shockedBase"';
    end    
    
    if numNoRisk > 0
        startIndex = startIndex + 1;
        Prefixes(1, numDet + whatIfFlag + 1) = {startIndex};
        Prefixes(2, numDet + whatIfFlag + 1) = {'"__noriskscr"'};        
    end
            
    endIndex = startIndex + numSto;
    startIndex = startIndex + 1;
    
    Prefixes(1, numDet + whatIfFlag + numNoRisk + 1: numDet + whatIfFlag + numNoRisk + numSto) = mat2cell(startIndex:1:endIndex, 1, ones(1, numSto));               
    Prefixes(2, numDet + whatIfFlag + numNoRisk + 1: numDet + whatIfFlag + numNoRisk + numSto) = {'""'};    
    Prefixes(3, 1:numDet) = mat2cell(0:1:numDet-1, 1, ones(1, numDet));
    if whatIfFlag && ~strcmpi(shockDate, dates(end))
        Prefixes{3, numDet + 1} = Prefixes{3, numDet} + 1;
        Prefixes(3, numDet + 1: end) = Prefixes(3, numDet + 1) ; 
    else
        Prefixes(3, numDet + 1: end) = Prefixes(3, numDet) ;    
    end
    
    Prefixes(4, 1:numDet) = dates(1:numDet)';
    if whatIfFlag        
        Prefixes(4, numDet + 1 : end) = {shockDate};
    else
        Prefixes(4, numDet + 1 : end) = dates(end);   
    end
    
        
    % override scenario names.
    detScenarios = scenarioSet.getDeterministicScenarios();
    if ~isempty(detScenarios)                                  
        for i = 1:numel(detScenarios)
            Prefixes(2, i) = {['"' detScenarios(i).name '"']};                 
        end                    
    end        

    if whatIfFlag        
        shockedBaseScenario = scenarioSet.getShockedBaseScenario();
        if ~isempty(shockedBaseScenario)
            Prefixes(2, numDet + 1) = {['"' shockedBaseScenario.name '"']};
        end
    end
    
    scenarioNamePrefix = GetScenarioNamePrefix(scenarioType);
    
    stoScenarios = scenarioSet.getStochasticScenarios();
    if ~isempty(stoScenarios)   
        
        target = 1;
        if scenarioType == int32(prursg.Engine.ScenarioType.CriticalScenario)
            target = 0;
        end
        
        if (numel(stoScenarios) > target)
            assert(numel(stoScenarios) == numSto, 'The no of stochastic scenarios do not match with the no of stochastic values.');
            
            stoIndex = numDet + whatIfFlag + numNoRisk + 1;
            for i = 1:numel(stoScenarios)    
                name = stoScenarios(i).name;
                if strcmpi(name, 'null')
                    name = '';
                end
                Prefixes(2, stoIndex) = {['"' scenarioNamePrefix name '"']}; 
                stoIndex = stoIndex + 1;
            end            
        end
    end        
    
    prefixFileName = fullfile(pruFilesPath, 'Prefixes.mat');
    save(prefixFileName, 'Prefixes', prursg.Util.FileUtil.GetMatFileFormat());
    
    runInGrid = (prursg.Util.ConfigurationUtil.GetUseGrid() && nBatches > 1);    
                                                                                                  
    % loop over main risk groups and write results into file
    for i = 1:length(riskTypes)
        
                        
        % organise data to be written into arrays
        results = cellfun(@(x)isequal(x, riskTypes{i}), riskUniverse(3, :));
        indexes = find(results);
                        
        header = ['Scenario' 'ScenName' 'Step' 'Date' riskUniverse(2, indexes)];                
        WriteHeader(fname{i}, riskTypes{i}, header);
        
        allValuesStore = zeros(size(indexes, 2), numDet + whatIfFlag + numNoRisk + numSto);
        allValuesStore(:, 1:numDet) = detValues(:, indexes)';
        if whatIfFlag
           allValuesStore(:, numDet + whatIfFlag) = shockValues(:, indexes)'; 
        end

        if numNoRisk
           allValuesStore(:, numDet + whatIfFlag + numNoRisk) = noRiskValues(:, indexes)';  
        end
        sum= numDet + whatIfFlag + numNoRisk ;
        allValuesStore(:, sum +1 : sum + numSto) = stoValues(:, indexes)';
        dataFileName = fullfile(pwd, 'PruFiles', 'data.mat');
        
        fileNames = {};
        
        if size(allValuesStore,1) > 0     
            [m n] = size(allValuesStore);                                    

            if( runInGrid && (m * n > 10000000)) %due to the grid overhead, only use the grid when the matrix size is greather than 10m.
                save(dataFileName, 'allValuesStore', prursg.Util.FileUtil.GetMatFileFormat());
                fileNames = mat2cell(1:nBatches, 1, ones(1, nBatches));
                fileNames = cellfun(@(x)[fname{i} '_' num2str(x)], fileNames, 'UniformOutput', 0);
                
                parentJob = getCurrentJob();                                   
                
                if isInMemory
                    job = CreateDistributedJob(prursg.Util.ConfigurationUtil.GetSymphonyAppProfileName(1));    
                else
                    job = CreateDistributedJob();
                end
                
                if ~isempty(parentJob)
                    set(job, 'PathDependencies', {prursg.Util.ConfigurationUtil.GetRSGSourceCodePath()});
                end                  
                                                  
                for batchIndex = 1:nBatches
                  % Create specific number of tasks within the job.
                  startIndex = (batchIndex - 1) * nSimsLocal(1) + 1;
                  endIndex = (batchIndex - 1) * nSimsLocal(1) + nSimsLocal(batchIndex);                                         
                  createTask(job, @writeChunkData, 0, {fileNames{batchIndex}, prefixFileName, dataFileName, startIndex, endIndex, SCENARIO_VALUE_FORMAT});
                end
                            
                alltasks = get(job, 'Tasks');
                set(alltasks, 'CaptureCommandWindowOutput', true);
                
                % Submit the job.
                submit(job);

                % Wait for the job to finish. This client actually checks the job status
                waitForState(job, 'finished');               
                outputmessages = get(alltasks, 'CommandWindowOutput');
                outputmessages{1}

                destroy(job);      

            else
                fileNames = {[fname{i} '_all']};
                WriteData(fileNames{1}, Prefixes, allValuesStore, SCENARIO_VALUE_FORMAT);                               
            end                               
        end
        
        prursg.Util.FileUtil.CombineFiles(fname{i}, fileNames);
                       
        if exist(dataFileName, 'file')
            delete(dataFileName);
        end
        
    end
    
    if exist(prefixFileName, 'file')
        delete(prefixFileName);
    end
        
end

function WriteHeader(fileName, riskType, header)
    fid = fopen(fileName, 'w');
    fprintf(fid, ['*' riskType '\r\n']);
    format = ['%s' repmat(',%s', 1, numel(header) - 1) '\r\n'];
    fprintf(fid, format, header{1, :});
    fclose(fid);
end

function WriteData(fileName, Prefixes, allValuesStore, scenarioValueFormat)
                
    % write all other rows
    fid = fopen(fileName, 'w'); 
    format = ['%g,%s,%g,%s' repmat([',' scenarioValueFormat], 1, size(allValuesStore, 1)) '\r\n'];
    for i = 1:size(allValuesStore, 2)
        fprintf(fid, format, Prefixes{1, i}, Prefixes{2, i}, Prefixes{3, i}, Prefixes{4, i},  allValuesStore(:, i));                
    end
    fclose(fid);
end

function WriteDataChunked(fileName, prefixFileName, dataFileName, startIndex, endIndex, scenarioValueFormat)
    
    
    Prefixes = load(prefixFileName, 'Prefixes');
    Prefixes = Prefixes.Prefixes(:, startIndex:endIndex);
    allValuesStore = load(dataFileName, 'allValuesStore');
    allValuesStore = allValuesStore.allValuesStore(:, startIndex:endIndex);
    
    % write all other rows    
    [fid message]= fopen(fileName, 'w');     
    format = ['%g,%s,%g,%s' repmat([',' scenarioValueFormat], 1, size(allValuesStore, 1)) '\r\n'];
    for i = 1:size(allValuesStore, 2)
        fprintf(fid, format, Prefixes{1, i}, Prefixes{2, i}, Prefixes{3, i}, Prefixes{4, i},  allValuesStore(:, i));                
    end
    fclose(fid);
end

function prefix = GetScenarioNamePrefix(scenarioType)
    prefix = '';
    
    switch scenarioType
        case int32(prursg.Engine.ScenarioType.CriticalScenario)
            prefix = '++';
    end
end

function writeChunkData(fileName, prefixFileName, dataFileName, startIndex, endIndex, scenarioValueFormat)
    try
        WriteDataChunked(fileName,prefixFileName, dataFileName, startIndex, endIndex, scenarioValueFormat);
    catch ex
        disp(getReport(ex));
    end
end
