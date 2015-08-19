function test_suite = Test_QC2497_ToDateAttributeMissingFromDataSeriesWithinItem()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestToDateAttributeMissingFromDataSeriesWithinItem()

    disp('Executing test Test_QC2497_ToDateAttributeMissingFromDataSeriesWithinItem');
    
    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_ToDateAttributeMissingFromDataSeriesWithinItem.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:ToAttributeMissingFromDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when to date exceeds the effective date');
end


