function test_suite = Test_QC2497_FromAttributeMissingFromDataSeries()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestFromAttributeMissingFromDataSeries()

    disp('Executing test Test_QC2497_FromAttributeMissingFromDataSeries');
    
    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_FromAttributeMissingFromDataSeries.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:FromAttributeMissingFromDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the "from" attribute is missing');
end


