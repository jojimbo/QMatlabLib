% STS-IM UNIT TEST
% P19-2
% 20 November 2012

function [bool] = Unit_Test_P19_2(testPath, codePath)
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
disp('### Start Unit_Test_P19_2');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase   = [testPath 'IDEAL_header.csv'];
headerFileChng   = [testPath 'IDEAL_header_headerChanged.csv'];

% File Definitions
data1_Base       = [testPath 'ir_credit_spread20120629.csv'];
data1_FlexCS     = [testPath 'ir_credit_spread20120629_flexNrOfCS.csv'];
data1_FlexCurr   = [testPath 'ir_credit_spread20120629_flexNrOfCurr.csv'];
data1_FlexTnr    = [testPath 'ir_credit_spread20120629_flexNrOfTenors.csv'];

data2_Base       = [testPath 'ir_credit_spread20111230.csv'];
data2_FlexCS     = [testPath 'ir_credit_spread20111230_flexNrOfCS.csv'];
data2_FlexCurr   = [testPath 'ir_credit_spread20111230_flexNrOfCurr.csv'];
data2_FlexTnr    = [testPath 'ir_credit_spread20111230_flexNrOfTenors.csv'];
data2_HeaderChng = [testPath 'ir_credit_spread20111230_headerChanged.csv'];


%% Collect Headers & Data
disp('Start loading..');

% Prepare Header
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect Data
contents1_Base       = getCsvContents('spreadFile', data1_Base,       headerBase);
contents1_FlexCS     = getCsvContents('spreadFile', data1_FlexCS,     headerBase);
contents1_FlexCurr   = getCsvContents('spreadFile', data1_FlexCurr,   headerBase);
contents1_FlexTnr    = getCsvContents('spreadFile', data1_FlexTnr,    headerBase);

contents2_Base       = getCsvContents('spreadFile', data2_Base,       headerBase);
contents2_FlexCS     = getCsvContents('spreadFile', data2_FlexCS,     headerBase);
contents2_FlexCurr   = getCsvContents('spreadFile', data2_FlexCurr,   headerBase);
contents2_FlexTnr    = getCsvContents('spreadFile', data2_FlexTnr,    headerBase);
contents2_HeaderChng = getCsvContents('spreadFile', data2_HeaderChng, headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if size(contents1_FlexCurr.identifiers, 1) == 495
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b1 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b1 = false;
end


if (find(strcmp(contents2_FlexCurr.identifiers,'CR1-AA-SPREAD')) == 3 && ...
    find(strcmp(contents2_FlexCurr.identifiers,'CR2-AA-SPREAD')) == 8)

    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b2 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b2 = false;
end


if size(contents1_FlexTnr.GenZeroSurface0AXS, 1) == 6786
    disp('PASSED : flexible nr of Tenors (dataset 1)');
    b3 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 1)');
    b3 = false;
end


if size(contents2_FlexTnr.GenZeroSurface0AXS, 1) == 6772
    disp('PASSED : flexible nr of Tenors (dataset 2)');
    b4 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 2)');
    b4 = false;
end


if  (find(strcmp(contents1_FlexCS.identifiers, 'SEK-CREDITS1-SPREAD')) == 393 && ...
     find(strcmp(contents1_FlexCS.identifiers, 'HUF-CREDITS2-SPREAD')) == 484)

    disp('PASSED : flexible nr of credit spreads (dataset 1) ');
    b5 = true;
else
    disp('FAILED : flexible nr of credit spreads (dataset 1) ');
    b5 = false;
end


if (find(strcmp(contents2_FlexCS.identifiers, 'AUD')) == 3 && ...
    find(strcmp(contents2_FlexCS.identifiers, 'PEN')) == 337)
    
    disp('PASSED : flexible nr of credit spreads (dataset 2) ');
    b6 = true;
else
    disp('FAILED : flexible nr of credit spreads (dataset 2) ');
    b6 = false;
end


if find(strcmp(contents2_HeaderChng.identifiers,'AUD-A-SPREAD')) == 1
    disp('PASSED : header change (dataset 2) ');
    b7 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b7 = false;
end

bool = b1 && b2 && b3 && b4 && b5 && b6 && b7;
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
