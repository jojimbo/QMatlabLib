
% This test implements the test for CR240 and QC2393 by using old(pre-CR212) input xml format.
function TestOldFormat()    

    disp('Starting test for CR240 TestOldFormat');

    appConf = xmlread('app.config');                    
    appSettings = ReadAppSettings(appConf.getElementsByTagName('appSettings').item(0));
    rsgRoot = fullfile(appSettings('RSGRoot'));
    
    addpath(rsgRoot);
    import prursg.*;
        
    cm = prursg.Configuration.ConfigurationManager();
    
    pathToInputFile = fullfile(cm.AppSettings('InputFolderPath'), 'cr240_old.xml');
    
    if (exist(pathToInputFile, 'file') ~= 2)
        disp('Input folder not set as expected, should be set to:');
        disp([prursg.Util.ConfigurationUtil.GetRootFolderPath() '/Tests/FunctionalTests/CR240/']);
        assert(false);
    end
    
    pathToARAReport = '/Tests/FunctionalTests/CR240/ARAReports/CR240.csv';
    fullARAReportLocation = [prursg.Util.ConfigurationUtil.GetRootFolderPath() pathToARAReport];
    
    db = prursg.Db.DbFacade();
    db.clearTables();    
    
    [UserMsg ScenSetID] = RSGSimulate('cr240_old.xml');
    [UserMsg ScenSetID] = RSGRunCS('cr240_old.xml', fullARAReportLocation, 1, 'Exponential', []);
    
    % 1. Verify that Test_pru_output_definition.xls file contain a column "Risk Group".
    % 2. Verify that each pru file contain the scenario ++Singapore.
    RSGMakePruFiles(ScenSetID, []);
    
    % 1. Verify that AlgoFiles folder contains risk_factor_shredding.xml
    % file containing NMKT risk factor group.
    RSGMakeAlgoFiles(ScenSetID, []);       
end

function settings = ReadAppSettings(node)
    settings = containers.Map('KeyType', 'char', 'ValueType', 'char');
    settingNodeList = node.getElementsByTagName('setting');
    if ~isempty(settingNodeList)                
        for i = 0:settingNodeList.getLength() - 1
            settings(char(settingNodeList.item(i).getAttributes().getNamedItem('key').getNodeValue())) = ...
                char(settingNodeList.item(i).getAttributes().getNamedItem('value').getNodeValue());
        end                            
    end
end 
