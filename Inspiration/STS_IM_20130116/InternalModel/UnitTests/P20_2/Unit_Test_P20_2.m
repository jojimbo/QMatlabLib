% STS-IM UNIT TEST
% P20-2
% 29 November 2012

function [bool] = Unit_Test_P20_2(testPath, codePath)
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
disp('### Start Unit_Test_P20_2');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase = [testPath 'IDEAL_header.csv'];
headerFileChng = [testPath 'IDEAL_header_headerChanged.csv'];

% PCA Files
pcaFile1_Base          = [testPath 'matrix_parameter_curve.csv'];
pcaFile1_flexNrOfCurr  = [testPath 'matrix_parameter_curve_flexNrOffCurr.csv'];
pcaFile1_flexNrOfPCA   = [testPath 'matrix_parameter_curve_flexNrOfPCA.csv'];
pcaFile1_headerChanged = [testPath 'matrix_parameter_curve_headerChanged.csv'];


%% Collect Headers & PCA Data
% Prepare Header
disp('Start loading..');
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect PCA Data
contents1_Base          = getCsvContents('pcaFile', pcaFile1_Base,          headerBase);
contents1_flexNrOfCurr  = getCsvContents('pcaFile', pcaFile1_flexNrOfCurr,  headerBase);
contents1_flexNrOfPCA   = getCsvContents('pcaFile', pcaFile1_flexNrOfPCA,   headerBase); 
contents1_headerChanged = getCsvContents('pcaFile', pcaFile1_headerChanged, headerChng); 
disp('Finished loading');


%% Processing & Test Acceptance
% 1. Currency "EV_CR1_SWAP" must be available
currencyFull = 'EV_CR1_SWAP';
identifier   = textscan(currencyFull, '%s', 'Delimiter', '_');
currency     = identifier{1}{2};
currInd      = find(strcmpi({contents1_flexNrOfCurr.currency}, currency), 1);

if ~isempty(currInd)
    disp('PASSED : flexible nr of currencies');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies');
    b1 = false;
end


% 2. Test PCA Modifications:
%       A. For EV_AUD_SWAP: 30 day PCA vector is added
%       B. For EV_BGN_SWAP: 1095 day PCA vector is removed
%       C. For EV_BRL_SWAP: 800 and 1000 day PCA vector's are added

% A. 30 day PCA vector is added (AUD)
curInd = strcmpi({contents1_flexNrOfPCA.currency}, 'AUD');
term1  = contents1_flexNrOfPCA(curInd).Term(1);

if  eq(term1, 30) && ...
    eq(size(contents1_flexNrOfPCA(curInd).EV, 1), 103)

    disp('PASSED : Adding 30 day PCA Vector (AUD)');
    b2a = true;
else
    disp('FAILED : Adding 30 day PCA Vector (AUD)');
    b2a = false;
end

% B. 1095 day PCA vector is removed (BGN)
curInd = strcmpi({contents1_flexNrOfPCA.currency}, 'BGN');

if  ~any(eq(contents1_flexNrOfPCA(curInd).Term, 1095)) && ...
    eq(size(contents1_flexNrOfPCA(curInd).EV, 1), 103)

    disp('PASSED : Removing 1095 PCA Vector (BGN)');
    b2b = true;
else
    disp('FAILED : Removing 1095 PCA Vector (BGN)');
    b2b = false;
end

% C. 800 and 1000 day PCA vector's are added (BRL)
curInd = strcmpi({contents1_flexNrOfPCA.currency}, 'BRL');

if  any(eq(contents1_flexNrOfPCA(curInd).Term, 800))  && ...
    any(eq(contents1_flexNrOfPCA(curInd).Term, 1000)) && ...
    eq(size(contents1_flexNrOfPCA(curInd).EV, 1), 104)

    disp('PASSED : Adding 800 & 1000 day PCA Vector (BRL)');
    b2c = true;
else
    disp('PASSED : Adding 800 & 1000 day PCA Vector (BRL)');
    b2c = false;
end


% 3. HeaderChange must result in viable PCA Data
if  any(strcmpi({contents1_headerChanged.currency}, 'AUD')) && ...
    any(strcmpi({contents1_headerChanged.currency}, 'BGN'))

    disp('PASSED : Changed Headerfile for PCA');
    b3 = true;
else
    disp('PASSED : Changed Headerfile for PCA');
    b3 = false;
end


bool = b1 && b2a && b2b && b2c && b3;
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
