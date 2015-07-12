%% Unit Test_P20_12_P24_19_2
% Loading and Pricing of FX Swaps

function Test_P20_12_P24_19_2
disp(['################ Starting ' mfilename ' ################']);
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']));
configFilePath = fullfile(pwd, '+Test', filesep, 'Configuration Files', computer, 'configDemo_P24_19_2(FXSw).txt');
disp(['.....Running STS_CM with ConfiFile: ' configFilePath ' .....']);

results = STS_CM(configFilePath);

obtainedCube = results.cube.data;

expectedCube = expectedresults.cube.data;

for i=1:size(obtainedCube,1);
    temp = results.instCol.Instruments{1,i};
    N = temp.Notional;
    obtainedCube(i,:) = obtainedCube(i,:)./ N;
   
    expectedCube(i,:) = expectedCube(i,:)./ N;
end

save(fullfile('+Test', 'Results', computer, filesep, [mfilename '_Results.mat']), ...
    'obtainedCube', 'expectedCube' ...
    );

disp('.....Checking values of the Cube');
assertElementsAlmostEqual(obtainedCube, expectedCube, 'absolute', ToleranceLevel)


clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end