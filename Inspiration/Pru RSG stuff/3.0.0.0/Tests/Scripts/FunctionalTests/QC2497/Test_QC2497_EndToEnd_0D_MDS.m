function test_suite = Test_QC2497_EndToEnd_0D_MDS()
    initTestSuite;
end

function Setup()
    addpath('/gpfs/matlab/x1201456/iRSG/');
    import prursg.*;
    
    Test_QC2497_PrepareMDS()
end


function teardown()
    
end


function TestEndToEnd_0D_MDS()

    disp('Executing test Test_QC2497_EndToEnd_0D');
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_EndToEnd_0D.xml'));    
    
    dbDao = prursg.HistoricalDAO.DbHistoricalDataDao();
    dbResults = dbDao.PopulateData('EndToEnd_0D', [], [], '30/Nov/2011', [], [], [], [], [], []);
    xmlDao = prursg.HistoricalDAO.XmlHistoricalDataDao();
    xmlDao.InputDir = fullfile(pwd(), 'Outputs');
    xmlResults = xmlDao.PopulateData('EndToEnd_0D', [], [], '30/Nov/2011', [], [], [], [], [], []);
    xmlResults.Status = 2;
    xmlResults.Purpose = '';
    assertTrue(dbResults == xmlResults);

end


