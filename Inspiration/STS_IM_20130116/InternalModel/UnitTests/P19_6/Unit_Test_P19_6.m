% STS-IM UNIT TEST
% P19-6
% 20 November 2012

function [bool] = Unit_Test_P19_6(testPath, codePath)
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
disp('### Start Unit_Test_P19_6');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase   = [testPath 'IDEAL_header.csv'];
headerFileChng   = [testPath 'IDEAL_header_headerChanged.csv'];

% File Definitions
data1_Base       = [testPath 'equity_imp_vol_surface20120629.csv'];
data1_FlexCurr   = [testPath 'equity_imp_vol_surface20120629_flexNrOfCurrMoneyMaturity.csv'];
data1_NegCurr    = [testPath 'equity_imp_vol_surface20120629_negativeVal.csv'];

data2_Base       = [testPath 'equity_imp_vol_surface20111230.csv'];
data2_FlexCurr   = [testPath 'equity_imp_vol_surface20111230_flexNrOfCurrMoneyMaturity.csv'];
data2_HeaderChng = [testPath 'equity_imp_vol_surface20111230_headerChanged.csv'];


%% Collect Headers & Data
disp('Start loading..');

% Prepare Header
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect Data
contents1_Base       = getCsvContents('eqIndFile', data1_Base,       headerBase);
contents1_FlexCurr   = getCsvContents('eqIndFile', data1_FlexCurr,   headerBase);
contents1_NegCurr    = getCsvContents('eqIndFile', data1_NegCurr,    headerBase);

contents2_Base       = getCsvContents('eqIndFile', data2_Base,       headerBase);
contents2_FlexCurr   = getCsvContents('eqIndFile', data2_FlexCurr,   headerBase);
contents2_HeaderChng = getCsvContents('eqIndFile', data2_HeaderChng, headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if size(contents1_FlexCurr.identifiers, 1) == 72
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b1 = false;
end


if find(strcmp(contents2_FlexCurr.identifiers, 'USAGG_USD_UNHEDG-Volatility Surface')) == 102 
    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b2 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b2 = false;
end


if size(contents1_FlexCurr.GnVolMnyTrmSfNODE, 1) == 9373
    disp('PASSED : flexible nr of Tenors (dataset 1)');
    b3 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 1)');
    b3 = false;
end


if  find(strcmp(contents2_HeaderChng.identifiers, '.AEX-Volatility Surface')) == 2
    disp('PASSED : header change (dataset 2) ');
    b4 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b4 = false;
end


if strcmpi(lastwarn, 'negative data found in equity Imp File!')
    disp('PASSED : detection negative data');
    b5 = true;
else
    disp('FAILED : detection negative data');
    b5 = false;
end

bool = b1 && b2 && b3 && b4 && b5 ;
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
