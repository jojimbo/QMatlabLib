function [UserMsg algoFilesPath] = RSGMakeAlgoFiles(scenSetName, scenDates)
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
    
    nBatches = prursg.Util.ConfigurationUtil.GetNoOfBatches();
    dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(0);  
    [UserMsg algoFilesPath] = RSGMakeAlgoFilesMain(scenSetName, scenDates, nBatches, dataFacade);
    
    pctRunDeployedCleanup;
end

