function [UserMsg ScenSetID] = RSGSimulate(XMLFilePath, nBatch)
    tic;
    
    try        
        disp([datestr(now) ' - Simulation Started']);
        
        import prursg.Xml.*;                 
        fprintf('Main - reading XML model file ''%s'' \n', XMLFilePath);
        
        nBatch = prursg.Util.ConfigurationUtil.GetNoOfBatches();
        
        filePath = prursg.Util.ConfigurationUtil.GetInputPath(XMLFilePath);
        controlFile = ControlFile.ControlFileFactory.create(filePath);
        
        allInOne = controlFile.is_in_memory;
        if (controlFile.is_in_memory == 1 &&  prursg.Util.ConfigurationUtil.GetUseGrid())               
            
            schedulerType = prursg.Util.ConfigurationUtil.GetSchedulerType();
            if strcmpi(schedulerType, 'generic')
                results = SubmitDistributedJob(@RSGSimulateMain, 2, {filePath, nBatch, [], allInOne}, prursg.Util.ConfigurationUtil.GetSymphonyInMemoryProcessingAppName());
            else
                results = SubmitDistributedJob(@RSGSimulateMain, 2, {filePath, nBatch, [], allInOne});
            end
            UserMsg = results{1, 1};
            ScenSetID = results{1, 2};
            
        else                        
            [UserMsg ScenSetID] = RSGSimulateMain(filePath, nBatch, controlFile, allInOne);
        end        
    catch ME
        UserMsg = sprintf('Main - Warning: Error during RSGSimulate run:\n%s', getReport(ME));
        disp(UserMsg);
    end    
    toc;
    pctRunDeployedCleanup;        
end


