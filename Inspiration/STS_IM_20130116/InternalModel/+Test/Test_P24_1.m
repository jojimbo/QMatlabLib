%% Unit test P24-1
% Market Data Interpolation and Extrapolation

function Test_P24_1
disp('################ Starting Test_P24_1 ################');
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, 'P24-1TestingData.mat'));

disp('.....Pasting the correspoding InterestRates into each one of the instruments.....');
for i=1:numel(objPreCalcIntRate.instCol.Instruments)
    objPreCalcIntRate.instCol.Instruments{i}.interestRate = inputtotIR((i-1)*6 + 1: i*6);
end

disp('.....Pricing instruments.....');
obtainedZCBPrices = zeros(6, numel(objPreCalcIntRate.instCol.Instruments));
for i=1:numel(objPreCalcIntRate.instCol.Instruments)
    obtainedZCBPrices(:,i) = objPreCalcIntRate.instCol.Instruments{i}.value;
end

save(fullfile('+Test', 'Results', computer, filesep, 'P24-1Results.mat'),...
    'obtainedZCBPrices',...
    'expectedZCBvalues', 'objPreCalcIntRate');

assertElementsAlmostEqual(obtainedZCBPrices, expectedZCBvalues, 'relative', ToleranceLevel)

clear
disp('################ Passed Test_P24_1 ################');
disp(' ');

end