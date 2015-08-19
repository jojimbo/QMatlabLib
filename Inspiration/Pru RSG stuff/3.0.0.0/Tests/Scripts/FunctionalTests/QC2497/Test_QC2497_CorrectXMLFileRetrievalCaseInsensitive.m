function test_suite = Test_QC2497_CorrectXMLFileRetrievalCaseInsensitive()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestCorrectXMLFileRetrievalCaseInsensitive()

    disp('Executing test Test_QC2497_CorrectXMLFileRetrievalCaseInsensitive');
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_CorrectXMLFileRetrievalCaseInsensitive.xml'));    

end


