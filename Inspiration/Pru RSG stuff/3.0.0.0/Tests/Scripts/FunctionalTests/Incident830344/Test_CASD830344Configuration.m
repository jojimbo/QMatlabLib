% These tests cover 830344(Consistent scenario values).
% Update the app.config file if necessary.

function test_suite = Test_CASD830344Configuration()
    initTestSuite;
end

% Tests configuration retrieval.
function TestConfiguration()
    assertEqual('%.3g', prursg.Util.ConfigurationUtil.GetCalibrationNumberFormat);    
    assertEqual('%.3g', prursg.Util.ConfigurationUtil.GetScenarioValueNumberFormat);    
end


% Tests ValueConverterFactory
function TestValueConverterFactory()
    converter = prursg.Converter.ValueConverterFactory.Create('Sd2');    
    assertEqual('Converter.Sd2ValueConverter', class(converter));
end



% Tests ConvertScenarioValue
function TestConvertScenarioValue1
    value = 0.123456;
    newValue = prursg.Util.ConvertScenarioValue(value);
    assertEqual(0.123, newValue);
end

% Tests ConvertScenarioValue
function TestConvertScenarioValue2
    value = [0.123456 3.23125 12345.23];
    newValue = prursg.Util.ConvertScenarioValue(value); 
    expectedValue = [0.123 3.23 12300];
    assertEqual(expectedValue, newValue);
end

% Tests ConvertScenarioValue
function TestConvertScenarioValue3
    value = [0.123456 3.23125 12345.23;0.001234 3.22332 24.233];
    newValue = prursg.Util.ConvertScenarioValue(value); 
    expectedValue = [0.123 3.23 12300; 0.00123 3.22 24.2];
    assertEqual(expectedValue, newValue);
end

