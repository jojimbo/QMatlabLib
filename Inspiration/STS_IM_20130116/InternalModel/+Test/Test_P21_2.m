%% Unit test P21-2
% Scenario Shock Interpolation and Extrapolation

function Test_P21_2
disp('################ Starting Test_P21_2 ################');
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, 'P21-2TestingData.mat'));
disp('.....Testing interpolation for PCA factors for EUR.....');
intvalues1PCA = internalModel.Util.Interpolation(targettenorsPCA, modifiedPCA(1,11).EV, {modifiedPCA(1,11).Term}, 'linear');
% We test it with no specified interpolation method and cell array input
% for the targets
intvalues2PCA = internalModel.Util.Interpolation(targettenorsPCA, modifiedPCA(1,11).EV, {modifiedPCA(1,11).Term});

disp('.....Testing interpolation for EQIV factors for AEX-Vol-Factor.....');
intvalues1VolFactor = internalModel.Util.Interpolation(targetsVol, volFactorData, axisVolFactor, 'linear');
intvalues2VolFactor = internalModel.Util.Interpolation(targetsVol, volFactorData, axisVolFactor);

disp('.....Testing interpolation for EQIV caps for AEX-Vol-Factor.....');
intvalues1VolCap = internalModel.Util.Interpolation(targetsVolCap, volCapData, axisVolCap, 'linear');
intvalues2VolCap = internalModel.Util.Interpolation(targetsVolCap, volCapData, axisVolCap);

disp('.....Testing interpolation for FXIV for EUR/GBP-Vol-Factor.....');
intvalues1VolFX = internalModel.Util.Interpolation(targetsFXVol, volFXdata, axisFXVol, 'linear');
intvalues2VolFX = internalModel.Util.Interpolation(targetsFXVol, volFXdata, axisFXVol);

save(fullfile('+Test', 'Results', computer, filesep, 'P21-2Results.mat'), 'intvalues2PCA',...
    'expectedvaluesPCA', 'intvalues2VolFactor', 'expectedvaluesVolFactor', ...
    'intvalues2VolCap', 'expectedvaluesVolCap', ...
    'intvalues2VolFX', 'expectedvaluesFXFactor');


assertElementsAlmostEqual(intvalues2PCA, expectedvaluesPCA, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2VolFactor, expectedvaluesVolFactor, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2VolCap, expectedvaluesVolCap, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2VolFX,expectedvaluesFXFactor,'relative',ToleranceLevel)

clear
disp('################ Passed Test_P21_2 ################');
disp(' ');

end