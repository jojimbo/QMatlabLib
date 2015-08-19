function [UserMsg pruFilesPath] = RSGMakePruFiles(scenSetName, scenDates)
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
    
    nBatches = prursg.Util.ConfigurationUtil.GetNoOfBatches();
    dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(0);
    [UserMsg pruFilesPath] = RSGMakePruFilesMain(scenSetName, scenDates, nBatches, dataFacade, false);
    
    pctRunDeployedCleanup;
end

