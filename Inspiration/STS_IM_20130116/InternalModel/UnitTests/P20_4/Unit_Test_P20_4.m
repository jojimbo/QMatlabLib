% STS-IM UNIT TEST
% P20-4
% 04 December 2012

function [bool] = Unit_Test_P20_4(testPath, codePath)
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
disp('### Start Unit_Test_P20_4');
currentPath = pwd;
cd(codePath); % Go to code

% Header File
headerFileBase                = [testPath 'IDEAL_header.csv'];

% Ceiling Factor Files
volatility_cap_Base           = [testPath 'volatility_cap.csv'];
volatility_cap_flexNrOfTenors = [testPath 'volatility_cap_flexNrOfTenors.csv'];
volatility_cap_flexNrOfInd    = [testPath 'volatility_cap_flexNrOfInd.csv'];
volatility_cap_negData        = [testPath 'volatility_cap_negData.csv'];


%% Collect Headers & Ceiling Factor Data
% Prepare Header
disp('Start loading..');
headerBase            = internalModel.Utilities.csvreadCell(headerFileBase);

% Collect Ceiling Factor Data
volCap_Base           = getCsvContents('volatilityCapFile', volatility_cap_Base,           headerBase);
volCap_flexNrOfTenors = getCsvContents('volatilityCapFile', volatility_cap_flexNrOfTenors, headerBase);
volCap_flexNrOfInd    = getCsvContents('volatilityCapFile', volatility_cap_flexNrOfInd,    headerBase);
volCap_negData        = getCsvContents('volatilityCapFile', volatility_cap_negData,        headerBase);

disp('Finished loading');


%% Processing & Test Acceptance
tenorKeyword = 'termDATA';

% 1. Correct Loading
% No specific test
b1 = true;


% 2. Modified Ceiling Factor Files Behavior: 'flexNrOfTenors'
% 2.1. volatility_cap_flexNrOfTenors.csv
%       A. For AEX-Volatility Cap: 800, 900, 1000 day tenors (3) added
%       B. For USAGG_USD_UNHEDG_INDEX-Volatility Cap: all tenors removed, except 730
itemLines  = volCap_flexNrOfTenors.itemLines;
tenors     = volCap_flexNrOfTenors.(tenorKeyword);

% Test 2.1.A
itemInd    = find(strcmpi(volCap_flexNrOfTenors.names, 'AEX-Volatility Cap'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 800)) && ...
    any(eq(itemTenors, 900)) && ...
    any(eq(itemTenors, 1000))

    disp('PASSED : Added Tenors [800, 900, 1000] for ''AEX-Volatility Cap''');
    b2_a = true;
else
    disp('FAILED : Added Tenors [800, 900, 1000] for ''AEX-Volatility Cap''');
    b2_a = false;
end

% Test 2.1.B
itemInd    = find(strcmpi(volCap_flexNrOfTenors.names, 'USAGG_USD_UNHEDG_INDEX-Volatility Cap'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 730)) && ...
    eq(numel(itemTenors), 1)

    disp('PASSED : All Tenors removed except [730] for ''USAGG_USD_UNHEDG_INDEX-Volatility Cap''');
    b2_b = true;
else
    disp('FAILED : All Tenors removed except [730] for ''USAGG_USD_UNHEDG_INDEX-Volatility Cap''');
    b2_b = false;
end


% 3. Modified Ceiling Factor Files Behavior: 'flexNrOfInd'
%       A. 'AEX-Volatility Cap' has been removed
%       B. 'TEST1_USD_TEST1_INDEX-Volatility Cap' has been added (at the end)

% Test 3.A
itemRemovedInd = find(strcmpi(volCap_flexNrOfInd.names, 'AEX-Volatility Cap'), 1);
itemAddedInd   = find(strcmpi(volCap_flexNrOfInd.names, 'TEST1_USD_TEST1_INDEX-Volatility Cap'));

if isempty(itemRemovedInd)
    disp('PASSED : Removed item: ''AEX-Volatility Cap''');
    b3_a = true;
else
    disp('FAILED : Removed item: ''AEX-Volatility Cap''');
    b3_a = false;
end

% Test 3.B
if  ~isempty(itemAddedInd) && ...
    eq(itemAddedInd, numel(volCap_flexNrOfInd.names))

    disp('PASSED : Added item: ''TEST1_USD_TEST1_INDEX-Volatility Cap'', at the end');
    b3_b = true;
else
    disp('FAILED : Added item: ''TEST1_USD_TEST1_INDEX-Volatility Cap'', at the end');
    b3_b = false;
end

valuesKeyword = 'valueDATA';
% 4. Modified Ceiling Factor Files Behavior: 'volatility_cap_negData.csv'
%       A. Row 846 contains negative number (Line 780 in Filtered Data!)
if lt(volCap_negData.(valuesKeyword){780}, 0)

    disp('PASSED : element [780] negative, ''volCap_negData''');
    b4 = true;
else
    disp('FAILED : element [780] negative, ''volCap_negData''');
    b4 = false;
end


%% Summary
bool = b1 && b2_a && b2_b && b3_a && b3_b && b4;
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
