%% Test_<TEST_NAME>
%
% SUMMARY:
%       <TEST_DESCRIPTION>
%%

function test_suite = Test_<TEST_NAME>() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_<TEST_NAME>')
    
    % Could call this from setup if required before each testcase
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('app.config');    
    testutil.TestUtil.RebuildScenarioDB();
    
    initTestSuite;
    disp('Executing Test_<TEST_NAME>')
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

function Test_<TEST_NAME>_1()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    import prusg.*;
    import testutil.*;

    %% Body of test 1 goes here
    %% Copy this function and rename for each test        
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end


%%
%% Test utils below here
%%
