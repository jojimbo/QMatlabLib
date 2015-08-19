function [UserMsg ScenSetId] = RSGChained(modelFile, nBatches, dataFacade)
    %RSGCHAINED Run Simulation, Validation, MakePruFiles,
    %MakeAlgoFiles in one go

    UserMsg = [];
    ScenSetId = [];
    
    try
        scenSetsToIterateOver = [];
        
        switch modelFile.scenario_type_key
            case {1,8}
                scenSetsToIterateOver = modelFile.base_set;
            case {2,3}
                scenSetsToIterateOver = modelFile.what_if_sets;
            case {4,7,5,6}
                scenSetsToIterateOver = modelFile.user_defined_sets;
        end
        
        %foreach scenSetName (created in memory) do the following
        for scenarioSet = 1:length(scenSetsToIterateOver)
            [ValUserMsg valReportPath] = RSGValidateMain(scenSetsToIterateOver(scenarioSet).name, nBatches, dataFacade);

            %Run Validation
            disp(ValUserMsg);
            disp(['Validation files path: ' valReportPath]);

            %Make Aggregator format RSG files
            [PruUserMsg pruFilesPath] = RSGMakePruFilesMain(scenSetsToIterateOver(scenarioSet).name, '', nBatches, dataFacade, true);
            disp(PruUserMsg);
            disp(['Pru files path: ' pruFilesPath]);

            %Make Algo Files
            [AlgoUserMsg algoFilesPath] = RSGMakeAlgoFilesMain(scenSetsToIterateOver(scenarioSet).name, '', nBatches, dataFacade);
            disp(AlgoUserMsg);
            disp(['Algo files path: ' algoFilesPath]);
            
            ScenSetId = scenSetsToIterateOver(scenarioSet).name;
                        
            
            UserMsg = [char(10) ValUserMsg char(10) PruUserMsg char(10) AlgoUserMsg];
        end
    catch ME
        UserMsg = getReport(ME);
    end
end
