%% Test_Simulation
%
% SUMMARY:
%       Test end-to-end
%%

function test_suite = Test_Simulation() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_Simulation')
    
    initTestSuite;
        
    disp('Executing Test_Simulation')
end

function setup() %#ok<DEFNU>
    fprintf('\n%s\n', testutil.TestUtil.func);  
end

function teardown() %#ok<DEFNU>
    fprintf('\n%s\n', testutil.TestUtil.func);
end

%%
%% Tests
%%

function Test_Test40v3()	%#ok<DEFNU>
    % This test is currently failing as the file received from Sam appears
    % to be corrupt.
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    %runSimulation('Test40_v3_0_0_3.xml');
    %runSimulation('Test40_v3.0.0.0.xml');
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

% Test v3.0.0.0 schema simulation
function Test_CompareSimulationOutputs()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1Functional.app.config');    
    testutil.TestUtil.RebuildScenarioDB();
    
    inmem = false;
    runSimulations(inmem);
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

% Test v3.0.0.0 schema simulation on the grid
function Test_CompareSimulationGridOutputs()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1FunctionalGrid.app.config');    
    testutil.TestUtil.RebuildScenarioDB();
    
    inmem = false;
    runSimulations(inmem);
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

% Test v3.0.0.0 schema simulation in-memory
function Test_CompareSimulationInMemoryOutputs()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1FunctionalInMemory.app.config');    
    testutil.TestUtil.RebuildScenarioDB();
    
    inmem = true;
    runSimulations(inmem);
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

% Test v3.0.0.0 schema simulation in-memory on the grid
function Test_CompareSimulationGridInMemoryOutputs()	%#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)
    
    import prursg.Configuration.*;
    ConfigurationManager.setConfigFileName('P1FunctionalGridInMemory.app.config');    
    testutil.TestUtil.RebuildScenarioDB();
    
    inmem = true;
    runSimulations(inmem);
    
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end


%%
%% Test utils below here
%%

% Do the work of the above tests
function runSimulations(inmem) %#ok<DEFNU>
    fprintf('Starting test: "%s"...\n',  testutil.TestUtil.func)

    scenid1 = runSimulation('tid1.xml', inmem);
   
    scenid2 = runSimulation('tid2.xml', inmem);
 
    % This should pass as tid 1 and tid 2 are both 2.3.0.0 schemas
    % tid2 differsonly in that the schema version is present
    CompareOutputs(scenid1, scenid2);

    % This should pass as RSG v3.0.0.0 is backward compatible. Therefore it
    % should be possible to produce the same output from RSG v2.7.0 and RSG
    % v3.0.0.0 given the same input
    CompareBaselineOutputs(scenid1, 'tid1.2.7.0.baseline');

    scenid3 = runSimulation('tid3.xml', inmem);

    scenid4 = runSimulation('tid4.xml', inmem);
    
    % This test should pass as tid3 and tid4 differ only in that tid4 has
    % an external correlation matrix
    CompareOutputs(scenid3, scenid4);
   
    
    % Not expecting 2 & 3 to match as they are 2.3.0 and 3.0.0 schemas
    % with a tid3 having a many to one risk to correlation entry mapping.
    % Because of this it will not be possible to order the outputs in the
    % same way
    % CompareOutputs(scenid2, scenid3);
    
    
    % 5, 1 and 2 share the same correlation matrix so should produce the same output
    scenid5 = runSimulation('tid5.xml', inmem);
    
    CompareOutputs(scenid1, scenid5);
  
    % Not expecting 6 to match exactly as it has output suppression enabled.
    % The risks that are not suppressed should match tid1 exactly
    scenid6 = runSimulation('tid6.xml', inmem);
    
    CompareBaselineOutputs(scenid6, 'tid6.3.0.0.0.baseline');
   
    fprintf('Test "%s" has completed\n',  testutil.TestUtil.func)
end

function scenid = runSimulation(controlFile, inmem)
    import prusg.*;
    import testutil.*;
    
    % TestUtil.RebuildScenarioDB();
	[message, scenid] = RSGSimulate(controlFile);
    fprintf('Simulation completed with message: %s\n', message);

    if ~inmem
        % Generate files for the base simulation. If inmem then will aready
        % have been created
        TestUtil.GenerateFiles(scenid);
    end
end

function CompareOutputs(scenid1, scenid2)
    import prusg.*;
    import testutil.*;
    
    outputRoot = TestUtil.GetConfigValue('OutputFolderPath');    
    TestUtil.CompareDirs(outputRoot, scenid1, outputRoot, scenid2);
end

function CompareBaselineOutputs(scenid, baseline)
    import prusg.*;
    import testutil.*;
    
    outputRoot = TestUtil.GetConfigValue('OutputFolderPath'); 
    baselinePath = TestUtil.GetConfigValue('BaselineFolder');
    outputBaselineRoot = fullfile(baselinePath, baseline); 
    
    TestUtil.CompareDirs(outputBaselineRoot, scenid, outputRoot, scenid);
end
