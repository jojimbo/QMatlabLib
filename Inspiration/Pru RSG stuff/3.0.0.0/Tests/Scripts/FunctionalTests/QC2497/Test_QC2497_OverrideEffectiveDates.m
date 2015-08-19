function test_suite = Test_QC2497_OverrideEffectiveDates()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    addpath('./Models');
    import prursg.*;
   
end


function teardown()
    
end


function TestOverrideEffectiveDates()

    disp('Executing test Test_QC2497_OverrideEffectiveDates');
    
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_OverrideEffectiveDates.xml'));  
    
    xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
    xmlDao.InputDir = './Outputs';
    ds = xmlDao.PopulateData('OE', [], [], '30/Nov/2011', [], [], [], [], [], []);
    assertEqual(ds.effectiveDates{1}, '30/Nov/2011');
    
end


