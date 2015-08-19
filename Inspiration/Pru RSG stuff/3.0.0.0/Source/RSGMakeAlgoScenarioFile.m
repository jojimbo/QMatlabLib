function [UserMsg algoFilesPath] = RSGMakeAlgoScenarioFile(scenSetName)
    error('The RSGMakeAlgoScenarioFile function is no longer supported');
    
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
    
    nBatches = prursg.Util.ConfigurationUtil.GetNoOfBatches();
    dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(0);  
    [UserMsg algoFilesPath] = RSGMakeAlgoScenarioFileMain(scenSetName, nBatches, dataFacade);
    pctRunDeployedCleanup;
end

