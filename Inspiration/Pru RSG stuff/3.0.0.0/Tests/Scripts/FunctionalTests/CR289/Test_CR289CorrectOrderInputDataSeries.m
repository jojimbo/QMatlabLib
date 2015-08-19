function test_suite = Test_CR289CorrectOrderInputDataSeries()

    disp('Initialising Test_CR289InvalidTypeException')
 
    initTestSuite; 


end

function TestCorrectOrderInputDataSeries()

    fprintf('\nStarting test for correct order of input data series...')
    
    diary tempFileName.txt;
   
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    
    controlFile = 'bootstrapValidationCorrectOrderInputDataSeries.xml';

    % Set file paths
    bootstrapValidationControlFilePath = strcat(pathstr, filesep,'BootstrapControl', filesep, controlFile);
   
    % Start the bootstrap
    disp('Starting the bootstrap validation process');
    tic
    RSGBootstrapValidate(bootstrapValidationControlFilePath);
    toc
    
    diary off;
    
    searchTerm = 'ERROR';
   
    noException = SearchFileForString('tempFileName.txt', searchTerm);
    
    delete tempFileName.txt;
    
    assertTrue(noException, 'The order of the input data series does not much the one specified in the control XML file');   
    
        
    fprintf('Finishing test for correct order of input data series...\n');

end