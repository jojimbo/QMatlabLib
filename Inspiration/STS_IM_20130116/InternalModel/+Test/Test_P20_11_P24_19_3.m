%% Unit Test_P20_11_P24_19_3
% Loading and Pricing of FXForward

function Test_P20_11_P24_19_3
disp(['################ Starting ' mfilename ' ################']);
addpath(genpath(['matlab_xunit_3.1' filesep]))
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', 'InputData', [mfilename 'TestingData.mat']));
configFilePath = fullfile(pwd, '+Test', 'Configuration Files', computer, '/configDemo_P24_19_3(FXFw).txt');

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

save(fullfile('+Test', 'Results', computer, [mfilename '_Results.mat']), ...
    'obtainedCube', 'expectedCube' ...
    );

disp('.....Checking values of the Cube');
assertElementsAlmostEqual(obtainedCube, expectedCube, 'absolute', ToleranceLevel)


clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end