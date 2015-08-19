%% Test_WhatIf
%
% SUMMARY:
%       Test case to test a What-If T=0 run
%%

function test_suite = Test_WhatIf() %#ok<STOUT>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_WhatIf')
    initTestSuite;
    disp('Executing Test_WhatIf')
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

function Test_WhatIf_NonGrid()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    run('WhatIf.app.config');

    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end


function Test_WhatIf_Grid()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    run('WhatIf_Grid.app.config');

    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

%%
%% Test utils below here
%%

function run(configName)
    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName(configName);    
    testutil.TestUtil.RebuildScenarioDB();

    % The base file used is a base simulation T=0. The second run is a
    % What-If T=0 run. Both files have been formatted in schema 3.0.0.0
    RSGSimulate('Test64_Base_v3.0.0.0.xml');
	[message, ScenSetID] = RSGSimulate('Test64_What-If_v3.0.0.0.xml');
	fprintf('RSGSimulate completed with message: %s', message)
    
    % Generate files for the base simulation
    TestUtil.GenerateFiles(ScenSetID);      
    
    % Compare the generated files to a baseline. The baseline files have
    % been created using the RSG v2.7.0 and the same input files used here
    % formatted in schema 2.3.0.0 rather than 3.0.0.0
    % Provide the scenario set ID of the What-If run and the path to the
    % baseline files 
    pathToBaseline = TestUtil.GetConfigValue('BaselineFolder');
    pathToOutput = TestUtil.GetConfigValue('OutputFolderPath');
    TestUtil.CompareFiles(pathToOutput, ScenSetID, pathToBaseline);
end
