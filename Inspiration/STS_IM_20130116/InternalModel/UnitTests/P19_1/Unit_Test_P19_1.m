% STS-IM UNIT TEST
% P19-1
% 20 November 2012

function [bool] = Unit_Test_P19_1(testPath, codePath)
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
disp('### Start Unit_Test_P19_1');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase = [testPath 'IDEAL_header.csv'];
headerFileChng = [testPath 'IDEAL_header_headerChanged.csv'];

% IR Curve Files
irCurveFile1_Base        = [testPath 'ir_swap_zero_curve20120629.csv'];
irCurveFile1_FlexCurrTnr = [testPath 'ir_swap_zero_curve20120629_flexibleNrofCurrAndTenors.csv'];
irCurveFile1_NegCurr     = [testPath 'ir_swap_zero_curve20120629_negativeCurr.csv'];

irCurveFile2_Base        = [testPath 'ir_swap_zero_curve20111230.csv'];
irCurveFile2_FlexCurrTnr = [testPath 'ir_swap_zero_curve20111230_flexibleNrofCurrAndTenors.csv'];
irCurveFile2_NegCurr     = [testPath 'ir_swap_zero_curve20111230_negativeCurr.csv'];
irCurveFile2_HeaderChng  = [testPath 'ir_swap_zero_curve20111230_headerChanged.csv'];


%% Collect Headers & IR Data
% Prepare Header
disp('Start loading..');
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect IR Curves
[contents1_Base,        irCurve1_Base]        = getCsvContents('irCurveFile', irCurveFile1_Base,        headerBase);
[contents1_FlexCurrTnr, irCurve1_FlexCurrTnr] = getCsvContents('irCurveFile', irCurveFile1_FlexCurrTnr, headerBase);
[contents1_NegCurr,     irCurve1_NegCurr]     = getCsvContents('irCurveFile', irCurveFile1_NegCurr,     headerBase);

[contents2_Base         irCurve2_Base]        = getCsvContents('irCurveFile', irCurveFile2_Base,        headerBase);
[contents2_FlexCurrTnr  irCurve2_FlexCurrTnr] = getCsvContents('irCurveFile', irCurveFile2_FlexCurrTnr, headerBase);

[contents2_NegCurr      irCurve2_NegCurr]     = getCsvContents('irCurveFile', irCurveFile2_NegCurr,     headerBase);
[contents2_HeaderChng   irCurve2_HeaderChng]  = getCsvContents('irCurveFile', irCurveFile2_HeaderChng,  headerChng);
disp('Finished loading');


%% Processing & Test Acceptance
if size(irCurve1_FlexCurrTnr.Curves{end}.Data, 1) == 109
    disp('PASSED : flexible nr of Tenors (dataset 1)');
    b1 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 1)');
    b1 = false;
end


if size(irCurve2_FlexCurrTnr.Curves{5}.Data, 1) == 134
    disp('PASSED : flexible nr of Tenors (dataset 2)');
    b2 = true;
else
    disp('FAILED : flexible nr of Tenors (dataset 2)');
    b2 = false;
end


if find(strcmp(irCurve1_FlexCurrTnr.CurveNames,'CR1-SWAP')) == 10
    disp('PASSED : flexible nr of currencies (dataset 1) ');
    b3 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 1) ');
    b3 = false;
end


if size(irCurve2_FlexCurrTnr.CurveNames, 2) == 32
    disp('PASSED : flexible nr of currencies (dataset 2) ');
    b4 = true;
else
    disp('FAILED : flexible nr of currencies (dataset 2) ');
    b4 = false;
end


if  find(strcmp(irCurve2_HeaderChng.CurveNames,'BGN-SWAP')) == 2
    disp('PASSED : header change (dataset 2) ');
    b5 = true;
else
    disp('FAILED : header change (dataset 2) ');
    b5 = false;
end


if strcmpi(lastwarn,'negative data found in IR Curve File!')
    disp('PASSED : detection negative data');
    b6 = true;
else
    disp('FAILED : detection negative data');
    b6 = false;
end

bool = b1 && b2 && b3 && b4 && b5 && b6;
cd(currentPath); % Go back

end


function [csvContents, irCurves]= getCsvContents(identifier, filename, header)
% Collect CSV file contents
% Prepare Dummy Calculation Object, for use in 'Configuration' methods
% Generic Properties
calcObj.configFile = '';
calcObj.parameters.headerFile = '';

% Custom Properties
calcObj.parameters.(identifier) = filename;
calcObj.header = header;

% A. COLLECT RAW CSV CONTENTS
% Create Configuration Object and Read File
calcObj.configuration = internalModel.Configuration(calcObj);
csvContents = calcObj.configuration.csvFileContents.(identifier);

% B. COLLECT INTEREST RATE CURVES
irCurves = internalModel.CurveCollection(calcObj, identifier);

end
