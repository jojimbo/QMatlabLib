%% Test_CorrelationMatrixSource
%
% SUMMARY:
% 	A unit test. Test that the correlation matrix source classes behave as expected
%%

%%
%%
%% NEED TO ADD MORE NEGATIVE TESTS - E.G. MISSING AND MALFORMED FILES
%% Should also create a separate test folder for XML vs XLS so can make use 
%% of the Pillar I test XMLs in Tests/Externals
%%
%%

function test_suite = Test_CorrelationMatrixSource() %#ok<STOUT>
	disp('Initialising Test_CorrelationMatrixSource')
	initTestSuite;
	disp('Executing Test_CorrelationMatrixSource')
end

function Test_CorrelationMatrixXlsSource_TID_4_0_0_xls() %#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...']);

    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config'); 

    ProcessCorrelationMatrixXlsSource('TID_4.0.0.xml', {'.xls'}, true)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test_CorrelationMatrixXlsSource_TID_4_0_0_xlsm() %#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...']);

    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config'); 
    
    ProcessCorrelationMatrixXlsSource('TID_4.0.0.xml', {'.xlsm'}, true)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function xTest_CorrelationMatrixXlsSource_TID_4_0_0_xlsb() %#ok<DEFNU>
% xlsb does not work. No investigation has been undertaken to understand
% why. Note the requirement was to support xlsx, we wer asked to try xlsb
% and xlsm just prior to delivery
    disp(['Starting test: "' testutil.TestUtil.func '"...']);
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config'); 

    ProcessCorrelationMatrixXlsSource('TID_4.0.0.xml', {'.xlsb'}, true)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test_CorrelationMatrixXlsSource_TID_5_0_0() %#ok<DEFNU>
    % TID_5_0_0 does not appear to be PSD - talk to Edmund
	disp(['Starting test: "' testutil.TestUtil.func '"...']);

    ProcessCorrelationMatrixXlsSource('TID_5.0.0.xml', {}, false)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test_CorrelationMatrixXlsSource_TID_6_0_0() %#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...']);
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config'); 

    ProcessCorrelationMatrixXlsSource('TID_6.0.0.xml', [], true)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test40_CorrelationMatrixControlFileSource() %#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...']);

    import testutil.*;
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1Checkpoint.app.config');   

    inputXMLFolder = TestUtil.GetConfigValue('InputFolderPath');
    control_file = fullfile(inputXMLFolder, 'Test40.xml');
    mockcf = constructControlFile(control_file);
    
    processControlFile(mockcf, true);               
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test19_CorrelationMatrixControlFileSource() %#ok<DEFNU>
    % Test19 does not appear to be PSD is this correct?
	disp(['Starting test: "' testutil.TestUtil.func '"...']);

    import testutil.*;
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1Checkpoint.app.config'); 

    inputXMLFolder = TestUtil.GetConfigValue('InputFolderPath');
    control_file = fullfile(inputXMLFolder, 'Test19.xml');
    mockcf = constructControlFile(control_file);
    
    processControlFile(mockcf, false);          
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

function Test_CorrelationMatrixXlsSource_xlsx() %#ok<DEFNU>
	disp(['Starting test: "' testutil.TestUtil.func '"...']);
    
    import testutil.*;
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config'); 

    % Note this is a dummy control file. The correlation matrix was
    % provided by Andrew Leifer without a controlf file. That;s ok for this
    % test as we're only interested in the corr matrix but the control file
    % name and location is used to derived the corr matrix file location
    ProcessCorrelationMatrixXlsSource('AndrewL.xml', {}, true)
	
    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end

%%
%% Utils
%%

function ProcessCorrelationMatrixXlsSource(controlFile, patterns, assertion)
	import prursg.*;
	import testutil.*;

    inputXMLFolder = TestUtil.GetConfigValue('InputFolderPath');
    control_file = fullfile(inputXMLFolder, controlFile);
    mockcf = constructControlFile(control_file);
    
    source = prursg.CorrelationMatrix.CorrelationMatrixXlsSource(mockcf);
    source.Verbosity = 1;
    % xls_source.Verbosity = 2;
        
    if ~isempty(patterns)
        % override the default pattern(s)
        source.patterns = patterns;
    end
    
    status = source.readCorrelationMatrix();
    assertTrue(status, 'Failed to read the correlation matrix');
    
    names = source.names;
    values = source.values;

    %check_min_eig(values, 9.999826833900416e-10)
    size = checkCorrMatrix(values, assertion);
    checkNames(size, names);
end

function processControlFile(control_file, assertion)
	import prursg.*;
	import testutil.*;
    
    source = prursg.CorrelationMatrix.CorrelationMatrixControlFileSource(control_file);    
    source.Verbosity = 1;
    % xls_source.Verbosity = 2;
    status = source.readCorrelationMatrix();
    assertTrue(status, 'Failed to read the correlation matrix');
    
    names = source.names;
    values = source.values;
        
    size = checkCorrMatrix(values, assertion);
    checkNames(size, names);
end

% Perform some checks on the matrix and the identifies
% in: corr_mat, the matrix
% out: dim, the size of the matrix
function dim = checkCorrMatrix(corr_mat, assertion)
    [m, n] = size(corr_mat);
    assertEqual(m, n, 'The correlation matrix should be square');
    dim = m;
    
    assertIsPSD(corr_mat, assertion);
end

function check_min_eig(corr_mat, mineig)
    % not a functional test as this is the value produced by matlab from the
    % read in result - more a regression test
    assertEqual(min(eig(corr_mat)), mineig); 
end

% Perform some checks on the matrix identifiers
function checkNames(matrix_size, names)
    len_names = length(names);
    assertEqual(matrix_size, len_names,...
        ['The number of names in the name sheet '...
        'should match the dimensions of the correlation matrix']);
    
    % Names should be unique - unique removes duplicates
    unique_names = unique(names);
    len_unique_names = length(unique_names);
    assertEqual(len_names, len_unique_names, 'Names are not unique');
end

%   If A is positive definite, then
%   R = CHOL(A) produces an upper triangular R so that R'*R = A.
%   If A is not positive definite, an error message is printed.

%   [R,p] = CHOL(A), with two output arguments, never produces an
%   error message.  If A is positive definite, then p is 0 and R
%   is the same as above.   But if A is not positive definite, then
%   p is a positive integer.
%   When A is full, R is an upper triangular matrix of order q = p-1
%   so that R'*R = A(1:q,1:q).
%   When A is sparse, R is an upper triangular matrix of size q-by-n
%   so that the L-shaped region of the first q rows and first q
%   columns of R'*R agree with those of A.
function assertIsPSD(corr_mat, assertion)
    [~, p] = chol(corr_mat);
    if assertion
        assertTrue((p == 0), 'If A is positive definite, then p is 0');
    else
        assertFalse((p == 0), 'The correlation matrix is not expected to be PSD');
    end
end

function mcf = constructControlFile(controlFilePath)    
    mcf = MockControlFile();
    mcf.controlFilePath = controlFilePath;
    mcf.controlFileDOM = xmlread(controlFilePath);
end