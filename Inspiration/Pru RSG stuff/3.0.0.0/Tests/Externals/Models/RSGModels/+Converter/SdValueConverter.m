
classdef SdValueConverter < prursg.Converter.IValueConverter
   
    properties
        NoOfSignificantDigits
    end
    
    methods
        function obj = SdValueConverter()
            obj.NoOfSignificantDigits = 9;
        end
              
        function newValue = Convert(obj, value)
            
            if isempty(obj.NoOfSignificantDigits) || obj.NoOfSignificantDigits <= 0
                throw(MException('SdValueConverter:Convert', 'Either the NoOfSignificantDigits property is not set or the property value is invalid.'));
            end
            
            if ~isnumeric(value) && ~islogical(value)
                throw(MException('SdValueConverter:Convert', 'Numeric input value is required.'));
            end
            
            if ~isempty(value)                
                og = 10.^(floor(log10(abs(value)) - obj.NoOfSignificantDigits + 1));
                newValue = round(value ./ og) .* og;
                newValue(find(value == 0)) = 0;
            end
        end
    end 
    
end

