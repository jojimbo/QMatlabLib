%% Test_UserDefined_TgtZero
%
% SUMMARY:
%       Regression test for user defined T>0 scenario
%%

function test_suite = Test_UserDefined_TgtZero() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_UserDefined_TgtZero')
    initTestSuite;
    disp('Executing Test_UserDefined_TgtZero')
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

function Test_UserDefined_TgtZero1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Clear down the DB (or not) and run a user defined T>0 scenario 
    TestUtil.RebuildScenarioDB();
	[UserMsg ScenSetID] = RSGSimulate('Test30.xml');
	disp('Test "simulation()" has completed.')
    
    % Generate files for the base simulation
    TestUtil.GenerateFiles(ScenSetID);
    
    % Compare the generated files to a baseline
    % Provide the scenario set ID and the path to the baseline files
    pathToBaseline = TestUtil.GetConfigValue('BaselineFolder');
    pathToOutput = TestUtil.GetConfigValue('OutputFolderPath');
    TestUtil.CompareFiles(pathToOutput, ScenSetID, pathToBaseline);

    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end


%%
%% Test utils below here
%%
