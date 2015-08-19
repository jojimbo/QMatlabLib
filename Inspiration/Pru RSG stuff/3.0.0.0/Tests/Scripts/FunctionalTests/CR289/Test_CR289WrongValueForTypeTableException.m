function test_suite = Test_CR289WrongValueForTypeTableException()

    disp('Initialising Test_CR289WrongValueForTypeTableException')
 
    initTestSuite; 


end

function TestWrongValueForTypeTableException()

    fprintf('\nStarting test for wrong value provided for type table...')
    
    diary tempFileName.txt;
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationWrongValueForTypeTable.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    disp('Starting the bootstrap validation process');
    tic
    outputPath = RSGBootstrapValidate(bootstrapValidationControlFilePath);
    toc
    
    diary off;
    
    searchTerm = 'ValidationResults:validateInputParameters:InvalidValueForTable';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the wrong value has been provided for type table');
    
    files = areThereFilesInTheDirectory(outputPath);
    
    tempResult = strfind(files, '.xml');
    
    assertTrue(isempty(tempResult{1}), 'Some files have been generated by the boostrap validation process when they shouldn''t');
    
    fprintf('Finishing test for wrong value provided for type table...\n');

end