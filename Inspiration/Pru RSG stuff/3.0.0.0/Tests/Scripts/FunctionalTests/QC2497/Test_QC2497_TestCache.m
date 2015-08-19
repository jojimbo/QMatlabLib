function test_suite = Test_QC2497_TestCache()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestCorrectXML()

    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_TestCache.xml'));    

end


