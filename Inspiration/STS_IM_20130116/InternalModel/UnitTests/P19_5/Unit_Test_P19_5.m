% STS-IM UNIT TEST
% P19-5
% 20 November 2012

function [bool] = Unit_Test_P19_5(testPath, codePath)
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
disp('### Start Unit_Test_P19_5');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase   = [testPath 'IDEAL_header.csv'];
headerFileChng   = [testPath 'IDEAL_header_headerChanged.csv'];

% File Definitions
data1_Base       = [testPath 'swaption_implied_volatility20120629.csv'];
data1_FlexCurr   = [testPath 'swaption_implied_volatility20120629_flexNrCurr.csv'];
data1_FlexTnr    = [testPath 'swaption_implied_volatility20120629_flexNrOfTenorAndMaturity.csv'];
data1_NegCurr    = [testPath 'swaption_implied_volatility20120629_negativeVal.csv'];

data2_Base       = [testPath 'swaption_implied_volatility20111230.csv'];
data2_FlexCurr   = [testPath 'swaption_implied_volatility20111230_flexNrCurr.csv'];
data2_FlexTnr    = [testPath 'swaption_implied_volatility20111230_flexNrOfTenorAndMaturity.csv'];
data2_HeaderChng = [testPath 'swaption_implied_volatility20111230_headerChanged.csv'];


%% Collect Headers & Data
disp('Start loading..');

% Prepare Header
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect Data
contents1_Base       = getCsvContents('swaptionImpVolFile', data1_Base,        headerBase);
contents1_FlexCurr   = getCsvContents('swaptionImpVolFile', data1_FlexCurr,    headerBase);
contents1_FlexTnr    = getCsvContents('swaptionImpVolFile', data1_FlexTnr,     headerBase);
contents1_NegCurr    = getCsvContents('swaptionImpVolFile', data1_NegCurr,     headerBase);

contents2_Base       = getCsvContents('swaptionImpVolFile', data2_Base,         headerBase);
contents2_FlexCurr   = getCsvContents('swaptionImpVolFile', data2_FlexCurr,     headerBase);
contents2_FlexTnr    = getCsvContents('swaptionImpVolFile', data2_FlexTnr,     headerBase);
contents2_HeaderChng = getCsvContents('swaptionImpVolFile', data2_HeaderChng,   headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if find(strcmp(contents1_FlexCurr.identifiers, 'CR2_Swaption_Volatility_Surface'))==20
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b1 = false;
end


if size(contents2_FlexCurr.identifiers, 1) == 35
    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b2 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b2 = false;
end


if size(contents1_FlexTnr.GenVolTrmTrmSfNODE, 1) == 5866
    disp('PASSED : flexible nr of Tenors (dataset 1)');
    b3 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 1)');
    b3 = false;
end


if size(contents2_FlexTnr.GenVolTrmTrmSfNODE, 1) == 5846
    disp('PASSED : flexible nr of Tenors (dataset 2)');
    b4 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 2)');
    b4 = false;
end


if find(strcmp(contents2_HeaderChng.identifiers, 'BGN_Swaption_Volatility_Surface')) == 2
    disp('PASSED : header change (dataset 2) ');
    b5 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b5 = false;
end


if strcmpi(lastwarn, 'negative data found in swaption Imp Vol File!')
    disp('PASSED : detection negative data');
    b6 = true;
else
    disp('FAILED : detection negative data');
    b6 = false;
end

bool = b1 && b2 && b3 && b4 && b5 && b6;
cd(currentPath); % Go back

end


function [csvContents, varargout]= getCsvContents(identifier, filename, header)
% Collect CSV file contents
% Prepare Dummy Calculation Object, for use in 'Configuration' methods
% Generic Properties
varargout          = [];
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
