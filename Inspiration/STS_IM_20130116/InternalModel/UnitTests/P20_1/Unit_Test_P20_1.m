% STS-IM UNIT TEST
% P20-1
% 29 November 2012

function [bool] = Unit_Test_P20_1(testPath, codePath)
%% CSV FILE - STS IDENTIFIERS:
%       irCurveFile
%       equityReFile
%       forexFile
%       swaptionImpVolFile
%       eqIndFile
%       fxImpVolData
%       scenFile
%       pcaFile
%       bfVolVolFile
%       eqVolVolFile
%       reVolVolFile
%       irVolVolFile
%       fxVolVolFile
%       volatilityCapFile

%% File Declarations:
disp('### Start Unit_Test_P20_1');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase = [];
headerFileChng = [];

% Scenario Files
scenarioFile1_Base         = [testPath 'ASE_dummy.csv'];
scenarioFile1_flexNrOfRF   = [testPath 'ASE_dummy_flexNrOfRFtruncated.csv'];
scenarioFile1_flexNrOfScen = [testPath 'ASE_dummy_flexNrOfScen_v2.csv'];


%% Collect Headers & Scenario Data
% Prepare Header
disp('Start loading..');
headerBase = [];
headerChng = [];

% Collect Scenario Data
contents1_Base         = getCsvContents('scenFile', scenarioFile1_Base,         []);
contents1_flexNrOfRF   = getCsvContents('scenFile', scenarioFile1_flexNrOfRF,   []);
contents1_flexNrOfScen = getCsvContents('scenFile', scenarioFile1_flexNrOfScen, []);
disp('Finished loading');


if (~any(any(isnan(contents1_Base.ScenarioMatrix))))
    disp('PASSED : Base Scenario Matrix');
    b0 = true;
else
    disp('FAILED : Base Scenario Matrix');
    b0 = false;
end

%% Processing & Test Acceptance
if (size(contents1_flexNrOfScen.ScenarioMatrix, 1) == 50) && (~any(any(isnan(contents1_flexNrOfScen.ScenarioMatrix))))
    disp('PASSED : flexible nr of Scenario''s');
    b1 = true;
else
    disp('FAILED : flexible nr of Scenario''s');
    b1 = false;
end


if (size(contents1_flexNrOfRF.ScenarioMatrix, 2) == 383) && (~any(any(isnan(contents1_flexNrOfRF.ScenarioMatrix))))
    disp('PASSED : flexible nr of Risk Factors');
    b2 = true;
else
    disp('FAILED : flexible nr of Risk Factors');
    b2 = false;
end


bool = b0 && b1 && b2;
cd(currentPath); % Go back

end


function csvContents = getCsvContents(identifier, filename, header)
% Collect CSV file contents
% Prepare Dummy Calculation Object, for use in 'Configuration' methods
% Generic Properties
calcObj.configFile = '';
calcObj.parameters.headerFile = '';

% Custom Properties
calcObj.parameters.(identifier) = filename;
calcObj.header = header;

% COLLECT RAW CSV CONTENTS
% Create Configuration Object and Read File
calcObj.configuration = internalModel.Configuration(calcObj);
csvContents = calcObj.configuration.csvFileContents.(identifier);

end
