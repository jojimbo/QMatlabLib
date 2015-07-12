% STS-IM UNIT TEST
% P20-3
% 29 November 2012

function [bool] = Unit_Test_P20_3(testPath, codePath)
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
disp('### Start Unit_Test_P20_3');
currentPath = pwd;
cd(codePath); % Go to code

% Header Files
headerFileBase                  = [testPath 'IDEAL_header.csv'];
headerFileChng                  = [testPath 'IDEAL_header_headerChanged.csv'];

% Volatility Factor Files
bfVolVolFactor_Base             = [testPath 'BF_vol_vol_factor.csv'];
eqVolVolFactor_Base             = [testPath 'EQ_vol_vol_factor.csv'];
fxVolVolFactor_Base             = [testPath 'FX_vol_vol_factor.csv'];
irVolVolFactor_Base             = [testPath 'IR_vol_vol_factor.csv'];
reVolVolFactor_Base             = [testPath 'RE_vol_vol_factor.csv'];

bfVolVolFactor_flexNrOfTenors   = [testPath 'BF_vol_vol_factor_flexNrOfTenors.csv'];
eqVolVolFactor_flexNrOfTenors   = [testPath 'EQ_vol_vol_factor_flexNrOfTenors.csv'];
fxVolVolFactor_flexNrOfTenors   = [testPath 'FX_vol_vol_factor_flexNrOfTenors.csv'];
irVolVolFactor_flexNrOfTenors   = [testPath 'IR_vol_vol_factor_flexNrOfTenors.csv'];
reVolVolFactor_flexNrOfTenors   = [testPath 'RE_vol_vol_factor_flexNrOfTenors.csv'];

bfVolVolFactor_flexNrOfEI       = [testPath 'BF_vol_vol_factor_flexNrOfEI.csv'];
eqVolVolFactor_flexNrOfEI       = [testPath 'EQ_vol_vol_factor_flexNrOfEI.csv'];
fxVolVolFactor_flexNrOfEI       = [testPath 'FX_vol_vol_factor_flexNrOfEI.csv'];
irVolVolFactor_flexNrOfEI       = [testPath 'IR_vol_vol_factor_flexNrOfEI.csv'];
reVolVolFactor_flexNrOfEI       = [testPath 'RE_vol_vol_factor_flexNrOfEI.csv'];

bfVolVolFactor_negData          = [testPath 'BF_vol_vol_factor_negData.csv'];
eqVolVolFactor_negData          = [testPath 'EQ_vol_vol_factor_negData.csv'];
fxVolVolFactor_negData          = [testPath 'FX_vol_vol_factor_negData.csv'];
irVolVolFactor_negData          = [testPath 'IR_vol_vol_factor_negData.csv'];
reVolVolFactor_negData          = [testPath 'RE_vol_vol_factor_negData.csv'];

bfVolVolFactor_headerChanged    = [testPath 'BF_vol_vol_factor_headerChanged.csv'];
eqVolVolFactor_headerChanged    = [testPath 'EQ_vol_vol_factor_headerChanged.csv'];
fxVolVolFactor_headerChanged    = [testPath 'FX_vol_vol_factor_headerChanged.csv'];
irVolVolFactor_headerChanged    = [testPath 'IR_vol_vol_factor_headerChanged.csv'];
reVolVolFactor_headerChanged    = [testPath 'RE_vol_vol_factor_headerChanged.csv'];


%% Collect Headers & Volatility Data
% Prepare Header
disp('Start loading..');
headerBase                = internalModel.Utilities.csvreadCell(headerFileBase);
headerChng                = internalModel.Utilities.csvreadCell(headerFileChng);

% Collect Volatility Data
bfVolVol_Base             = getCsvContents('bfVolVolFile', bfVolVolFactor_Base,           headerBase);
eqVolVol_Base             = getCsvContents('eqVolVolFile', eqVolVolFactor_Base,           headerBase);
fxVolVol_Base             = getCsvContents('fxVolVolFile', fxVolVolFactor_Base,           headerBase);
irVolVol_Base             = getCsvContents('irVolVolFile', irVolVolFactor_Base,           headerBase);
reVolVol_Base             = getCsvContents('reVolVolFile', reVolVolFactor_Base,           headerBase);

bfVolVol_flexNrOfTenors   = getCsvContents('bfVolVolFile', bfVolVolFactor_flexNrOfTenors, headerBase);
eqVolVol_flexNrOfTenors   = getCsvContents('eqVolVolFile', eqVolVolFactor_flexNrOfTenors, headerBase);
fxVolVol_flexNrOfTenors   = getCsvContents('fxVolVolFile', fxVolVolFactor_flexNrOfTenors, headerBase);
irVolVol_flexNrOfTenors   = getCsvContents('irVolVolFile', irVolVolFactor_flexNrOfTenors, headerBase);
reVolVol_flexNrOfTenors   = getCsvContents('reVolVolFile', reVolVolFactor_flexNrOfTenors, headerBase);

bfVolVol_flexNrOfEI       = getCsvContents('bfVolVolFile', bfVolVolFactor_flexNrOfEI,     headerBase);
eqVolVol_flexNrOfEI       = getCsvContents('eqVolVolFile', eqVolVolFactor_flexNrOfEI,     headerBase);
fxVolVol_flexNrOfEI       = getCsvContents('fxVolVolFile', fxVolVolFactor_flexNrOfEI,     headerBase);
irVolVol_flexNrOfEI       = getCsvContents('irVolVolFile', irVolVolFactor_flexNrOfEI,     headerBase);
reVolVol_flexNrOfEI       = getCsvContents('reVolVolFile', reVolVolFactor_flexNrOfEI,     headerBase);

bfVolVol_negData          = getCsvContents('bfVolVolFile', bfVolVolFactor_negData,        headerBase);
eqVolVol_negData          = getCsvContents('eqVolVolFile', eqVolVolFactor_negData,        headerBase);
fxVolVol_negData          = getCsvContents('fxVolVolFile', fxVolVolFactor_negData,        headerBase);
irVolVol_negData          = getCsvContents('irVolVolFile', irVolVolFactor_negData,        headerBase);
reVolVol_negData          = getCsvContents('reVolVolFile', reVolVolFactor_negData,        headerBase);

bfVolVol_headerChanged    = getCsvContents('bfVolVolFile', bfVolVolFactor_headerChanged,  headerChng);
eqVolVol_headerChanged    = getCsvContents('eqVolVolFile', eqVolVolFactor_headerChanged,  headerChng);
fxVolVol_headerChanged    = getCsvContents('fxVolVolFile', fxVolVolFactor_headerChanged,  headerChng);
irVolVol_headerChanged    = getCsvContents('irVolVolFile', irVolVolFactor_headerChanged,  headerChng);
reVolVol_headerChanged    = getCsvContents('reVolVolFile', reVolVolFactor_headerChanged,  headerChng);

disp('Finished loading');


%% Processing & Test Acceptance
% tenorKeyword = 'GnVolMnyTrmSf1AXS';
tenorKeyword = 'termDATA';

% 1. Correct Loading
% No specific test
b1 = true;


% 2. Modified Volatility Files Behavior: 'flexNrOfTenors'
% 2.1. BF_vol_vol_factor_flexNrOfTenors.csv
%       A. For BCOPC3A2_INDEX-Vol-Factor: 120 day tenor added
%       B. For BCOPC3A8_INDEX-Vol-Factor: 5475 and 9125 day tenors removed
%       C. For USAGG_USD_UNHEDG_INDEX-Vol-Factor: 19000, 19500, 20000 day tenors added
itemLines  = bfVolVol_flexNrOfTenors.itemLines;
tenors     = bfVolVol_flexNrOfTenors.(tenorKeyword);

% Test 2.1.A
itemInd    = find(strcmpi(bfVolVol_flexNrOfTenors.names, 'BCOPC3A2_INDEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if any(eq(itemTenors, 120))
    disp('PASSED : Added Tenor [120] for ''BCOPC3A2_INDEX-Vol-Factor''');
    b2_1a = true;
else
    disp('FAILED : Added Tenor [120] for ''BCOPC3A2_INDEX-Vol-Factor''');
    b2_1a = false;
end

% Test 2.1.B
itemInd    = find(strcmpi(bfVolVol_flexNrOfTenors.names, 'BCOPC3A8_INDEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  ~any(eq(itemTenors, 5475)) && ...
    ~any(eq(itemTenors, 9125))

    disp('PASSED : Removed Tenors [5475 9125] for ''BCOPC3A8_INDEX-Vol-Factor''');
    b2_1b = true;
else
    disp('FAILED : Removed Tenors [5475 9125] for ''BCOPC3A8_INDEX-Vol-Factor''');
    b2_1b = false;
end

% Test 2.1.C
itemInd    = find(strcmpi(bfVolVol_flexNrOfTenors.names, 'USAGG_USD_UNHEDG_INDEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 19000)) && ...
    any(eq(itemTenors, 19500)) && ...
    any(eq(itemTenors, 20000))

    disp('PASSED : Added Tenors [19000 19500 20000] for ''USAGG_USD_UNHEDG_INDEX-Vol-Factor''');
    b2_1c = true;
else
    disp('FAILED : Added Tenors [19000 19500 20000] for ''USAGG_USD_UNHEDG_INDEX-Vol-Factor''');
    b2_1c = false;
end


% 2.2. EQ_vol_vol_factor_flexNrOfTenors.csv
%       A. For AEX-Vol-Factor: 19000, 19365, 19730, 20095, 20825, 21555 and 22650 day tenors added
%       B. For KLSE-Vol-Factor: all tenors are removed, except 18250 day tenor.
itemLines  = eqVolVol_flexNrOfTenors.itemLines;
tenors     = eqVolVol_flexNrOfTenors.(tenorKeyword);

% Test 2.2.A
itemInd    = find(strcmpi(eqVolVol_flexNrOfTenors.names, 'AEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 19000)) && ...
    any(eq(itemTenors, 19365)) && ...
    any(eq(itemTenors, 19730)) && ...
    any(eq(itemTenors, 20095)) && ...
    any(eq(itemTenors, 20825)) && ...
    any(eq(itemTenors, 21555)) && ...
    any(eq(itemTenors, 22650))

    disp('PASSED : Added Tenors [19000 19365 19730 20095 20825 21555 22650] for ''AEX-Vol-Factor''');
    b2_2a = true;
else
    disp('FAILED : Added Tenors [19000 19365 19730 20095 20825 21555 22650] for ''AEX-Vol-Factor''');
    b2_2a = false;
end

% Test 2.2.B
itemInd    = find(strcmpi(eqVolVol_flexNrOfTenors.names, 'KLSE-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 18250)) && ...
    numel(itemTenors, 1)

    disp('PASSED : Only 1 Tenor [18250] for ''KLSE-Vol-Factor''');
    b2_2b = true;
else
    disp('FAILED : Only 1 Tenor [18250] for ''KLSE-Vol-Factor''');
    b2_2b = false;
end


% 2.3. FX_vol_vol_factor_flexNrOfTenors.csv
%       A. For EUR/BGN-Vol-Factor: 5475 day tenor is removed
%       B. For EUR/USD-Vol-Factor: 18615 day tenor is added
itemLines  = fxVolVol_flexNrOfTenors.itemLines;
tenors     = fxVolVol_flexNrOfTenors.(tenorKeyword);

% Test 2.3.A
itemInd    = find(strcmpi(fxVolVol_flexNrOfTenors.names, 'EUR/BGN-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if ~any(eq(itemTenors, 5475))
    disp('PASSED : Removed Tenor [5475] for ''EUR/BGN-Vol-Factor''');
    b2_3a = true;
else
    disp('FAILED : Removed Tenor [5475] for ''EUR/BGN-Vol-Factor''');
    b2_3a = false;
end

% Test 2.3.B
itemInd    = find(strcmpi(fxVolVol_flexNrOfTenors.names, 'EUR/USD-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if any(eq(itemTenors, 18615))
    disp('PASSED : Added Tenor [18615] for ''EUR/USD-Vol-Factor''');
    b2_3b = true;
else
    disp('FAILED : Added Tenor [18615] for ''EUR/USD-Vol-Factor''');
    b2_3b = false;
end

tenorKeyword = 'GnVolMnyTrmSf1AXS';

% 2.4. IR_vol_vol_factor_flexNrOfTenors.csv
%       A. For AUD-Swaption-Vol-Factor: 5500 and 7777 tenors added
%       B. For BGN-Swaption-Vol-Factor: 1825-2555,3650-2555 tenors removed
itemLines  = irVolVol_flexNrOfTenors.itemLines;
tenors     = irVolVol_flexNrOfTenors.(tenorKeyword);

% Test 2.4.A
itemInd    = find(strcmpi(irVolVol_flexNrOfTenors.names, 'AUD-Swaption-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 5500)) && ...
    any(eq(itemTenors, 7777))

    disp('PASSED : Added Tenors [5500 7777] for ''AUD-Swaption-Vol-Factor''');
    b2_4a = true;
else
    disp('FAILED : Added Tenors [5500 7777] for ''AUD-Swaption-Vol-Factor''');
    b2_4a = false;
end

% Test 2.4.B
% ??? Don't understand...

tenorKeyword = 'termDATA';

% 2.5. RE_vol_vol_factor_flexnrOfTenors.csv
%       A. For ELUK_INDEX-Vol-Factor: 6000 and 6666 tenors added
%       B. For RMS_INDEX-Vol-Factor: 2555 till 10950 tenors removed
itemLines  = reVolVol_flexNrOfTenors.itemLines;
tenors     = reVolVol_flexNrOfTenors.(tenorKeyword);

% Test 2.5.A
itemInd    = find(strcmpi(reVolVol_flexNrOfTenors.names, 'ELUK_INDEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if  any(eq(itemTenors, 6000)) && ...
    any(eq(itemTenors, 6666))

    disp('PASSED : Added Tenors [6000 6666] for ''ELUK_INDEX-Vol-Factor''');
    b2_5a = true;
else
    disp('FAILED : Added Tenors [6000 6666] for ''ELUK_INDEX-Vol-Factor''');
    b2_5a = false;
end

% Test 2.5.B
itemInd    = find(strcmpi(reVolVol_flexNrOfTenors.names, 'RMS_INDEX-Vol-Factor'));
itemTenors = cell2mat(tenors(itemLines(itemInd, 1):itemLines(itemInd, 2)));

if itemTenors(end) < 2555

    disp('PASSED : Removed Tenors [2555 : 10950] for ''RMS_INDEX-Vol-Factor''');
    b2_5b = true;
else
    disp('FAILED : Removed Tenors [2555 : 10950] for ''RMS_INDEX-Vol-Factor''');
    b2_5b = false;
end


% 3. Modified Volatility Files Behavior: 'flexNrOfEI'
% 3.1. BF_vol_vol_factor_flexNrOfEI.csv
%       A. TEST1_INDEX-Vol-Factor and TEST2_INDEX-Vol-Factor added as new equity indices
if  any(strcmpi(bfVolVol_flexNrOfEI.names, 'TEST1_INDEX-Vol-Factor')) && ...
    any(strcmpi(bfVolVol_flexNrOfEI.names, 'TEST2_INDEX-Vol-Factor'))

    disp('PASSED : Added Equity Indices ''TEST1_INDEX-Vol-Factor'' and ''TEST1_INDEX-Vol-Factor''');
    b3_1a = true;
else
    disp('FAILED : Added Equity Indices ''TEST1_INDEX-Vol-Factor'' and ''TEST1_INDEX-Vol-Factor''');
    b3_1a = false;
end


% 3.2. EQ_vol_vol_factor_flexNrOfEI.csv
%       A. All indices removed, excepts XU100-Vol-Factor
if  any(strcmpi(eqVolVol_flexNrOfEI.names, 'XU100-Vol-Factor')) && ...
    eq(numel(eqVolVol_flexNrOfEI.names), 1)

    disp('PASSED : Equity Index ''XU100-Vol-Factor'' is the only one');
    b3_2a = true;
else
    disp('FAILED : Equity Index ''XU100-Vol-Factor'' is the only one');
    b3_2a = false;
end


% 3.3. FX_vol_vol_factor_flexNrOfEI.csv
%       A. TEST1/BGN-Vol-Factor and TEST2/BRL-Vol-Factor added as new currencies
if  any(strcmpi(fxVolVol_flexNrOfEI.names, 'TEST1/BGN-Vol-Factor')) && ...
    any(strcmpi(fxVolVol_flexNrOfEI.names, 'TEST2/BRL-Vol-Factor'))

    disp('PASSED : Added Currencies ''TEST1/BGN-Vol-Factor'' and ''TEST2/BRL-Vol-Factor''');
    b3_3a = true;
else
    disp('FAILED : Added Currencies ''TEST1/BGN-Vol-Factor'' and ''TEST2/BRL-Vol-Factor''');
    b3_3a = false;
end


% 3.4. IR_vol_vol_factor_flexNrOfEI.csv
%       A. All currencies are removed, excepts AUD-Swaption-Vol-Factor
if  any(strcmpi(irVolVol_flexNrOfEI.names, 'AUD-Swaption-Vol-Factor')) && ...
    eq(numel(irVolVol_flexNrOfEI.names), 1)

    disp('PASSED : All currencies are removed, except ''AUD-Swaption-Vol-Factor''');
    b3_4a = true;
else
    disp('FAILED : All currencies are removed, except ''AUD-Swaption-Vol-Factor''');
    b3_4a = false;
end


% 3.5. RE_vol_vol_factor_flexNrOfEI.csv
%       A. TEST1_INDEX-Vol-Factor is added at the end of the file.
nameInd = find(strcmpi(reVolVol_flexNrOfEI.names, 'TEST1_INDEX-Vol-Factor'));

if any(nameInd) && eq(nameInd, numel(reVolVol_flexNrOfEI.names))

    disp('PASSED : Added at the end: ''TEST1_INDEX-Vol-Factor''');
    b3_5a = true;
else
    disp('FAILED : Added at the end:  ''TEST1_INDEX-Vol-Factor''');
    b3_5a = false;
end

valuesKeyword = 'valueDATA';
% 4. Modified Volatility Files Behavior: 'negData'
% 4.1. BF_vol_vol_factor_negData.csv
%       A. Last row contains a negative number
if lt(bfVolVol_negData.(valuesKeyword){end}, 0)

    disp('PASSED : Last element negative, ''BF_vol_vol_factor_negData''');
    b4_1a = true;
else
    disp('FAILED : Last element negative, ''BF_vol_vol_factor_negData''');
    b4_1a = false;
end


% 4.2. EQ_vol_vol_factor_negData.csv
%       A. Row 126 contains negative number (Line 115 in Filtered Data!)
if lt(eqVolVol_negData.(valuesKeyword){115}, 0)

    disp('PASSED : element [115] negative, ''EQ_vol_vol_factor_negData''');
    b4_2a = true;
else
    disp('FAILED : element [115] negative, ''EQ_vol_vol_factor_negData''');
    b4_2a = false;
end


% 4.3. FX_vol_vol_factor_negData.csv
%       A. Row 219 contains negative number (Line 201 in Filtered Data!)
if lt(fxVolVol_negData.(valuesKeyword){201}, 0)

    disp('PASSED : element [201] negative, ''fxVolVol_negData''');
    b4_3a = true;
else
    disp('FAILED : element [201] negative, ''fxVolVol_negData''');
    b4_3a = false;
end

valuesKeyword = 'GnVolMnyTrmSfNODE';
% 4.4. IR_vol_vol_factor_negData.csv
%       A. Row 3 contains negative number (Line 1 in Filtered Data!)
if lt(irVolVol_negData.(valuesKeyword){1}, 0)

    disp('PASSED : element [1] negative, ''irVolVol_negData''');
    b4_4a = true;
else
    disp('FAILED : element [1] negative, ''irVolVol_negData''');
    b4_4a = false;
end

valuesKeyword = 'valueDATA';
% 4.5. RE_vol_vol_factor_negData.csv
%       A. Last row contains negative number
if lt(reVolVol_negData.(valuesKeyword){end}, 0)

    disp('PASSED : element [1] negative, ''reVolVol_negData''');
    b4_5a = true;
else
    disp('FAILED : element [1] negative, ''reVolVol_negData''');
    b4_5a = false;
end


% 5. Modified Header Files Behavior: 'IDEAL_header_headerChanged.csv'
%    Check if working with modified header yields expected results
if any(find(strcmpi(bfVolVol_Base.identifiers,     bfVolVol_headerChanged.identifiers)))
    disp('PASSED : Correct Identifiers, ''bfVolVol_headerChanged''');
    b5_1a = true;
else
    disp('Failed : Correct Identifiers, ''bfVolVol_headerChanged''');
    b5_1a = false;
end

if any(find(strcmpi(bfVolVol_Base.names,           bfVolVol_headerChanged.names)))
    disp('PASSED : Correct Names, ''bfVolVol_headerChanged''');
    b5_1b = true;
else
    disp('Failed : Correct Names, ''bfVolVol_headerChanged''');
    b5_1b = false;
end

if any(find(strcmpi(eqVolVol_Base.identifiers,     eqVolVol_headerChanged.identifiers)))
    disp('PASSED : Correct Identifiers, ''eqVolVol_headerChanged''');
    b5_2a = true;
else
    disp('Failed : Correct Identifiers, ''eqVolVol_headerChanged''');
    b5_2a = false;
end

if any(find(strcmpi(eqVolVol_Base.names,           eqVolVol_headerChanged.names)))
    disp('PASSED : Correct Names, ''eqVolVol_headerChanged''');
    b5_2b = true;
else
    disp('FAILED : Correct Names, ''eqVolVol_headerChanged''');
    b5_2b = true;
end

if any(find(strcmpi(fxVolVol_Base.identifiers,     fxVolVol_headerChanged.identifiers)))
    disp('PASSED : Correct Identifiers, ''fxVolVol_headerChanged''');
    b5_3a = true;
else
    disp('Failed : Correct Identifiers, ''fxVolVol_headerChanged''');
    b5_3a = false;
end
    
if any(find(strcmpi(fxVolVol_Base.names,           fxVolVol_headerChanged.names)))
    disp('PASSED : Correct Names, ''fxVolVol_headerChanged''');
    b5_3b = true;
else
    disp('FAILED : Correct Names, ''fxVolVol_headerChanged''');
    b5_3b = true;
end

if any(find(strcmpi(reVolVol_Base.identifiers,     reVolVol_headerChanged.identifiers)))
    disp('PASSED : Correct Identifiers, ''reVolVol_headerChanged''');
    b5_4a = true;
else
    disp('Failed : Correct Identifiers, ''reVolVol_headerChanged''');
    b5_4a = false;
end

if any(find(strcmpi(reVolVol_Base.names,           reVolVol_headerChanged.names)))
    disp('PASSED : Correct Names, ''reVolVol_headerChanged''');
    b5_4b = true;
else
    disp('FAILED : Correct Names, ''reVolVol_headerChanged''');
    b5_4b = true;
end


%% Summary
bool = b1    && b2_1a && b2_1b && b2_1c && b2_2a && b2_2b && b2_3a && b2_3b && b2_4a && ...
       b2_5a && b2_5b && b3_1a && b3_2a && b3_3a && b3_4a && b3_5a && b4_1a && b4_2a && ...
       b4_3a && b4_4a && b4_5a && b5_1a && b5_1b && b5_2a && b5_2b && b5_3a && b5_3b && ...
       b5_4a && b5_4b;
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
