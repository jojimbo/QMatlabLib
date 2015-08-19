classdef ICloneable < handle
    %ICLONEABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        newObj = Clone(obj)
    end
    
end

