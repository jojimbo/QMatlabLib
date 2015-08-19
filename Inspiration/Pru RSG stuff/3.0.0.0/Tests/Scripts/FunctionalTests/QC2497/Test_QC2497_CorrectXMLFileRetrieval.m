function test_suite = Test_QC2497_CorrectXMLFileRetrieval()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestCorrectXMLFileRetrievalL()

    disp('Executing test Test_QC2497_CorrectXMLFileRetrieval');
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_CorrectXMLFileRetrieval.xml'));    

end


