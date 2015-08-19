function test_suite = Test_QC2497_EndToEnd_3D()
    initTestSuite;
end

function Setup()
    addpath('/gpfs/matlab/x1201456/iRSG/');
    addpath(fullfile(pwd(), 'Models'));
    import prursg.*;
    
end


function teardown()
    
end


function TestEndToEnd_3D()

    disp('Executing test Test_QC2497_EndToEnd_3D');
    RSGBootstrap(fullfile(pwd(), 'Control','QC2497_EndToEnd_3D.xml'));            

end


