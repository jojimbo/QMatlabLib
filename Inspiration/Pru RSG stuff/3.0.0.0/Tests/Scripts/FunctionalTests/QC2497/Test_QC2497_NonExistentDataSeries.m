function test_suite = Test_QC2497_NonExistentDataSeries()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestNonExistentDataSeries()

    disp('Executing test Test_QC2497_NonExistentDataSeries');

    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_NonExistentDataSeries.xml'));    
        
    diary off;
    
    searchTerm = 'XmlHistoricalDataDao:PopulateDataSeriesContent:NoFilesFoundForDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when no files were found for a particular data series');

end


