
classdef Sd2ValueConverter < prursg.Converter.IValueConverter
   
    properties
        NoOfSignificantDigits
    end
    
    methods
        function obj = Sd2ValueConverter()
            obj.NoOfSignificantDigits = 3;
        end
              
        function newValue = Convert(obj, value)
            
            if isempty(obj.NoOfSignificantDigits) || obj.NoOfSignificantDigits <= 0
                throw(MException('Sd2ValueConverter:Convert', 'Either the NoOfSignificantDigits property is not set or the property value is invalid.'));
            end
            
            if ~isnumeric(value) && ~islogical(value)
                throw(MException('Sd2ValueConverter:Convert', 'Numeric input value is required.'));
            end
            
            if ~isempty(value)                
                newValue = str2double(arrayfun(@(x)num2str(x, ['%.' num2str(obj.NoOfSignificantDigits) 'g']), value, 'UniformOutput', false));
            end
        end
    end 
    
end
