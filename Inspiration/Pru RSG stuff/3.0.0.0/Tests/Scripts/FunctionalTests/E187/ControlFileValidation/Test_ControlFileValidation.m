%% Test_ControlFileValidation
%
% SUMMARY:
%       Test to confirm validation of the control file and the correct behavior depending on the flag in the configuration file
%%

function test_suite = Test_ControlFileValidation() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_ControlFileValidation')
    
    % Could call this from setup if required before each testcase
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config');    
    %testutil.TestUtil.RebuildScenarioDB();
    
    initTestSuite;
    disp('Executing Test_ControlFileValidation')
end

function setup() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

function teardown() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

%%
%% Tests
%%

function Test_ControlFileValidation_ValidationOn()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config');
    
    import prursg.Xml.ControlFile.*;
    assertTrue(ControlFileFactory.shouldValidateSchema(), 'The schema validation is not enabled when it should be enabled');     
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileValidation_ValidationOff()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app_validation_off.config');
    
    import prursg.Xml.ControlFile.*;
    assertFalse(ControlFileFactory.shouldValidateSchema(), 'The schema validation is enabled when it should not be');       
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileValidation_ValidationMissingValidationOption()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app_missing_validation.config');
    
    import prursg.Xml.ControlFile.*;
    assertFalse(ControlFileFactory.shouldValidateSchema(), 'The schema validation is enabled when it should not be');       
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileValidation_ValidationOnCorruptedControlFile()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config');
    
    diary tempFileName.txt;
    
    RSGSimulate('corruptXMLFile.xml');
    
    diary off;
    
    searchTerm = 'org.xml.sax.SAXParseException: cvc-complex-type.4: Attribute ''source'' must appear on element ''correlation_matrix''.';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'No exception has been thrown when the attribute ''source'' is missing');     
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_ControlFileValidation_ValidationOffCorruptedControlFile()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app_validation_off.config');
    
    diary tempFileName.txt;
    
    RSGSimulate('corruptXMLFile.xml');
    
    diary off;
    
    searchTerm = 'Schema validation is disabled.';
    
    noException = SearchFileForString('tempFileName.txt', searchTerm);
 
    delete tempFileName.txt;

    assertFalse(noException, 'An exception has been thrown that relates to schema validation, when shcema validation is disabled');     
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end
%%
%% Test utils below here
%%
function flag = SearchFileForString(fileName, stringToSearch)

    if (isunix)
        searchStatement = ['grep -li "'  stringToSearch '" ' fileName];
    else
        searchStatement = ['findstr /i /p /m "' stringToSearch '" ' fileName];
    end    
    
    txtFilesString = evalc('system(searchStatement)');
    fileNames = regexp(txtFilesString,'\n','split');  
    flag = true;
    if ~isempty(fileNames)
    	for i = 1:length(fileNames)
            txtFile = fileNames{i};
            [~, ~, ext] = fileparts(txtFile);
            if (exist(txtFile, 'file') && strcmpi(strtrim(ext), '.txt'))
                flag = false;
            end
        end
    end


end
