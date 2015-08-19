%% Test_simulation
%
% SUMMARY:
% 	An installation sanity test
%%

function test_suite = Test_simulation()	
    disp('InitialisingTest_simulation')
	initTestSuite;
	disp('Executing Test_simulation')
end

function Test_Simulate()
	disp('Starting test: "simulation()"...')

	import prusg.*;
	import testutil.*;
    TestUtil.RebuildScenarioDB();
	[message, scenid] = RSGSimulate('Test40.xml')
	disp('Test "simulation()" has completed.')
end
