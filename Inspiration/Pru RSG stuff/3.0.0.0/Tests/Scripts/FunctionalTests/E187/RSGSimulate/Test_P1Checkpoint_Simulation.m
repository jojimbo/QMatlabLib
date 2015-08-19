%% Test_P1Checkpoint_Simulation
%
% SUMMARY:
%       Test end-to-end with existing Pillar I control files. This means we
%       are testing controls files with schema versin 2.3.0.0 although the
%       schema version is not explicit in the control file.
% 
%       In the functions below the first number refers to the schema
%       version, the second to the test file name and the suffix to 
%       functionality under test.
%
%       The objective is to test end-to-end without error - not to verify
%       outputs. These tests ideally would be fast but the only CS test I'm
%       aware of reliease on test 19 which is very slow
%%

function test_suite = Test_P1Checkpoint_Simulation() %#ok<STOUT>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_v2_3_0_0_Simulation');
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1Checkpoint.app.config');
    testutil.TestUtil.RebuildScenarioDB();
    
    initTestSuite;
    disp('Executing Test_v2_3_0_0_Simulation')
end

function setup() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

function teardown() %#ok<DEFNU>
    fprintf('%s\n', testutil.TestUtil.func);
end

%%
%% Tests 
%%      Note: we're testing only for errors here not checking outputs
%%      The output will be compared to a baseline in regression testing
%%          

function Test_v2_3_0_0_Simulation_Test20_BB()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    runSimulation('Test20.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end

function Test_v2_3_0_0_Simulation_Test22_SF()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    runSimulation('Test22.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end

function Test_v2_3_0_0_Simulation_Test23_UDS()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    runSimulation('Test23.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end

function Test_v2_3_0_0_Simulation_Test40_base()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    runSimulation('Test40.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end

%{ 
% Not sure if this test works - the pillar I test pack suggests not
function xTest_v2_3_0_0_Simulation_Test52_inmem()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;

    TestUtil.RebuildScenarioDB();
	[message, ~] = RSGSimulate('Test52.xml')
    disp(message);

    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end
%}


function Test_v2_3_0_0_Simulation_Test19_24_teq0_WI()	%#ok<DEFNU>
    % This test fails becuase the scenario ids in the pillar I test files are broken
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    testutil.TestUtil.RebuildScenarioDB();
    runSimulation('Test19.xml');
    runSimulation('Test24.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end


function Test_v2_3_0_0_Simulation_Test27_31_tgt0_WI()	%#ok<DEFNU>
    % This test fails becuase the scenario ids in the pillar I test files are broken
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func);

    testutil.TestUtil.RebuildScenarioDB();
    runSimulation('Test27.xml');
    runSimulation('Test31.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func);
end


function Test_v2_3_0_0_CriticalScenarioTest19_21_CS_base()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...']);

    import prusg.*;
    import testutil.*;
    
    ARAReportPath = TestUtil.GetConfigValue('IRSGPillar1ARAReportPath');
    araReport = fullfile(ARAReportPath, 'Test47', 'ST_Critical_Scenarios_IDs_100sims.csv');

    TestUtil.RebuildScenarioDB();
	[message, ~] = RSGSimulate('Test19.xml');
    disp(message);
    
    [message, ~] = RSGRunCS('Test19.xml', araReport, 5, 'Exponential', []);
    disp(message);
	disp('Test "simulation()" has completed.');

    disp(['Test: "' testutil.TestUtil.func '" has completed.']);
end


%%
%% Test utils below here
%%

function scenid = runSimulation(controlFile)
    import prusg.*;
    import testutil.*;
    
	[message, scenid] = RSGSimulate(controlFile);
    fprintf('Simulation completed with message: %s\n', message);

    % Generate files for the base simulation
    TestUtil.GenerateFiles(scenid);
end