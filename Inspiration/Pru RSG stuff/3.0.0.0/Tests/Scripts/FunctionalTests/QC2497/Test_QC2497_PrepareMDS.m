function Test_QC2497_PrepareMDS

    addpath('/gpfs/matlab/x1201456/iRSG');
    import prursg.*;

    ClearMds();
    
    PrepareTestData();
          
end

function PrepareTestData()        
    
    importerExec = 'run_mdsimport.sh';
    if(~isunix)        
        importerExec = 'run_mdsimport.bat';
    end
    
    importerPath = fullfile(pwd(), 'MdsImporter', importerExec);
    marketDirPath = fullfile(pwd(), 'Inputs', 'TC');
    commands = ['cd MdsImporter && ' importerPath  ' '  marketDirPath];
    system(commands);    
end

function ClearMds()

    cm = prursg.Configuration.ConfigurationManager();                
    dbSetting = cm.ConnectionStrings('MDS');     
    connection = database(dbSetting.DatabaseName,dbSetting.UserName, dbSetting.Password,...
        'oracle.jdbc.driver.OracleDriver', dbSetting.Url);
        
    
    scriptFolder = [prursg.Util.ConfigurationUtil.GetRootFolderPath() '/+prursg/+Db/+Relational']
    statements = fileread(fullfile(scriptFolder, 'MDS.sql'));
    statements = regexp(statements, ';', 'split');    
    
    for i = 1:numel(statements)
        exec(connection, statements{i});
    end
    
    close(connection);
end