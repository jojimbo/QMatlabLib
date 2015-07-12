%% deploy_STS_IM script
% This code needs to run from ../Code folder

clc
clear All

% Get date and time of the deployment
modifiedStr = strrep(datestr(now), ' ', '_');
modifiedStr = strrep(modifiedStr, ':', '_');
modifiedStr = strrep(modifiedStr, '-', '_');

execName        = 'MATLAB_AM';
deployFolder    = [pwd filesep computer filesep  'STS_IM'];

if ~exist(deployFolder, 'dir')
    mkdir(deployFolder);
end
if ~exist([deployFolder, filesep, 'distrib'], 'dir')
    mkdir([deployFolder, filesep, 'distrib'])
end
if ~exist([deployFolder, filesep, 'src'], 'dir')
    mkdir([deployFolder, filesep, 'src'])
end

% addpath InternalModel
addpath(genpath('InternalModel'))
diary(fullfile(deployFolder, ['deploy_' computer '_' modifiedStr '.txt']))
cd('InternalModel')
Prepare_for_Unit_Tests
out = runtests('Test');
cd('..')
out = out && runtests('runUT_P19');
cd('..')
out = out && runtests('runUT_P20');
cd('..')
if ~out
    disp('Unit Tests did not pass, executable will not be created');
    disp(['Inspect diary file: ' fullfile(deployFolder, ['deploy_' computer '_' modifiedStr '.txt'])]);
end
diary off

if out    
    mcc('-o', execName, '-W', 'main:STS_CM', '-T', 'link:exe', ...
        '-d', [deployFolder filesep 'distrib'], ...
        '-w', 'enable:specified_file_mismatch', '-w', 'enable:repeated_file', ...
        '-w', 'enable:switch_ignored', '-w', 'enable:missing_lib_sentinel', ...
        '-w', 'enable:demo_license', '-v', ['InternalModel' filesep 'STS_CM.m'], ...
        '-a', 'InternalModel')
    
    mcc('-o', ['RUN_' execName], '-W', 'main:STS_Run', '-T', 'link:exe', ...
        '-d', [deployFolder filesep 'distrib'], ...
        '-w', 'enable:specified_file_mismatch', '-w', 'enable:repeated_file', ...
        '-w', 'enable:switch_ignored', '-w', 'enable:missing_lib_sentinel', ...
        '-w', 'enable:demo_license', '-v', ['InternalModel' filesep 'STS_Run.m'], ...
        '-a', 'InternalModel')
end