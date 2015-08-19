function test_suite = Test_QC2497_ToEffectiveDateValidation()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestToEffectiveDateValidation()

    disp('Executing test Test_QC2497_ToEffectiveDateValidation');

    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_ToEffectiveDateValidation.xml'));  
        
    diary off;
    
    searchTerm = 'BootstrapEngine:ProcessBootstrapItem:ToDateExceedingEffectiveDate';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when to date exceeds the effective date');
    
    
end


