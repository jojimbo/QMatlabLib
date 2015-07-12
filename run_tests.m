import matlab.unittest.TestSuite

originalPath = path;
addpath(fullfile(pwd, 'SourceCode'));

global RCQL_ROOT;
RCQL_ROOT = pwd; % referenced by tests

results = run(TestSuite.fromFolder('Tests', 'IncludingSubfolders', true));

disp(results);

path(originalPath);
clear test_root;
