%% Test_CS_WI_TgtZero
%
% SUMMARY:
%       Regression test for a T>0 base, the What if on the
%       base and finally a critical scenario on the what if run
%%

function test_suite = Test_CS_WI_TgtZero() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_CS_WI_TgtZero')
    initTestSuite;
    disp('Executing Test_CS_WI_TgtZero')
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

function Test_CS_WI_TgtZero1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Test 29 is the T>0 Critical Scenario, that's why we grab this ARA
    % report
    araReportPath = TestUtil.GetConfigValue('ARAReportPath');
    araReport = fullfile(araReportPath, 'Test29', 'ST_Critical_Scenarios_IDs_100sims.csv');
    
    % Clear down the DB (or not) and run a T>0 base, the What if on the
    % base and finally a critical scenario on the what if run
    TestUtil.RebuildScenarioDB();
	RSGSimulate('Test27.xml');
    RSGSimulate('Test31.xml');
    [UserMsg ScenSetID] = RSGRunCS('Test31.xml', araReport, 5, 'Exponential', []);
	disp('Test "simulation()" has completed.')
    
    % Generate files for the base simulation
    TestUtil.GenerateFiles(ScenSetID);
    
    baseScenId = 'Test31_T=3_SCEN15_27Feb2012_12:16:09_CS_13Nov2012_10:24:35';
    
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
