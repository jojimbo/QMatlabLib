% These tests cover QC3223(Bootstrapping Results formatting).
% Update the app.config file if necessary.

function test_suite = TestQC3223()
    % modify this if necessary.
    addpath('/gpfs/matlab/x1201456/iRSG/');
    addpath('./Models');
    initTestSuite;        
end

% Tests configuration retrieval.
function TestConfiguration()
    assertEqual('%.9g', prursg.Util.ConfigurationUtil.GetHistoricalDataDaoNumberFormat());    
end

% Tests BootstrapEngine creation. NumberFormatSpecifier property should be
% set with the HistoricalDataDaoNumberFormat value specified in the
% configuration file.
function TestBootstrapEngineCreation()
    engine = prursg.Bootstrap.BootstrapEngine();
    assertEqual('%.9g', engine.NumberFormatSpecifier);    
end

% Tests FormatNumber function of BootstrapEngine. As the method is defined
% as a private method, This test uses a helper function replicating the
% same logic.
function TestFormatNumber()

    numberFormatSpecifier = prursg.Util.ConfigurationUtil.GetHistoricalDataDaoNumberFormat();    
    value = 234.23232123456789;
    formattedValue = prursg.Util.FormatNumber(value, numberFormatSpecifier);
    assertEqual('234.232321', formattedValue);
    numberFormatSpecifier = '%.3g';
    formattedValue = prursg.Util.FormatNumber(value, numberFormatSpecifier);
    assertEqual('234', formattedValue);
    numberFormatSpecifier = '%.5g';
    formattedValue = prursg.Util.FormatNumber(value, numberFormatSpecifier);
    assertEqual('234.23', formattedValue);    
    
end


% Tests number conversion in XmlHistoricalDataDao.
function TestXmlHistoricalDataDao()

    ds = CreateTestDataSeries();
    dao = prursg.HistoricalDAO.XmlHistoricalDataDao();
    dao.NumberFormatSpecifier = prursg.Util.ConfigurationUtil.GetHistoricalDataDaoNumberFormat();
    dao.OutputFileName = 'TestDataSeries.xml';
    dao.WriteData(ds);
    
    xml = xmlread(dao.OutputFileName);
    list = xml.getElementsByTagName('Property')
    assertEqual('234.232322', char(list.item(1).getFirstChild().getData()))

    
    list = xml.getElementsByTagName('Axis')
    values = list.item(0).getElementsByTagName('V')
    assertEqual('0.232232323', char(values.item(0).getFirstChild().getData()))
    assertEqual('234.234234', char(values.item(1).getFirstChild().getData()))
    
    values = list.item(1).getElementsByTagName('V')
    assertEqual('0.387734843', char(values.item(0).getFirstChild().getData()))
    assertEqual('9485.23423', char(values.item(1).getFirstChild().getData()))
    
    values = list.item(2).getElementsByTagName('V')
    assertEqual('2234.32423', char(values.item(0).getFirstChild().getData()))
    assertEqual('23989456.2', char(values.item(1).getFirstChild().getData()))
    
end

% Tests  number conversion in DbHistoricalDataDao
function TestDbHistoricalDataDao()

    cm = prursg.Configuration.ConfigurationManager();                
    dbSetting = cm.ConnectionStrings('MDS');     
    connection = database(dbSetting.DatabaseName,dbSetting.UserName, dbSetting.Password,...
        'oracle.jdbc.driver.OracleDriver', dbSetting.Url);
        
    ClearMds();
    
    
    ds = CreateTestDataSeries();
    dao = prursg.HistoricalDAO.DbHistoricalDataDao();
    dao.NumberFormatSpecifier = prursg.Util.ConfigurationUtil.GetHistoricalDataDaoNumberFormat();    
    dao.WriteData(ds);
    
    curs = exec(connection,'select Value from dataseries_property where Name = ''NumericProperty''');
    results = fetch(curs);
    
    assertEqual('234.232322', results.Data{1})
    
    curs = exec(connection,'select Value from dataseries_value order by dataseries_id, axis1_value');
    results = fetch(curs);
    
    assertEqual(0.232232323, results.Data{1});
    assertEqual(0.387734843, results.Data{2});
    assertEqual(2234.32423, results.Data{3});
    assertEqual(234.234234, results.Data{4});
    assertEqual(9485.23423, results.Data{5});
    assertEqual(23989456.2, results.Data{6});        
    
end


function TestBootstrap()
    engine = prursg.Bootstrap.BootstrapEngine();
    engine.NumberFormatSpecifier = '%.3g';
    engine.Bootstrap([pwd() '/bootstrapSimpleNYC.xml']);
    
    %1.Confirm that A.xml is created in the current folder.
    %2.Open A.xml and check that all V element as well as Dyanmic Property
    %whos type is number have values with three signficant digits.
end

function TestBootstrapCalibrate()
    calibrationEngine = prursg.Bootstrap.BootstrapEngine();
    calibrationEngine.NumberFormatSpecifier = '%.3g';
    outputXmlPath = calibrationEngine.Calibrate([pwd() '/bootstrapSimpleNYC.xml'])
    
    %1.Confirm that bootstrapSimpleNYC_calibrated.xml is created in the current folder.
    %2.Open bootstrapSimpleNYC_calibrated.xml and check that all numeric
    %parameters have values with three significant digits.
end


%% Helper methods.
function dataSeries = CreateTestDataSeries()

    dataSeries = prursg.Engine.DataSeries();
    dataSeries.Name = 'Test';    
    
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
    dataSeries.axes = axes;
    
    dataSeries.dates = {'01/Jan/2010', '02/Jan/2010'};
    dataSeries.effectiveDates = {'01/Jan/2010', '01/Jan/2010'};
    dataSeries.values{1} = [0.232232323, 0.387734843, 2234.324234343];
    dataSeries.values{2} = [234.23423433, 9485.23423422, 23989456.2349803];    
    
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