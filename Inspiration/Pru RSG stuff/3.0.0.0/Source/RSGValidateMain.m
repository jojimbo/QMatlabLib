function [UserMsg valReportPath] = RSGValidateMain(scenSetName, nBatches, dataFacade)
    UserMsg = [];
    valReportPath = [];
    
    try
        disp([datestr(now) ' - Validation started.' ]);
        tic;
        
        import prursg.Xml.*;
        import prursg.Configuration.*;
        
        prursg.Xml.configureJava(true);
                
        valReportPath = prursg.Util.ConfigurationUtil.GetOutputPath(prursg.Util.OutputFolderType.Validate, scenSetName);

        if prursg.Util.FileUtil.FurtherProcessingRequired(valReportPath)
            prursg.Util.FileUtil.OverwriteOutputsIfRequired(valReportPath);
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

            %convert flattened data to cell array.        
            baseScenario = scenarioSet.getBaseScenario();

            subRisks = prursg.Util.JobUtil.getSubRisks(filteredRisks, baseScenario.expandedUniverse);
            stoValues = mat2cell(filteredData, size(filteredData, 1), subRisks(:, 1)');

            engine = prursg.Engine.ValidationEngine();
            engine.addRisk(filteredRisks);
            engine.validate(nBatches, modelFile, scenarioSet, stoValues, valReportPath);
        end
        
        toc;
        
        UserMsg = [datestr(now) ' Main - Msg: RSG validation run complete'];
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSG validation run:\n%s', getReport(ME));
    end
        
end
