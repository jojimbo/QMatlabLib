% converts scenario values by using a converter set in the configuration
% file.
function newValue = ConvertScenarioValue(value)
    persistent converter;
    
    if isempty(converter)        
        converterName = prursg.Util.ConfigurationUtil.GetScenarioValueConverterName();
        converter = prursg.Converter.ValueConverterFactory.Create(converterName);
    end
    
    newValue = converter.Convert(value);
end

