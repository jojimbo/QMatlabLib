%% Test_WI_TgtZero_BB
%
% SUMMARY:
%       Regression test for a what if T>0 on a Big Bang run
%       Covering QC3184
%%

function test_suite = Test_WI_TgtZero_BB() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_WI_TgtZero_BB')
    initTestSuite;
    disp('Executing Test_WI_TgtZero_BB')
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

function Test_WI_TgtZero_BB1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;
    
    import prursg.Configuration.*;
    prursg.Configuration.ConfigurationManager.setConfigFileName('app.config');
    
    % Clear down the DB (or not) and run a what if T>0 on a Big Bang run
    TestUtil.RebuildScenarioDB();
	RSGSimulate('Test28.xml');
    [UserMsg ScenSetID] = RSGSimulate('Test32.xml'); 
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
