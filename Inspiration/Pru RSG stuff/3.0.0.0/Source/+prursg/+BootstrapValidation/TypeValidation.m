classdef TypeValidation
    properties
        type = [];
    end
    methods 
        function tv = TypeValidation(allowedType)
            tv.type = allowedType;
        end
    end
    enumeration 
        ValidationResult ({'string', 'double', 'image', 'table'})
        CustomProperty ({'string', 'double', 'date'})
    end
end

