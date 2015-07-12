%% Unit Test_P26_6
% Tests the ability to run STS_Run with several config files

function Test_P26_6
disp(['################ Starting ' mfilename ' ################']);
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));

targetpath = ['+Test', filesep 'Results' filesep computer, filesep];
disp(['Targetpath for the output is ' targetpath]);

configFilePath1 = fullfile(pwd, '+Test', filesep, 'Configuration Files', computer, 'configDemoTest2011_FXFW_FAT_FX.txt');
configFilePath2 = fullfile(pwd, '+Test', filesep, 'Configuration Files', computer, 'configDemoTest2011_FXFW_FAT_IR.txt');
configFilePath3 = fullfile(pwd, '+Test', filesep, 'Configuration Files', computer, 'configDemoTest2011_FXFW_FAT_IR.txt');

disp('.....Running STS_Run with ConfiFiles: ');
disp(configFilePath1)
disp(configFilePath2)
disp(configFilePath3)

folderpath = STS_Run(targetpath, configFilePath1, configFilePath2, configFilePath3);

disp('.....Checking output file was created.....');
assertTrue(exist(fullfile(targetpath, 'STS_IM_Output.csv'), 'file')==2, ['file ' fullfile(targetpath, 'STS_IM_Output.csv') ' was not created']);

delete(fullfile(targetpath, 'STS_IM_Output.csv'));

clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end