function [UserMsg valReportPath] = RSGValidate(scenSetName)
    import prursg.Xml.*;
    prursg.Xml.configureJava(true);
    
    nBatches = prursg.Util.ConfigurationUtil.GetNoOfBatches();
    dataFacade = prursg.Db.DataFacadeFactory.CreateFacade(0);
    [UserMsg valReportPath] = RSGValidateMain(scenSetName, nBatches, dataFacade);
    
    pctRunDeployedCleanup;
end

