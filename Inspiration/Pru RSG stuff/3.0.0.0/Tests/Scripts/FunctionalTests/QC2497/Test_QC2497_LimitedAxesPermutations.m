function test_suite = Test_QC2497_LimitedAxesPermutations()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestLimitedAxesPermutations()

    disp('Executing test Test_QC2497_LimitedAxesPermutations');
    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_LimitedAxesPermutations.xml'));    

end


