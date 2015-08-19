function [UserMsg algoFilesPath] = RSGMakeAlgoScenarioFileMain( scenSetName, nBatches, dataFacade )
    UserMsg = [];
    algoFilesPath = [];
    
    try
        
        import prursg.Xml.*;
        import prursg.Configuration.*;
        
        prursg.Xml.configureJava(true);
        
        algoFilesPath = prursg.Util.ConfigurationUtil.GetOutputPath(prursg.Util.OutputFolderType.AlgoScenario, scenSetName);
        
        if prursg.Util.FileUtil.FurtherProcessingRequired(algoFilesPath)
            prursg.Util.FileUtil.OverwriteOutputsIfRequired(algoFilesPath);
            % read scenario set        
            fprintf('Main - reading scenario set ''%s'' \n', scenSetName);
            [modelFile scenarioSet stoValues riskIds stochasticScenarioId job nBatches] = dataFacade.readScenarioSet(scenSetName, nBatches);               


            %convert flattened data to cell array.
            subRisks = prursg.Util.JobUtil.getSubRisks(modelFile.riskDrivers, scenarioSet.getBaseScenario().expandedUniverse);
            stoValues = mat2cell(stoValues, size(stoValues, 1), subRisks(:, 1)');

            % format scenario set into Algo Scenario file
            fprintf('Main - making algo files \n');
            sess_date = prursg.Util.DateUtil.ReplaceLeapDate(scenarioSet.sess_date);
            prursg.Algo.generateStocasticFile(modelFile.riskDrivers, scenarioSet, ...
                modelFile.basecurrency, sess_date, stoValues, modelFile.scenario_type_key, algoFilesPath);
            
        end
                                       

        UserMsg = 'Main - Msg: RSG Scenario File generation complete';        
                
    catch ME        
        UserMsg = sprintf('Main - Warning: Error during RSG algo file generation run:\n%s', getReport(ME));
        disp(UserMsg);
    end
end


