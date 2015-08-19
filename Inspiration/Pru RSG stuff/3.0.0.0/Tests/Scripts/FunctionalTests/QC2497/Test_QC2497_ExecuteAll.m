function test_suite = Test_QC2497_ExecuteAll()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestAll()

    Test_QC2497_ContinuityFollowingException   
    Test_QC2497_CorrectXMLFileRetrieval
    Test_QC2497_CorrectXMLFileRetrievalCaseInsensitive
    Test_QC2497_DuplicateDataSeriesValidation
    Test_QC2497_EffectiveDateAttributeMissingFromDataSeries    
    Test_QC2497_EffectiveDateAttributeMissingFromItem
    Test_QC2497_EndToEnd_0D
    Test_QC2497_EndToEnd_1D
    Test_QC2497_EndToEnd_2D
    Test_QC2497_EndToEnd_3D
    Test_QC2497_FromAttributeMissingFromDataSeries
    Test_QC2497_FromDateAttributeMissingFromDataSeriesWithinItem
    Test_QC2497_FromToDateValidation
    Test_QC2497_NonExistentDataSeries
    Test_QC2497_TestCache
    Test_QC2497_ToAttributeMissingFromDataSeries
    Test_QC2497_ToDateAttributeMissingFromDataSeriesWithinItem
    Test_QC2497_ToEffectiveDateValidation
    Test_QC2497_OverrideEffectiveDates
    Test_QC2497_NaNException
    Test_QC2497_EmptyInputDataSeries

end


