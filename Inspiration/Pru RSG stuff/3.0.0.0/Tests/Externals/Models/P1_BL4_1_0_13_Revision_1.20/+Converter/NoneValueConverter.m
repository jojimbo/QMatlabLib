classdef NoneValueConverter < prursg.Converter.IValueConverter
    
    properties
    end
    
    methods
        function newValue = Convert(obj, value)
            newValue = value;
        end
    end
    
end

