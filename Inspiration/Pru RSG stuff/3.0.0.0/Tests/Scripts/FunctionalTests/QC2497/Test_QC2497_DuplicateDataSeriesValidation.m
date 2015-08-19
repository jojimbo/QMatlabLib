function test_suite = Test_QC2497_DuplicateDataSeriesValidation()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestDuplicateDataSeriesValidation()

    disp('Executing test Test_QC2497_DuplicateDataSeriesValidation');

    diary tempFileName.txt;

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_DuplicateDataSeriesValidation.xml'));  
        
    diary off;
    
    searchTerm = 'XMLHistoricalDataDao:HandleDataSeries:DuplicateDataSeriesFound';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when duplicate series were found');   

end


