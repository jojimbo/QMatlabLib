function test_suite = Test_QC2497_ContinuityFollowingException()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestContinuityFollowingException()

    disp('Executing test Test_QC2497_ContinuityFollowingException');
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_ContinuityFollowingException.xml'));    

end


