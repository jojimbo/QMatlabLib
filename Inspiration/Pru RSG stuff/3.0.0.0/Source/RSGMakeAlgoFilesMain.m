function [UserMsg algoFilesPath] = RSGMakeAlgoFilesMain(scenSetName, scenDates, nBatches, dataFacade)
    UserMsg = [];
    algoFilesPath = [];
    
    try
        disp([datestr(now) ' MakeAlgoFiles started.']);
        
        import prursg.Xml.*;
        import prursg.Configuration.*;
        
        prursg.Xml.configureJava(true);
        
        tic;
        
        algoFilesPath = prursg.Util.ConfigurationUtil.GetOutputPath(prursg.Util.OutputFolderType.Algo, scenSetName);                
        
        if prursg.Util.FileUtil.FurtherProcessingRequired(algoFilesPath)
            prursg.Util.FileUtil.OverwriteOutputsIfRequired(algoFilesPath);

            % read scenario set
            fprintf('Main - reading scenario set ''%s'' \n', scenSetName);

            [modelFile scenarioSet stoValues riskIds stochasticScenarioId job nBatches] = dataFacade.readScenarioSet(scenSetName, nBatches);                                                

            % Filter suppressed risk entries. 
            % Some risk model output is merely a function of others. 
            % The dependant risk may not itself have an entry in the
            % correlation matrix and it's dependencies are not required in the
            % output. 
            [filteredRisks, filteredData] =...
                modelFile.filterSuppressedRisks(modelFile.riskDrivers, stoValues);
            
            % format scenario set into pru aggregator files
            fprintf('Main - making algo files \n');
            sess_date = prursg.Util.DateUtil.ReplaceLeapDate(scenarioSet.sess_date);
            run_date = prursg.Util.DateUtil.ReplaceLeapDate(modelFile.run_date);
            prursg.Algo.generateAlgoFiles(...
                filteredRisks, scenarioSet, modelFile.basecurrency, ...
                sess_date, run_date, filteredData, modelFile.scenario_type_key, algoFilesPath);
        end
        
        toc;
        
        UserMsg = [datestr(now) ' Main - Msg: RSG algo file generation complete'];
    catch ME        
        UserMsg = sprintf('Main - Warning: Error during RSG algo file generation run:\n%s', getReport(ME));
        disp(UserMsg);
    end
end
