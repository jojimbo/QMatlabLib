%% Test_BaseSimulation_InMemory
%
% SUMMARY:
%       Regression test for base simulation in-memory run
%%

function test_suite = Test_BaseSimulation_InMemory() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_BaseSimulation_InMemory')
    initTestSuite;
    disp('Executing Test_BaseSimulation_InMemory')
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

function Test_BaseSimulation_InMemory1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app_inmemory.config');
    
    % Clear down the DB (or not) and run a base simulation
    %TestUtil.RebuildScenarioDB();
	[UserMsg ScenSetID] = RSGSimulate('Test19_inMemory.xml');
	disp('Test "simulation()" has completed.')
    %ScenSetID = 'Test19_11Apr2012_10:17:51';
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
