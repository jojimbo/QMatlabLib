function test_suite = Test_CR289WrongValueForTypeDoubleException()

    disp('Initialising Test_CR289WrongValueForTypeDoubleException')
 
    initTestSuite; 


end

function TestWrongValueForTypeDoubleException()

    fprintf('\nStarting test for wrong value provided for type double...')
    
    diary tempFileName.txt;
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationWrongValueForTypeDouble.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    disp('Starting the bootstrap validation process');
    tic
    outputPath = RSGBootstrapValidate(bootstrapValidationControlFilePath);
    toc
    
    diary off;
    
    searchTerm = 'ValidationResults:validateInputParameters:InvalidValueForDouble';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the wrong value has been provided for type double');
    
    files = areThereFilesInTheDirectory(outputPath);
    
    assertTrue(isempty(files), 'Some files have been generated by the boostrap validation process when they shouldn''t');
    
    fprintf('Finishing test for wrong value provided for type double...\n');

end