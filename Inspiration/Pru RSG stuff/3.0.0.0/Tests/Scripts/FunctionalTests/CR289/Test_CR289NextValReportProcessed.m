function test_suite = Test_CR289NextValReportProcessed()

    disp('Initialising Test_CR289NextValReportProcessed')
    initTestSuite; 

end

function TestNextValReportProcessed()

    fprintf('\nStarting test for next validation report processed...')
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationNextValReportProcessed.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    disp('Starting the bootstrap process');
    tic
    RSGBootstrapValidate(bootstrapValidationControlFilePath);
    toc
    disp('Bootstrap complete');
    
    fprintf('Finishing test for next validation report processed...\n');

end