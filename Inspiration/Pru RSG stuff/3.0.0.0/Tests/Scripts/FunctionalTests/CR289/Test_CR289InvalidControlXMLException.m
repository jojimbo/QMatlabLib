function test_suite = Test_CR289InvalidControlXMLException()

    disp('Initialising Test_CR289InvalidControlXMLException')
 
    initTestSuite; 
    
end

function TestInvalidControlXMLException()

    fprintf('\nStarting test for invalid control XML...')
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationInvalidControl.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    fprintf('\nStarting the bootstrap validation process');
    tic
    assertExceptionThrown(@() RSGBootstrapValidate(bootstrapValidationControlFilePath),  'BootstrapValidationEngine:BootstrapValidate:InvalidControlXML', ... 
        'We expect an exception as the control XML file provided is invalid')
    toc
    disp(['BootstrapValidationEngine:BootstrapValidate:InvalidControlXML',...
                    ' The control XML file provided does not conform to the schema defined for bootstrap validation']);
    fprintf('Finishing test for invalid control XML...\n');

end















