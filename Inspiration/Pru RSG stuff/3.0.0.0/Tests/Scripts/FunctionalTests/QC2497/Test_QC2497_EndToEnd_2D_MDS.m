function test_suite = Test_QC2497_EndToEnd_2D_MDS()
    initTestSuite;
end

function Setup()
    addpath('/gpfs/matlab/x1201456/iRSG/');
    addpath(fullfile(pwd(), 'Models'));
    import prursg.*;
    
    Test_QC2497_PrepareMDS()
    
end


function teardown()
    
end


function TestEndToEnd_2D()

    disp('Executing test Test_QC2497_EndToEnd_2D');
    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_EndToEnd_2D.xml'));    
    
    dbDao = prursg.HistoricalDAO.DbHistoricalDataDao();
    dbResults = dbDao.PopulateData('EndToEnd_2D', [], [], '30/Nov/2011', [], [], [], [], [], []);
    xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
    xmlDao.InputDir = fullfile(pwd(), 'Outputs');
    xmlResults = xmlDao.PopulateData('EndToEnd_2D', [], [], '30/Nov/2011', [], [], [], [], [], []);
    xmlResults.Status = 2;
    xmlResults.Purpose = '';
    assertTrue(dbResults == xmlResults);

end


