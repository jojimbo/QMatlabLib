% Defines methods to be implemented by all value converters.
classdef IValueConverter
    
    properties
    end
    
    methods(Abstract)
        % allows converts one value to another.
        % for scenarion value conversion, it should be able to convert one
        % double matrix to another.        
        newValue = Convert(obj, value)
    end
    
end

