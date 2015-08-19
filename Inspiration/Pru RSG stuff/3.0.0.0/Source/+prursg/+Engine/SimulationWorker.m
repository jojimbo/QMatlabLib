classdef SimulationWorker < handle
    % this is a class that gets instantiated at the worker level,
    % it receives all inputs required to perform a simulation and
    % holds results of junior models in memory for use in a senior
    % model
    
    properties (Access = public)
        batchID % batch ID
        riskFactors % cell array of all instantiated risk factors
        currentRisk % risk object currently being simulated
        corrNums % relevamt slice of correlated random numbers
        indexResolver % maps a risk name to its corrNums columns
        simOutputs % local cells of all risk factor simulation results        
        monteCarloNumber
        is_in_memory
        scenarioSetId
        scenarioId    
        rootFolder
    end
    
    methods
        function obj = SimulationWorker(localBatchID, risks, randInputs, resolver, monteCarloNumber, is_in_memory, scenarioSetId, scenarioId, rootFolder, risksFilePath)                                                
            fprintf('SimulationWorker - Msg: Constructor called \n');
            % SimulationWorker - constructor
            
            obj.rootFolder = rootFolder;
            
            inData = load(risksFilePath);
            risks = inData.risks;
            
            obj.batchID = localBatchID;
            obj.riskFactors = risks;
            obj.corrNums = randInputs;
            obj.indexResolver = resolver;
            obj.simOutputs = cell(1,length(risks));              
            obj.monteCarloNumber = monteCarloNumber;
            
            obj.is_in_memory = is_in_memory;
            obj.scenarioSetId = scenarioSetId;
            obj.scenarioId = scenarioId;
        end
        
        function simulate(obj)
            fprintf('SimulationWorker - Msg: Simulate method called \n');
            
            try
                obj.indexResolver.setCorrelatedRandomNumbers(obj.corrNums);
                
                % perform simulation of risk factors
                maxSeniority = 0; % zero by default
                for i = 1:numel(obj.riskFactors)
                    maxSeniority = max(obj.riskFactors(i).seniority, maxSeniority);
                end
                for i = 0:maxSeniority
                    for j = 1 : length(obj.riskFactors)
                        risk = obj.riskFactors(j);
                        obj.currentRisk = risk;
                        if (risk.seniority == i)              
                            stochasticInputs = obj.indexResolver.getStochInputs(risk.name);
                            outputs = risk.model.simulate(obj, stochasticInputs);
                            if size(outputs,1) ~= size(obj.corrNums,1)
                                fprintf(['SimulationWorker - WARNING: sim results of risk ' num2str(j) ' need to be transposed \n']);
                            end
                            if size(outputs,2) ~= risk.model.getNumberOfStochasticOutputs()
                                fprintf(['SimulationWorker - WARNING: number sub risk results of risk ' num2str(j) ' not equal to size of initial value \n']);
                            end
                            
                            % Stochastic risk model output must be available to all the (dependant) 
                            % risk models (a model may retrieve the stochastic output of any other model). 
                            % Seniority processing order ensures dependencies are processed first.
                            obj.simOutputs{j} = outputs;
                        end
                    end
                end  

                % save results in local file system
                obj.saveResults(fullfile(obj.rootFolder,'simResults'),obj.simOutputs);
            catch ex
                disp(getReport(ex));
            end
        end
        
        function riskSimResults = getSimResults(obj, riskFactorName)
            % get simulation results of another risk factor
            riskFactorIndex = obj.getRiskFactorIndex(riskFactorName);
            riskSimResults = obj.simOutputs{riskFactorIndex};
        end
        
        function riskInitVal = getInitVal(obj, riskFactorName)
            % get initial value of another risk factor
            riskFactorIndex = obj.getRiskFactorIndex(riskFactorName);
            riskInitVal = obj.riskFactors(riskFactorIndex).model.initialValue;
        end
        
        function riskFactorIndex = getRiskFactorIndex(obj,riskFactorName)
            % mapping between a risk factor name and it's position
            for i = 1:length(obj.riskFactors)
                riskName = obj.riskFactors(i).name;
                if strcmp(riskName,riskFactorName)
                    riskFactorIndex = i;
                end
            end
        end
        
        function allResults = getSimResultsArray(obj)
            % pull results out of individual cells and put into an array
            allResults = [];
            for i = 1:length(obj.simOutputs)
                allResults = [allResults obj.simOutputs{i}];
            end
        end
        
        function precedents = getCurrentRiskPrecedents(obj)
            % pull out the precedents of the risk factor currently being
            % simulated
            precedents = obj.currentRisk.model.getPrecedentNames();
        end
        
        function saveResults(obj, folderName, data)
            disp([datestr(now) ' - Saving results(BatchId-' num2str(obj.batchID)  ')...']);               
            db = prursg.Db.DataFacadeFactory.CreateFacade(obj.is_in_memory);
            r = prursg.Db.DataFacadeFactory.CreateRiskFactor(obj.is_in_memory);
            db.riskNameToIdResolver = r.makeRiskNameToIdResolver(db.dao);
            
            data = db.storeScenarioChunk( ...
            obj.monteCarloNumber, ...
            obj.riskFactors, obj.scenarioSetId, obj.scenarioId, ...
            data ...
            );
        
            % utility function
            % used for saving simulation results of a batch onto file
            % system            
            if(obj.is_in_memory)
                fname = fullfile( folderName, sprintf( 'simResults_B%d', obj.batchID ) );                
                save(fname, 'data', prursg.Util.FileUtil.GetMatFileFormat());
            end
        
            disp([ datestr(now) ' - Saved results(BatchId-' num2str(obj.batchID)  ')...']);
        end        
    end % methods
end

