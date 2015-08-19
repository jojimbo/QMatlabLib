function [UserMsg ScenSetID dataFacade] = RSGRunUDS(modelFile, isInMemory)
    
        disp([datestr(now) ' - UDS simulation started.']);
        import prursg.Xml.*;
        
        dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(isInMemory);        
        [jobId riskNameToIdMap] = dataFacade.storeJob(modelFile, now(), now());
        ScenSetList = {};

        % loop over all specified user defined scenarios
        for i = 1:numel(modelFile.user_defined_sets)
            
            uds = modelFile.user_defined_sets(i);
                                    
            [scenarioSetId scenarioId] = dataFacade.storeScenarioSet( ...
                jobId, uds, modelFile.scenario_set_type, ...
                modelFile.scenario_type_key, uds.stochasticScenarios, 1, modelFile.riskDrivers);
            
            modelFile.scenarioSetId = scenarioSetId;
            modelFile.scenarioId = scenarioId;
        
            mcNumber = 0;
            for i = 1: numel(scenarioId)
                simulationOutputs = uds.makeStochasticOutputs(modelFile.riskDrivers, i);                
                if ~isempty(simulationOutputs)
                    dataFacade.storeScenarioChunk( ...
                    mcNumber, ...
                    modelFile.riskDrivers, scenarioSetId, scenarioId(i), ...
                    simulationOutputs ...
                    );
                    mcNumber = mcNumber + size(simulationOutputs{1}, 1);
                end                
            end   
            
            dataFacade.convertScenarioSet(scenarioSetId);
        end
                
        % return the unique scenario set identifier(s)
        for i = 1:numel(modelFile.user_defined_sets)
            ScenSetList(i) = {modelFile.user_defined_sets(i).name};
        end
        
        ScenSetID = ScenSetList{1,1};
        UserMsg = 'Main - Msg: RSG UDS run complete';    
end