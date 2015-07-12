%% Unit test P23-1
% Market Data Interpolation and Extrapolation

function Test_P23_1
disp('################ Starting Test_P23_1 ################');
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, 'P23-1TestingData.mat'));
expRshock = expectedresults(:,8);
expRshock(1) = []; %expected Rshocks in a column vector format
expRshock = cell2mat(expRshock);
expRtot = expectedresults(:,10);
expRtot(1) = []; %expected final InterestRate in a column vector format
expRtot = cell2mat(expRtot);

disp('.....Running calcInterestRate on obj with input data.....');
objnew = objPreCalcIntRate.calcInterestRate;

obtainedRshock = zeros(numel(objnew.instCol.Instruments)*5, 1);
for i=1:numel(objnew.instCol.Instruments)
    %expectedRshock = objExpectedResults.shockedInterestLib{i,3}(2:end);
    % we create a double array with all the Rshocks calculated
    obtainedRshock((i-1)*5 + 1: i*5) = objnew.shockedInterestLib{i,3}(2:end);
end

obtainedIR = zeros(numel(objnew.instCol.Instruments)*5, 1);
for i=1:numel(objExpectedResults.instCol.Instruments)
    %expectedIR = objExpectedResults.instCol.Instruments{i}.InterestRate(2:end);
    obtainedIR((i-1)*5 + 1: i*5) = objnew.instCol.Instruments{i}.interestRate(2:end);
end

save(fullfile('+Test', 'Results', computer, filesep, 'P23-1Results.mat'), 'expRshock',...
    'obtainedRshock', 'expRtot', 'obtainedIR', 'objnew',...
    'objPreCalcIntRate');


disp('.....Comparing with expected results for Rshocks saved in shockedInterestLib.....');
assertElementsAlmostEqual(obtainedRshock, expRshock, 'relative', ToleranceLevel)
disp('.....Comparing with expected results for InterestRates stored on all the instruments.....');
assertElementsAlmostEqual(obtainedIR, expRtot, 'relative', ToleranceLevel)

clear
disp('################ Passed Test_P23_1 ################');
disp(' ');

end