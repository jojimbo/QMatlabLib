% These tests cover CR289 End-To-End functionality.

function test_suite = Test_CR289_EndToEnd()
    disp('Initialising Test_CR289_EndToEnd')
    initTestSuite;        
end

function TestBootstrapValidationEndToEnd()

    disp('Starting the boostrap validation process...')
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationControlEndToEnd.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    disp('Starting the bootstrap process');
    tic
    RSGBootstrapValidate(bootstrapValidationControlFilePath);
    toc
    disp('Bootstrap complete');

end
