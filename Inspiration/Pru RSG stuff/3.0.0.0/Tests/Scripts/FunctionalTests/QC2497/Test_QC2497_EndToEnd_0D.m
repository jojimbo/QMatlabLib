function test_suite = Test_QC2497_EndToEnd_0D()
    initTestSuite;
end

function Setup()
    addpath('c:\temp\iRSG');
    import prursg.*;
    
end


function teardown()
    
end


function TestEndToEnd_0D()

    disp('Executing test Test_QC2497_EndToEnd_0D');
    RSGBootstrap(fullfile(pwd(), 'Control', 'QC2497_EndToEnd_0D.xml'));    

end


