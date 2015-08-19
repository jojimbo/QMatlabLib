%% Test_WhatIf_SuppressRisks
%
% SUMMARY:
%       Test case to test a What-If T=0 run with suppressed risk drivers
%%

function test_suite = Test_WhatIf_SuppressRisks() %#ok<STOUT>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_WhatIf_SuppressRisks')
    initTestSuite;
    disp('Executing Test_WhatIf_SuppressRisks')
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

function Test_WhatIf_NonGridSuppressRisks()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    run('WhatIf_SuppressedRisks.app.config');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_WhatIf_GridSuppressRisks()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);
 
    run('WhatIf_GridSuppressedRisks.app.config');
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end


%%
%% Test utils below here
%%

function run(configName)
    import prusg.*;
    import testutil.*;
    
    % Grab the app config file for the What-If run with suppressed risk
    % drivers
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName(configName);    
    testutil.TestUtil.RebuildScenarioDB();
    
    % The base file used is a base simulation T=0. The second run is a
    % What-If T=0 run. Both files have been formatted in schema 3.0.0.0.
    % The same file used in Test_WhatIf.m have been used in this test. The
    % What-If file has been modified to suppress the first and fourth risk
    % drivers
    RSGSimulate('Test64_Base_v3.0.0.0.xml');
	[message, ScenSetID] = RSGSimulate('Test64_What-If_v3.0.0.0_SuppressRisks.xml');
    
	fprintf('RSGSimulate completed with message: %s', message)
    
    % Generate files for the base simulation. the files generated will need
    % to be inspected to confirm that the first and fourth first drivers
    % have been suppressed in the output. 
    TestUtil.GenerateFiles(ScenSetID);      
end
