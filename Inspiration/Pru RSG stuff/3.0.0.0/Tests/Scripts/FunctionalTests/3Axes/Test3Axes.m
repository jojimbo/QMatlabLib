% These tests cover Three Axes Testing.
% Update the app.config file if necessary.

function test_suite = Test3Axes()
    initTestSuite;            
end


% Tests whether 3 axes data can be serialised to the MDS and deserialised
% from the MDS.
function testMdsSerialisation()

    ClearMds();
    ds = CreateTestDataSeries();        
    
    dao = prursg.HistoricalDAO.DbHistoricalDataDao();    
    dao.WriteData(ds);
    
    dsRead = dao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);
    
    assertTrue(ds == dsRead);    
    
end

% Tests whether 3 axes data can be serialised to a xml file and deserialised from a xml file.
function testXmlSerialisation()

    
    ds = CreateTestDataSeries();        
    
    dao = prursg.HistoricalDAO.XmlHistoricalDataDao();    
    dao.WriteData(ds);
    
    dsRead = dao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);
    dsRead.Status  = 1;
    
    assertTrue(ds == dsRead);    
    
end

% Tests an end to end process(Xml -> Mds)
function testXmlToMds()

    ClearMds();
    
    ds = CreateTestDataSeries();        
        
    xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();            
    xmlDao.WriteData(ds);
    dsXml = xmlDao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);
    assertTrue(~isempty(dsXml));
    dsXml.Status  = 1;          
    
    mdsDao = prursg.HistoricalDAO.DbHistoricalDataDao();    
    mdsDao.WriteData(dsXml);
    
    dsMds = mdsDao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);
    
    assertTrue(dsXml == dsMds);    
end

%Tests an end to end process ( MDS - > Xml)
function testMdsToXml()

    ClearMds();
    ds = CreateTestDataSeries();        
    
    mdsDao = prursg.HistoricalDAO.DbHistoricalDataDao();    
    mdsDao.WriteData(ds);
    
    dsMds = mdsDao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);
    
    xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();            
    xmlDao.WriteData(dsMds);
    dsXml = xmlDao.PopulateData('Test3Axes', [], [], '01/Jan/2010', [], [], [], [], [], []);    
    dsXml.Status  = 1;          
    
    assertTrue(dsMds == dsXml);
    
end

%% Helper Methods.

% Create test data.
function [ds3] = CreateTestDataSeries()

    dataSeries = prursg.Engine.DataSeries();
    dataSeries.Name = 'Test3Axes';    
    dataSeries.Status = 1;
    
    properties = prursg.Engine.DynamicProperty.empty();
    p1 = prursg.Engine.DynamicProperty();
    p1.Name = 'StringProperty';
    p1.Type = 'string';
    p1.Value = 'StringValue';
    properties(1) = p1;
    p2 = prursg.Engine.DynamicProperty();
    p2.Name = 'NumericProperty';
    p2.Type = 'number';
    p2.Value = 234.232322323;
    properties(2) = p2;    
    dataSeries.SetDynamicProperties(properties);
        
    axes = prursg.Engine.Axis.empty();
    axis = prursg.Engine.Axis();
    axis.title = 'Term';
    axis.values = {1 2 3};
    axes(1) = axis;
    
    axis1 = prursg.Engine.Axis();
    axis1.title = 'Tenor';
    axis1.values = {4 5 6 7};
    axes(2) = axis1;
    
    axis2 = prursg.Engine.Axis();
    axis2.title = 'Strike';
    axis2.values = {100 200 300 400 500};
    axes(3) = axis2;
    
    
    dataSeries.axes = axes;
    
    dataSeries.dates = {'01/Jan/2010'; '02/Jan/2010'};
    dataSeries.effectiveDates = {'01/Jan/2010'; '01/Jan/2010'};
    
    
    values1(1, :, :) = [1 2 3 4 5; 6 7 8 9 10; 11 12 13 14 15; 16 17 18 19 20];
    values1(2, :, :) = values1(1, :, :) + 20;
    values1(3, :, :) = values1(1, :, :) + 40;
    
    values2(1, :, :) = values1(1, :, :) + 60;
    values2(2, :, :) = values1(1, :, :) + 80;
    values2(3, :, :) = values1(1, :, :) + 100;
       
        
    dataSeries.values{1, 1} = values1;
    dataSeries.values{2, 1} = values2;
       
    ds3 = dataSeries;    
      
end

% Clear MDS data.
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