function formattedValue = FormatNumber( inputValue, formatString )
%format input value to a string value.
    if ~isempty(formatString)
        formattedValue = num2str(inputValue, formatString);
    else
        formattedValue = num2str(inputValue);
    end
    
end

