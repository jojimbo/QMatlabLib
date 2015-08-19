%% Test_CalibrationPercentiles
%
% SUMMARY:
%       Regression test for calibration to percentiles
%%

function test_suite = Test_CalibrationPercentiles() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_CalibrationPercentiles')
    initTestSuite;
    disp('Executing Test_CalibrationPercentiles')
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

function Test_CalibrationPercentiles1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Clear down the DB (or not) and run calibration to percentiles
    TestUtil.RebuildScenarioDB();
	[UserMsg ScenSetID] = RSGSimulate('Test40.xml');
    [UserMsg XMLFilePathOut] = RSGCalibrate('Test38.xml');
	disp('Test "simulation()" has completed.')
    
    % Generate files for the base simulation
    %TestUtil.GenerateFiles(ScenSetID);
    
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