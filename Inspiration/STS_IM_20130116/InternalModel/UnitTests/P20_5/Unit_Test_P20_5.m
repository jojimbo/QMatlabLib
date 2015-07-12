% STS-IM UNIT TEST
% P20-5
% 04 December 2012

function [bool] = Unit_Test_P20_5(testPath, codePath)
%% File Declarations:
disp('### Start Unit_Test_P20_5');
currentPath = pwd;
cd(codePath); % Go to code

% Portfolio Files
pf_DV1BL4USIIM    = internalModel.Portfolio([testPath 'DV1BL4USIIM.xml']);
pf_test_portfolio = internalModel.Portfolio([testPath 'test_portfolio.xml']);

disp('Finished loading');


%% Processing & Test Acceptance
% 1. Correct Tree Representation
%    All elements of the 'benchTree' must be present
benchTree = {'ING_GROUP', 'DV_1', 'DV_1_BL_4',     'DV_1_BL_4_USIIM', 'DV_1_BL_4_USIIM_PF_20315', ...
             'DV_1_BL_4_USIIM_PF_20315_ASSETS',    'DV_1_BL_4_USIIM_PF_20315_PFM_22071', ...
             'DV_1_BL_4_USIIM_PF_20315_PFM_22072', 'DV_1_BL_4_USIIM_PF_20315_NONMARKETDATA'};

findGID   = @(x)(x.GID);
testTree  = cellfun(findGID, pf_DV1BL4USIIM.groups);

if all(strcmpi(benchTree, testTree))
    disp('PASSED : Benchmark Portfolio Tree is correctly loaded');
    b1 = true;
else
    disp('FAILED : Benchmark Portfolio Tree is correctly loaded');
    b1 = false;
end


% 2. Perform Full STS-RUN
%    Skipped for now: the configuration file uses absolute paths, while
%    this Unit Test code repository works with relative paths. This
%    requires more effort to implement. To do this, we have to implement an
%    override method to submit a manually constructed 'obj.parameters' in a
%    'Calculate' object. 
%    
%    CONCERN: A Unit-Test is not really the place to perform a full STS
%    Run. It is advised to use the Unit Test only for Portfolio File
%    Parsing
b2 = true;


%% Summary
bool = b1 && b2;
cd(currentPath); % Go back

end
