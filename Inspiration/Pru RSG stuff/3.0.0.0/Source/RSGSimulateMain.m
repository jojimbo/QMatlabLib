function [UserMsg ScenSetID] = RSGSimulateMain(XMLFilePath, nBatch, modelFile, allInOne)
    try        

        UserMsg = [];
        ScenSetID = [];
        
        if ~exist('Cache', 'dir')
            mkdir('Cache');
        end

        import prursg.Xml.*;

        if ~exist('simResults', 'dir')
            mkdir simResults
        end

                
        % instantiate a model file object from XML model file
        if isempty(modelFile)
            fprintf('Main - reading XML model file ''%s'' \n', XMLFilePath);
            modelFile = ControlFile.ControlFileFactory.create(XMLFilePath);
        end

        
        if (allInOne)
            if (modelFile.scenario_type_key ~= 2)
               disp('Msg: Running in ''In-Memory mode''');
                [SimUserMsg ScenSetID dataFacade] = RSGSimulateIntermediate(modelFile, nBatch, 1);
                [ChainUserMsg ScenSetID] = RSGChained(modelFile, nBatch, dataFacade);                
                UserMsg = [char(10) ChainUserMsg char(10) SimUserMsg];
            else
                UserMsg = 'Error: What-If simulation whilst in ''In-Memory'' mode is not supported';
            end
        else
            [UserMsg ScenSetID] = RSGSimulateIntermediate(modelFile, nBatch, 0);
        end
        
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSGSimulate run:\n%s', getReport(ME));
    end
end

function [UserMsg ScenSetID dataFacade] = RSGSimulateIntermediate(modelFile, nBatch, isInMemory)
    UserMsg = [];
    ScenSetID = [];
    dataFacade = [];
    
    try
        %limiting the simulation size to prevent RSG from inserting massive
        %data to the database.
        LimitSimulationSize(modelFile, isInMemory);
        
        %modelFile.num_simulations = 100;
        switch modelFile.scenario_type_key
            case {1,8}
                [UserMsg ScenSetID dataFacade] = RSGSimulateBase(modelFile, nBatch, isInMemory);
            case {2,3}
                [UserMsg ScenSetID dataFacade] = RSGRunWhatIf(modelFile, nBatch, isInMemory);
            case {4,7,5,6}
                [UserMsg ScenSetID dataFacade] = RSGRunUDS(modelFile, isInMemory);
        end
        
 catch ME
        UserMsg = sprintf('Main - Warning: Error during RSGSimulate run:\n%s', getReport(ME));
        disp(UserMsg);
    end
end       
% Limit simulation size so that the RSG isn't generating the massive data
% to be stored in the database. 
function LimitSimulationSize(modelFile, isInMemory)

    if ~isInMemory
        import prursg.Configuration.*;    

        cm = prursg.Configuration.ConfigurationManager();                
        maxSimulationSize = 0;                      
        if isKey(cm.AppSettings, 'MaxSimulationSize')
            maxSimulationSize = str2num(cm.AppSettings('MaxSimulationSize'));
        end

        modelScenarioSize = 0;
        if(maxSimulationSize > 0)
            switch(modelFile.scenario_type_key)
                case {1, 8} %base     
                    subRisks = prursg.Util.JobUtil.getSubRisks(modelFile.riskDrivers, modelFile.base_set.scenarios(end).expandedUniverse);   
                    modelScenarioSize = modelFile.num_simulations * sum(subRisks(:, 1));
                case {2, 3} %whatif                
                    dataFacade = prursg.Db.DataFacadeFactory.CreateDataFacade(0);
                    baseModelFile = dataFacade.readModelFile(modelFile.what_if_sets_base_set_name);
                    subRisks = prursg.Util.JobUtil.getSubRisks(baseModelFile.riskDrivers, baseModelFile.base_set.scenarios(end).expandedUniverse);   
                    modelScenarioSize = baseModelFile.num_simulations * sum(subRisks(:, 1));
                case {4, 7, 5, 6} %uds
                    if numel(modelFile.user_defined_sets) > 0
                        numScenarios = sum(arrayfun(@(x)numel(x.scenarios), modelFile.user_defined_sets));
                        subRisks = prursg.Util.JobUtil.getSubRisks(modelFile.riskDrivers, modelFile.user_defined_sets(1).scenarios(end).expandedUniverse);   
                        modelScenarioSize = numScenarios * sum(subRisks(:, 1));
                    end                
            end

            if (modelScenarioSize > maxSimulationSize)
                exception = MException('RSGSimulate:LimitSimulationSize', 'The simulation size exceeds the max size.');
                throw(exception);
            end
        end
    end    
end
