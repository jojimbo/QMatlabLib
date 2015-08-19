% convert numeric value to string value.
function formattedValue = FormatModelValue( value )
    numberFormat = prursg.Util.ConfigurationUtil.GetCalibrationNumberFormat();
    if ~isempty(numberFormat)
        formattedValue = num2str(value, numberFormat);
    else
        formattedValue = num2str(value);
    end
end

