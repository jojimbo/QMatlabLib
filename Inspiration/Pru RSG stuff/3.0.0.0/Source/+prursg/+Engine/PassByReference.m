classdef PassByReference < handle
    % Being a 'handle' class it facilitates passing by reference large matrices    
    % d = makeHugeMatrix();
    % makeCpuIntensiveChanges(PassByReference(d));
    properties
        data
    end
    
    methods
        function obj = PassByReference(d)
            obj.data = d;
        end
    end
        
end

