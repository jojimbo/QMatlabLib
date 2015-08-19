%% Test_CriticalScenario_TgtZero
%
% SUMMARY:
%       Regression test for Critical Scenario T>0 run
%%

function test_suite = Test_CriticalScenario_TgtZero() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_CriticalScenario_TgtZero')
    initTestSuite;
    disp('Executing Test_CriticalScenario_TgtZero')
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

function Test_CriticalScenario_TgtZero1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Test 21 is the T=0 Critical Scenario, that's why we grab this ARA
    % report
    araReportPath = TestUtil.GetConfigValue('ARAReportPath');
    araReport = fullfile(araReportPath, 'Test29', 'ST_Critical_Scenarios_IDs_100sims.csv');
    
    % Clear down the DB (or not) and run a critical scenario run
    TestUtil.RebuildScenarioDB();
	[UserMsg id] = RSGSimulate('Test27.xml')
    [UserMsg ScenSetID] = RSGRunCS('Test27.xml', araReport, 5, 'Exponential', []);
	disp('Test "simulation()" has completed.')
    
    % Generate files for the base simulation
    TestUtil.GenerateFiles(ScenSetID);
    
    baseScenId = 'Test27_11Apr2012_10_34_17_CS_26Oct2012_17:28:10';
    
    % Compare the generated files to a baseline
    % Provide the scenario set ID and the path to the baseline files
    pathToBaseline = TestUtil.GetConfigValue('BaselineFolder');
    pathToOutput = TestUtil.GetConfigValue('OutputFolderPath');
    TestUtil.CompareDirs(pathToBaseline, baseScenId, pathToOutput, ScenSetID);

    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end


%%
%% Test utils below here
%%
