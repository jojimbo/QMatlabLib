% STS-IM UNIT TEST
% P20-7
% 05 December 2012

function [bool] = Unit_Test_P20_7(testPath, codePath)
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
disp('### Start Unit_Test_P20_7');
currentPath = pwd;
cd(codePath); % Go to code

% Header File
headerFileBase = [testPath 'IDEAL_header.csv'];

% Instruments Files
instruments_ZCBwithoutCS = [testPath 'instruments_ZCBwithoutCS.csv'];
instruments_ZCBwithCS    = [testPath 'instruments_ZCBwithCS.csv'];
instruments_EquityFw     = [testPath 'instruments_EquityForwards.csv'];


%% Collect Headers
% Prepare Headers
headerBase = internalModel.Utilities.csvreadCell(headerFileBase);


%% Processing & Test Acceptance

% 1. Correct Instrument File Loading: ZCB with- and without Credit Spread
% 1.A. 'instruments_ZCBwithoutCS.csv'

% Prepare dummy 'calcObj'
calcObj.configFile              = '';
calcObj.parameters.headerFile   = '';
calcObj.parameters.('instFile') = instruments_ZCBwithoutCS;
calcObj.header                  = headerBase;
calcObj.configuration           = internalModel.Configuration(calcObj);

% Collect ZCB Instruments
dataZCB = calcObj.configuration.processInstrData('ZeroCouponBond');

% Verify ZCB contents
benchDC     = {'USD-SWAP'; 'JPY-SWAP'; 'USD-SWAP'; 'EUR-SWAP'; 'EUR-SWAP'; ...
               'EUR-SWAP'; 'EUR-SWAP'; 'USD-SWAP'; 'EUR-SWAP'; 'EUR-SWAP'};
benchTenors = [12775; 5475; 9125; 2920; 91; 13505; 365; 2190; 9125; 21900];

if      all(strcmpi(dataZCB.domesticCurve, benchDC)) && ...
        all(eq(dataZCB.tenor, benchTenors))

    % All Tenors and Domestic Curves match the benchmark
    disp('PASSED : Zero Coupon Bond Benchmarking of loaded Tenors and Domestic Curves');
    b1a = true;

else
    % Benchmark test fails
    disp('FAILED : Zero Coupon Bond Benchmarking of loaded Tenors and Domestic Curves');
    b1a = true;
end

% 1.B. 'instruments_ZCBwithCS.csv'
% Prepare dummy 'calcObj'
calcObj.configFile              = '';
calcObj.parameters.headerFile   = '';
calcObj.parameters.('instFile') = instruments_ZCBwithCS;
calcObj.header                  = headerBase;
calcObj.configuration           = internalModel.Configuration(calcObj);

% Collect ZCB Instruments
dataZCB = calcObj.configuration.processInstrData('ZeroCouponBond');

% Verify ZCB contents
benchCS = 'TestCR-AAA';

if all(strcmpi(dataZCB.creditSpread, benchCS))

    % Credit Spread correctly propagated
    disp('PASSED : Zero Coupon Bond Benchmarking of Credit Spread Definition');
    b1b = true;

else
    % Benchmark test fails
    disp('FAILED : Zero Coupon Bond Benchmarking of Credit Spread Definition');
    b1b = true;
end

%% Summary
bool = b1a && b1b;
cd(currentPath); % Go back

end
