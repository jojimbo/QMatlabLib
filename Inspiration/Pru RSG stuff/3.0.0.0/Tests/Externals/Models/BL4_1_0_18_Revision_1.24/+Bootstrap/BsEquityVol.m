classdef BsEquityVol
    %BSEQUITYVOL Bootstrap for equity vol surfaces
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
         function obj = BsEquityVol()
        end
        function res = bs(obj, param)
            % take copy of incoming data
            res = param;
        end

    end
    
end

