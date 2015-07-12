%% Unit Test_P28_2
% Output Cube in LOCAL currency (not converted to EUR or anything else)
 
function Test_P28_2
disp(['################ Starting ' mfilename ' ################']);
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

if exist(fullfile('+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']))
    load(fullfile('+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']));
elseif exist(fullfile('Internalmodel', '+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']))
    load(fullfile('Internalmodel', '+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']));
else
end
configFilePath = fullfile(pwd, '+Test', filesep, 'Configuration Files', computer, 'configDemo_P28_2.txt');
disp(['.....Running STS_CM with ConfiFile: ' configFilePath ' .....']);
disp('.....Using EquityForward instruments since value=1 for now .....');

results = STS_CM(configFilePath);

obtainedCubePath = results.cube.path;

%expectedCube = expectedresults.cube.data; % Loaded in TestingData.mat

aux = load(fullfile(obtainedCubePath, 'Cube.mat'));

save(fullfile('+Test', 'Results', computer, filesep, [mfilename '_Results.mat']), ...
    'obtainedCubePath', 'aux', 'expectedCube' ...
    );

disp('.....Checking values of the Cube');
assertElementsAlmostEqual(aux.obj.data, expectedCube, 'relative', ToleranceLevel)
assertElementsAlmostEqual(results.cube.data, expectedCube, 'relative', ToleranceLevel)

clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end