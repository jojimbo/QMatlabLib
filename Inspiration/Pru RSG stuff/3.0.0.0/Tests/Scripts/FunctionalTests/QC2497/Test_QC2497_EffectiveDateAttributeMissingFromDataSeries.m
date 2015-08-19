function test_suite = Test_QC2497_EffectiveDateAttributeMissingFromDataSeries()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestEffectiveDateAttributeMissingFromDataSeries()

    disp('Executing test Test_QC2497_EffectiveDateAttributeMissingFromDataSeries');
    
    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_EffectiveDateAttributeMissingFromDataSeries.xml'));  
        
    diary off;
    
    searchTerm = 'XMLHistoricalDataDao:HandleDates:EffectiveDateAttributeMissingFromDataSeries';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the effective date attribute is missing from the Data Series xml file.');
end


