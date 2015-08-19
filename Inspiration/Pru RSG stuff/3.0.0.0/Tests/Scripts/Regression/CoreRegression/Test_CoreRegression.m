%% Test_CoreRegression
%
% SUMMARY:
%       Test for testing the core regression functionality
%%

function test_suite = Test_CoreRegression() %#ok<STOUT,FNDEF>
    % The first test must return an instance of initTestSuite
    disp('Initialising Test_CoreRegression')
    initTestSuite;
    disp('Executing Test_CoreRegression')
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

function Test_CoreRegression_1()	%#ok<DEFNU>
    disp(['Starting test: "' testutil.TestUtil.func '"...'])

    import prusg.*;
    import testutil.*;

    %% Body of test 1 goes here
    %% Copy this function and rename for each test

    disp(['Test: "' testutil.TestUtil.func '" has completed.'])
end


%%
%% Test utils below here
%%
