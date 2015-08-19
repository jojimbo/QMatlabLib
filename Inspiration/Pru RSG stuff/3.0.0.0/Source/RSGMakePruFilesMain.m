function [UserMsg pruFilesPath] = RSGMakePruFilesMain(scenSetName, scenDates, nBatches, dataFacade, isInMemory)
    UserMsg = [];
    pruFilesPath = [];
    
    try
        disp([datestr(now) ' MakePruFile started.']);
                                
        import prursg.Xml.*;
        import prursg.Configuration.*;
        
        prursg.Xml.configureJava(true);
                
        pruFilesPath = prursg.Util.ConfigurationUtil.GetOutputPath(prursg.Util.OutputFolderType.Pru, scenSetName);

        if prursg.Util.FileUtil.FurtherProcessingRequired(pruFilesPath)
            prursg.Util.FileUtil.OverwriteOutputsIfRequired(pruFilesPath);
           % read scenario set                       
            fprintf('Main - reading scenario set ''%s'' \n', scenSetName);        
            [modelFile scenarioSet stoValues riskIds stochasticScenarioId job nBatches] = dataFacade.readScenarioSet(scenSetName, nBatches);    
            
            % Following the change to the Critical Scenario Engine, the
            % scenario type key could be a string. We need to check the
            % scenario type key and assign appropriatelly the variables to
            % be used.
            sstFromModel = modelFile.scenario_type_key;
            
            if (isa(modelFile.scenario_type_key, 'char'))
                stk = str2num(sstFromModel(strfind(sstFromModel, ':')+1:end));
                sstFromModel = str2num(sstFromModel(1:strfind(sstFromModel, ':')-1));
            else
                stk = sstFromModel;
            end
            
            % Aligned with MakePru files. In each case below it appears that 
            % the session date can be retrieved directly from the persisted 
            % scenario set. The sess date is stored in the scenario db by
            % dataFacade.storeScenarioSet, from what I can see it's always
            % called with the session date from the appropriate set (i.e.
            % as below) so this change should not cause any issues
            session_date = scenarioSet.sess_date;
            
            switch stk

                case {1,8,9}
                    %session_date = modelFile.base_set.sess_date;
                    whatIfFlag = 0;
                case {2,3}
                    %session_date = modelFile.what_if_sets.sess_date;
                    whatIfFlag = 1;
                case {4,7,5,6}
                    %session_date = modelFile.user_defined_sets.sess_date;
                    whatIfFlag = 0;
            end
            
            if ~isempty(session_date)                
                session_date = prursg.Util.DateUtil.ReplaceLeapDate(session_date);
            end

            % Filter suppressed risk entries. 
            % Some risk model output is merely a function of others. 
            % The dependant risk may not itself have an entry in the
            % correlation matrix and it's dependencies are not required in the
            % output. 
            [filteredRisks, filteredData] =...
                modelFile.filterSuppressedRisks(modelFile.riskDrivers, stoValues);
            
            % format scenario set into pru aggregator files
            fprintf('Main - making pru aggregator files \n');
            prursg.Aggregator.makePruFiles(session_date, sstFromModel,...
                whatIfFlag, filteredRisks, scenarioSet, filteredData,...
                nBatches, pruFilesPath, isInMemory); 
            
        end
                                
        UserMsg = [datestr(now) ' Main - Msg: RSG pru aggregator file generation complete'];
        
    catch ME        
        UserMsg = sprintf('Main - Warning: Error during RSG pru aggregator file generation run:\n%s', getReport(ME));
        disp(UserMsg);
    end
        
end


