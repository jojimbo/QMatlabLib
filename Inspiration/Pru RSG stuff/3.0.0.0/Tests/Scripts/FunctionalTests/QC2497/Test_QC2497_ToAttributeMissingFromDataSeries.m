function test_suite = Test_QC2497_ToAttributeMissingFromDataSeries()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestToAttributeMissingFromDataSeries()

    disp('Executing test Test_QC2497_ToAttributeMissingFromDataSeries');
    
    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_ToAttributeMissingFromDataSeries.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:ToAttributeMissingFromDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the "to" attribute is missing');
end


