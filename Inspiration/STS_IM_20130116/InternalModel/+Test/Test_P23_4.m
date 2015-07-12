%% Unit Test_P23_4
% Calculation of shocked FX Volatilities

function Test_P23_4
disp(['################ Starting ' mfilename ' ################']);
addpath(genpath(fullfile('matlab_xunit_3.1', filesep)));
ToleranceLevel = sqrt(eps);
disp(['Relative ToleranceLevel = ' num2str(ToleranceLevel)]);

load(fullfile('+Test', filesep, 'InputData', filesep, [mfilename 'TestingData.mat']));

% We store the current runtime for the Test
modifiedStr      = strrep(datestr(now), ' ', '_');
modifiedStr      = strrep(modifiedStr, ':', '_');
modifiedStr      = strrep(modifiedStr, '-', '_'); % To be revisited later
obj.runtime      = modifiedStr;

vector_ttm = [45 120 400 800 2000 4000 8000 19000];

% obj is loaded from the TestingData.mat file
[obj2] = obj.runTopLevel();

obtainedresultsGBP = [];
mats1 = [];
moneyness1 = [];
spotPrices1 = [];
obtainedresultsJPY = [];
mats2 = [];
moneyness2 = [];
spotPrices2 = [];
for iInst = 1: numel(obj2.instCol.Instruments)
    if ~isempty(find(vector_ttm == obj2.instCol.Instruments{iInst}.TimeToMaturity, 1))
        if strcmp(obj2.instCol.Instruments{iInst}.ForeignCurrency, 'GBP')
            if isempty(find(mats1 == obj2.instCol.Instruments{iInst}.TimeToMaturity, 1))
                mats1 = [mats1 obj2.instCol.Instruments{iInst}.TimeToMaturity];
                obtainedresultsGBP = [obtainedresultsGBP obj2.instCol.Instruments{iInst}.volatility];
                moneyness1 = [moneyness1 obj2.instCol.Instruments{iInst}.Moneyness];
                spotPrices1 = [spotPrices1 obj2.instCol.Instruments{iInst}.spotPrice];
            end
        elseif strcmp(obj2.instCol.Instruments{iInst}.ForeignCurrency, 'JPY')
            if isempty(find(mats2 == obj2.instCol.Instruments{iInst}.TimeToMaturity, 1))
                mats2 = [mats2 obj2.instCol.Instruments{iInst}.TimeToMaturity];
                obtainedresultsJPY = [obtainedresultsJPY obj2.instCol.Instruments{iInst}.volatility];
                moneyness2 = [moneyness2 obj2.instCol.Instruments{iInst}.Moneyness];
                spotPrices2 = [spotPrices2 obj2.instCol.Instruments{iInst}.spotPrice];
            end
        end
    end
end

save(fullfile('+Test', 'Results', computer, filesep, [mfilename '_Results.mat']), ...
    'obtainedresultsGBP', 'expectedresultsGBP', 'mats1', 'moneyness1', 'spotPrices1', ...
    'obtainedresultsJPY', 'expectedresultsJPY', 'mats2', 'moneyness2', 'spotPrices2' ...
    );

disp('.....Checking values of the Shocked Volatilites');
assertElementsAlmostEqual(obtainedresultsGBP, expectedresultsGBP, 'relative', ToleranceLevel)
assertElementsAlmostEqual(obtainedresultsJPY, expectedresultsJPY, 'relative', ToleranceLevel)


clear
disp(['################ Passed ' mfilename ' ################']);
disp(' ');

end