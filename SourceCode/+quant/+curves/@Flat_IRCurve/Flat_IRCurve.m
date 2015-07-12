classdef Flat_IRCurve < engine.curves.CurveBase & IRDataCurve  
    % Flat_IRCurve - A proxy for MATLAB's IRDataCurve class with a flat
    % term structure
    %
    % Flat_IRCurve Properties:
    % 
    % Flat_IRCurve Methods:
    % Flat_IRCurve - The constructor
    % name - Returns the name by which the curve is to be identified
    % desc - Returns a description of the curve
    
    properties
    end
    
    methods       
        function [curve] = Flat_IRCurve(Settle, Dates, r, varargin) 
            % IRDataCurve  The IRDataCurve constructor
            %   Invoke the base class constructor
            %
            %   See also IRDataCurve.
            
            Data = r*ones(1,length(Dates));
        
            curve@IRDataCurve('Zero', Settle, Dates, Data, varargin{:});
        end
        
        function [name] = name(~)
            % name  The name of the curve
            %   Returns the name of the curve which may be more informative 
            %   than the class name.
            %
            %   See also desc.
            name = 'Flat_IRCurve';
        end
        
        function [desc] = desc(~)
            % desc  A description of the curve
            %   Returns a description of the curve which may be more informative 
            %   than the class name alone.
            %
            %   See also name.
            desc = 'A thin wrapper around MATLAB''s IRDataCurve implementation with a flat term structure';
        end
    end    
end

