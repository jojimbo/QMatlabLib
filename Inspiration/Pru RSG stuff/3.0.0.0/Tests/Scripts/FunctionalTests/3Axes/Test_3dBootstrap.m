%% Test_Graeme_SIVs_Dec2011 
%
% SUMMARY: Test boostrapping with a 3 dimensional data series as provided by Graeme 
%
%%

function test_suite = Test_3dBootstrap()
    disp('Initialising Test_3dBootstrap')
    
    initTestSuite;        
end

function Test_GraemesSwaptionImpliedVolBootstrap()
    % Test that the Item description in the control file
    % feeds through to the bootstrapped data series

    disp('Starting: Test_GraemesSwaptionImpliedVolBootstrap...')
    
    control = RunBootstrap('bootstrapVol.xml');
end


% Helpers
function bootstrapControlFilePath = RunBootstrap(controlFile)
    disp('Starting the boostrap process...')
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));

    % Set file paths
    bootstrapControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    bootstrapEngine = prursg.Bootstrap.BootstrapEngine();
    disp('Starting the bootstrap process');
    tic
    bootstrapEngine.Bootstrap(bootstrapControlFilePath);
    toc
    disp('Bootstrap complete');
end
