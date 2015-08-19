
%% Test_CS
%
% SUMMARY:
%       Test case to test a Critical Scenario run on a base T=0
%%

function test_suite = Test_CS() %#ok<STOUT>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_CS');
    initTestSuite;
    disp('Executing Test_CS');
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

function Test_CS_NonGrid()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    run('CS.app.config');
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function Test_CS_Grid()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    run('CS_Grid.app.config');
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end


%%
%% Test utils below here
%%

function run(configName)
    % Grab the app config file for the CS run
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName(configName);    
    testutil.TestUtil.RebuildScenarioDB();
    
    import prusg.*;
    import testutil.*;
    
    araReportPath = TestUtil.GetConfigValue('ARAReportPath');
    araReport = fullfile(araReportPath, 'ST_Critical_Scenarios_IDs_100sims.csv');

    % The base file used is a base simulation T=0. The file is identical to
    % the Test64_Base_v3.0.0.0.xml, only the number of simulations has
    % increased to 100
    RSGSimulate('Test64_Base_v3.0.0.0_100sims.xml');
	[message, ScenSetID] = RSGRunCS('Test64_Base_v3.0.0.0_100sims.xml', araReport, 5, 'Exponential', []);
	fprintf('RSGSimulate completed with message: %s', message)
    
    % Generate files for the base simulation
    TestUtil.GenerateFiles(ScenSetID);      
    
    % Compare the generated files to a baseline. The baseline files have
    % been created using the RSG v2.7.0 and the same input files used here
    % formatted in schema 2.3.0.0 rather than 3.0.0.0
    % Provide the scenario set ID of the CS run and the path to the
    % baseline files 
    pathToBaseline = TestUtil.GetConfigValue('BaselineFolder');
    pathToOutput = TestUtil.GetConfigValue('OutputFolderPath');
    baselineScenarioID = 'Test64_Base_05Nov2012_16_20_21_CS_05Nov2012_20_36_33';
    
    % First use the baseline folder and compare against the
    % generated output
    TestUtil.CompareDirs(pathToBaseline, baselineScenarioID, pathToOutput, ScenSetID);

    % Use the generated output in case more files have been
    % generated
    TestUtil.CompareDirs(pathToOutput, ScenSetID, pathToBaseline, baselineScenarioID); 
end
