% STS-IM UNIT TEST
% P19-7
% 20 November 2012

function [bool] = Unit_Test_P19_7(testPath, codePath)
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
disp('### Start Unit_Test_P19_7');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase   = [testPath 'IDEAL_header.csv'];
headerFileChng   = [testPath 'IDEAL_header_headerChanged.csv'];

% File Definitions
data1_Base       = [testPath 'fx_implied_volatility20120629.csv'];
data1_FlexCurr   = [testPath 'fx_implied_volatility20120629_flexNrCurr.csv'];
data1_FlexTnr    = [testPath 'fx_implied_volatility20120629_flexNrTenorOptionMaturities.csv'];
data1_NegCurr    = [testPath 'fx_implied_volatility20120629_negativeValues.csv'];

data2_Base       = [testPath 'fx_implied_volatility20111230.csv'];
data2_FlexCurr   = [testPath 'fx_implied_volatility20111230_flexNrCurr.csv'];
data2_FlexTnr    = [testPath 'fx_implied_volatility20111230_flexNrTenorOptionMaturities.csv'];
data2_HeaderChng = [testPath 'fx_implied_volatility20111230_headerChanged.csv'];


%% Collect Headers & Data
disp('Start loading..');

% Prepare Header
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect Data
contents1_Base       = getCsvContents('fxImpVolData', data1_Base,       headerBase);
contents1_FlexCurr   = getCsvContents('fxImpVolData', data1_FlexCurr,   headerBase);
contents1_FlexTnr    = getCsvContents('fxImpVolData', data1_FlexTnr,    headerBase);
contents1_NegCurr    = getCsvContents('fxImpVolData', data1_NegCurr,    headerBase);

contents2_Base       = getCsvContents('fxImpVolData', data2_Base,       headerBase);
contents2_FlexCurr   = getCsvContents('fxImpVolData', data2_FlexCurr,   headerBase);
contents2_FlexTnr    = getCsvContents('fxImpVolData', data2_FlexTnr,    headerBase);
contents2_HeaderChng = getCsvContents('fxImpVolData', data2_HeaderChng, headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if find(strcmp(contents1_FlexCurr.identifiers, 'EUR/CR1_Volatility_Surface')) == 29 
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b1 = false;
end


if size(contents2_FlexCurr.identifiers, 1) == 31
    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b2 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b2 = false;
end

valuesKeyword = 'valueDATA';
if size(contents1_FlexTnr.(valuesKeyword), 1) == 2446
    disp('PASSED : flexible nr of Tenors (dataset 1)');
    b3 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 1)');
    b3 = false;
end


if size(contents2_FlexTnr.(valuesKeyword), 1) == 2491
    disp('PASSED : flexible nr of Tenors (dataset 2)');
    b4 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 2)');
    b4 = false;
end


if  find(strcmp(contents2_HeaderChng.identifiers, 'EUR/BGN_Volatility_Surface')) == 2
    disp('PASSED : header change (dataset 2) ');
    b5 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b5 = false;
end


if strcmpi(lastwarn, 'negative data found in for ex Imp File!')
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
