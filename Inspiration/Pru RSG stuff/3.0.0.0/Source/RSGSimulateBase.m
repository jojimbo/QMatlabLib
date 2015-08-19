function [UserMsg ScenSetID dataFacade] = RSGSimulateBase(modelFile, nBatch, isInMemory)
    
        import prursg.Xml.*;
        
        dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(isInMemory);        
        [jobId riskNameToIdMap] = dataFacade.storeJob(modelFile, now(), now());                      
                        
        % create a dummy stochastic scenario.
        dummyStochasticScenario = createDummyStochasticScenario(modelFile.base_set.getBaseScenario());
        modelFile.base_set.addScenario(dummyStochasticScenario);
        
        [scenarioSetId scenarioId] = dataFacade.storeScenarioSet( ...
            jobId, modelFile.base_set, ...
            modelFile.scenario_set_type, modelFile.scenario_type_key, ...            
            dummyStochasticScenario, nBatch, modelFile.riskDrivers ...
            );
                
        
        modelFile.scenarioSetId = scenarioSetId;
        modelFile.scenarioId = scenarioId;
        
        % instantiate a RSG object
        fprintf('Main - Instantiating RSG object \n');
        rsg = prursg.Engine.RSG(modelFile.riskDrivers, modelFile.correlationMatrix.values, modelFile.dependencyModel, modelFile);
    
        % simulate, results under folder simResults
        fprintf('Main - RSG simulating %g scenarios \n',modelFile.num_simulations);
        rsg.simulate(modelFile.simtimestepinmonths, modelFile.num_simulations, nBatch, modelFile.riskIndexResolver);
                
        % return simulation outputs.
        dummyStochasticScenario.simResults = rsg.simEngine.simulationOutputs;
        
        % convert scenario set data if required.
        dataFacade.convertScenarioSet(scenarioSetId);
            
                        
        
        % return the unique scenario set identifier
        ScenSetID = modelFile.base_set.name;
                
        UserMsg = 'Main - Msg: RSG base simulation run complete';    
end

function scenario = createDummyStochasticScenario(baseScenario)
    scenario = prursg.Engine.Scenario();    
    scenario.scen_step = baseScenario.scen_step;
    scenario.date = baseScenario.date;
    scenario.number = baseScenario.number;
    scenario.isStochasticScenario = 1;
end