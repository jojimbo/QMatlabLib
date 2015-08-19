%% Test_BaseSimulation_InMemory_Grid
%
% SUMMARY:
%       Regression test for base simulation in memory using the grid
%%

function test_suite = Test_BaseSimulation_InMemory_Grid() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_BaseSimulation_InMemory_Grid')
    initTestSuite;
    disp('Executing Test_BaseSimulation_InMemory_Grid')
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

function Test_BaseSimulation_InMemory_Grid1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app_inmemory_grid.config');
    
    % Clear down the DB (or not) and run a base simulation
    TestUtil.RebuildScenarioDB();
	[UserMsg ScenSetID] = RSGSimulate('Test19_inMemory.xml');
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
