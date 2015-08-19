function test_suite = Test_QC2497_FromToDateValidation()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestFromToDateValidation()

    disp('Executing test Test_QC2497_FromToDateValidation');
    
    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_FromToDateValidation.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:FromDateExceedingToDate';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when to date exceeds the effective date');
end


