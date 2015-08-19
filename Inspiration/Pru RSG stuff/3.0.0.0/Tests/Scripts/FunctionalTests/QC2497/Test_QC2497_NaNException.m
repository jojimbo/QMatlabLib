function test_suite = Test_QC2497_NaNException()
    initTestSuite;
end

function Setup() 
    addpath('c:\temp\iRSG');
    addpath('./Models');
    import prursg.*;
   
end


function teardown()
    
end


function TestNaNException()

    disp('Executing test Test_QC2497_NaNException');

    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_NaNException.xml'));  
        
    diary off;
    
    searchTerm = 'BaseHistoricalDataDao:CheckNaNValues';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when to date exceeds the effective date');
    
    
end


