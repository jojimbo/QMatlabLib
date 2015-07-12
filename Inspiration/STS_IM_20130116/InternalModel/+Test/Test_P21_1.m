%% Unit test P21-1
% Market Data Interpolation and Extrapolation

function Test_P21_1
disp('################ Starting Test_P21_1 ################');
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, 'P21-1TestingData.mat'));
disp('.....Testing 1D interpolation for IR.....');
CurveEURSWAP = internalModel.Curve('EUR-SWAP', tenorsIR, valuesIR);
intvalues1IR = internalModel.Util.Interpolation(targettenorsIR, CurveEURSWAP.Data, {CurveEURSWAP.Tenor}, 'linear');
% We test it with no specified interpolation method and cell array input
% for the targets
intvalues2IR = internalModel.Util.Interpolation(targetsIR, CurveEURSWAP.Data, {CurveEURSWAP.Tenor});

disp('.....Testing 2D interpolation for EQIV.....');
intvalues1EQIV = internalModel.Util.Interpolation(targetsEQIV, valuesEQIV, axesEQIV, 'linear');
intvalues2EQIV = internalModel.Util.Interpolation(targetsEQIV, valuesEQIV, axesEQIV);

disp('.....Testing 2D interpolation for IRIV.....');
intvalues1IRIV = internalModel.Util.Interpolation(targetsIRIV, valuesIRIV, axesIRIV, 'linear');
intvalues2IRIV = internalModel.Util.Interpolation(targetsIRIV, valuesIRIV, axesIRIV);

disp('.....Testing 2D interpolation for FXIV.....');
intvalues1FXIV = internalModel.Util.Interpolation(targetsFXIV, valuesFXIV, axesFXIV, 'linear');
intvalues2FXIV = internalModel.Util.Interpolation(targetsFXIV, valuesFXIV, axesFXIV);

save(fullfile('+Test', 'Results', computer, filesep, 'P21-1Results.mat'), 'intvalues2FXIV', 'expectedvaluesFXIV',...
    'intvalues2IRIV', 'expectedvaluesIRIV', 'intvalues2EQIV', 'expectedvaluesEQIV',...
    'intvalues2IR', 'expectedvaluesIR', 'ToleranceLevel');


assertElementsAlmostEqual(intvalues2IR, expectedvaluesIR, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2EQIV, expectedvaluesEQIV, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2IRIV, expectedvaluesIRIV, 'relative', ToleranceLevel)
assertElementsAlmostEqual(intvalues2FXIV, expectedvaluesFXIV, 'relative', ToleranceLevel)


clear
disp('################ Passed Test_P21_1 ################');
disp(' ');

end