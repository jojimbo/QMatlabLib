%% Test_BigBang_TgtZero
%
% SUMMARY:
%       Regression test for big bang T>0 run
%%

function test_suite = Test_BigBang_TgtZero() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_BigBang_TgtZero')
    initTestSuite;
    disp('Executing Test_BigBang_TgtZero')
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

function Test_BigBang_TgtZero1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Clear down the DB (or not) and run a big bang
    TestUtil.RebuildScenarioDB();
	[UserMsg ScenSetID] = RSGSimulate('Test28.xml')
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
