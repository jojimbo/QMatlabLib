classdef IRDataCurve < engine.curves.CurveBase & IRDataCurve  
    % IRDataCurve - A proxy for MATLAB's IRDataCurve class
    %
    % IRDataCurve Properties:
    % 
    % IRDataCurve Methods:
    % IRDataCurve - The constructor
    % name - Returns the name by which the curve is to be identified
    % desc - Returns a description of the curve
    
    properties
    end
    
    methods       
        function [curve] = IRDataCurve(varargin) 
            % IRDataCurve  The IRDataCurve constructor
            %   Invoke the base class constructor
            %
            %   See also IRDataCurve.
        
            curve@IRDataCurve(varargin{:});
        end
        
        function [name] = name(~)
            % name  The name of the curve
            %   Returns the name of the curve which may be more informative 
            %   than the class name.
            %
            %   See also desc.
            name = 'IRDataCurve';
        end
        
        function [desc] = desc(~)
            % desc  A description of the curve
            %   Returns a description of the curve which may be more informative 
            %   than the class name alone.
            %
            %   See also name.
            desc = 'A thin wrapper around MATLAB''s IRDataCurve implementation';
        end
    end    
end

