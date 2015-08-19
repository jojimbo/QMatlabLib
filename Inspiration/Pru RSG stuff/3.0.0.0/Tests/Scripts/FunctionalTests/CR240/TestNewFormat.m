
% This tests performs the test for CR240 with the new (post CR212) input xml. 
function TestNewFormat()    

    disp('Starting test for CR240 TestNewFormat');

    appConf = xmlread('app.config');                    
    appSettings = ReadAppSettings(appConf.getElementsByTagName('appSettings').item(0));
    rsgRoot = fullfile(appSettings('RSGRoot'));
    
    addpath(rsgRoot);

    import prursg.*;
        
    cm = prursg.Configuration.ConfigurationManager();
    
    pathToInputFile = fullfile(cm.AppSettings('InputFolderPath'), 'cr240_new.xml');
    
    if (exist(pathToInputFile, 'file') ~= 2)
        disp('Input folder not set as expected, should be set to:');
        disp([prursg.Util.ConfigurationUtil.GetRootFolderPath() '/Tests/FunctionalTests/CR240/']);
        assert(false);
    end
    
    db = prursg.Db.DbFacade();
    db.clearTables();    
    
    [UserMsg ScenSetID] = RSGSimulate('cr240_new.xml');    
    
    % 1. Verify that Test_pru_output_definition.xls file contain three
    % shredding group columns("Lapses", "NonMarket", "XAllRisks").    
    [UserMsg2 FolderLoc2] = RSGMakePruFiles(ScenSetID, []);

    % 1. Verify that AlgoFiles folder contains three shredding
    % files(risk_factor_shredding_Lapses.xml,
    % risk_factor_shredding_NonMarket.xml,
    % risk_factor_shredding_XAllRisks.xml).
    [UserMsg3 FolderLoc3] = RSGMakeAlgoFiles(ScenSetID, []);       
         
    disp(UserMsg2);
    disp(FolderLoc2);    
    disp('Verify that Test_pru_output_definition.xls file contain three shredding group columns("Lapses", "NonMarket", "XAllRisks").')
    
    disp(UserMsg3);
    disp(FolderLoc3);
    disp('Verify that AlgoFiles folder contains three shredding files(risk_factor_shredding_Lapses.xml, risk_factor_shredding_NonMarket.xml,risk_factor_shredding_XAllRisks.xml).');
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