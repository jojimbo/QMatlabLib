% STS-IM UNIT TEST
% P19-4
% 20 November 2012

function [bool] = Unit_Test_P19_4(testPath, codePath)
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
disp('### Start Unit_Test_P19_4');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase   = [testPath 'IDEAL_header.csv'];
headerFileChng   = [testPath 'IDEAL_header_headerChanged.csv'];

% File Definitions
data1_Base       = [testPath 'fx_foreign_exchange20111230.csv'];
data1_FlexCurr   = [testPath 'fx_foreign_exchange20111230_flexNrCurr.csv'];
data1_NegCurr    = [testPath 'fx_foreign_exchange20111230_negativeCurr.csv'];

data2_Base       = [testPath 'fx_foreign_exchange20120629.csv'];
data2_FlexCurr   = [testPath 'fx_foreign_exchange20120629_flexNrCurr.csv'];
data2_NegCurr    = [testPath 'fx_foreign_exchange20120629_negativeCurr.csv'];
data2_HeaderChng = [testPath 'fx_foreign_exchange20111230_headerChanged.csv'];


%% Collect Headers & FX Data
disp('Start loading..');

% Prepare Header
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect FX Curves
contents1_Base       = getCsvContents('forexFile', data1_Base,       headerBase);
contents1_FlexCurr   = getCsvContents('forexFile', data1_FlexCurr,   headerBase);
contents1_NegCurr    = getCsvContents('forexFile', data1_NegCurr,    headerBase);

contents2_Base       = getCsvContents('forexFile', data2_Base,       headerBase);
contents2_FlexCurr   = getCsvContents('forexFile', data2_FlexCurr,   headerBase);
contents2_NegCurr    = getCsvContents('forexFile', data2_NegCurr,    headerBase);
contents2_HeaderChng = getCsvContents('forexFile', data2_HeaderChng, headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if size(contents1_FlexCurr.identifiers, 1) == 27
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b1 = false;
end


if size(contents2_FlexCurr.identifiers, 1) == 38
    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b2 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b2 = false;
end


if find(strcmp(contents2_HeaderChng.identifiers, 'TRY')) == 29
    disp('PASSED : header change (dataset 2) ');
    b3 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b3 = false;
end


if strcmpi(lastwarn, 'negative data found in FOREX File!')
    disp('PASSED : detection negative data');
    b4 = true;
else
    disp('FAILED : detection negative data');
    b4 = false;
end

bool = b1 && b2 && b3 && b4 ;
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
