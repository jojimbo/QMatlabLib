function test_suite = Test_QC2497_EmptyInputDataSeries()
    initTestSuite;
end

function Setup()  
    addpath('c:\temp\iRSG');
    addpath('./Models');
    import prursg.*;
   
end


function teardown()
    
end


function TestEmptyInputDataSeries()

    disp('Executing test Test_QC2497_EmptyInputDataSeries');

    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_EmptyInputDataSeries.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:EmptyInputDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when to date exceeds the effective date');
    
    
end


