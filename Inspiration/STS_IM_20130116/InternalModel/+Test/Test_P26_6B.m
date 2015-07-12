%% Unit Test_P26_6B
% Tests the ability to run STS_Run with several config files

function Test_P26_6B
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

scenname = 'Base Scenario';
folderpath = STS_ECScenario(targetpath, scenname, configFilePath1, configFilePath2, configFilePath3);

disp('.....Checking output file was created.....');
assertTrue(exist(fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']), 'file')==2, ['file ' fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']) ' was not created']);

delete(fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']));


% Same thing with a different Scenario name that 'Base Scenario'
scenname = 'SSMC_7';
folderpath = STS_ECScenario(targetpath, scenname, configFilePath1, configFilePath2, configFilePath3);
disp('.....Checking output file was created.....');
assertTrue(exist(fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']), 'file')==2, ['file ' fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']) ' was not created']);
delete(fullfile(targetpath, ['MATLAB_AM_Output_' scenname '.csv']));


clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end