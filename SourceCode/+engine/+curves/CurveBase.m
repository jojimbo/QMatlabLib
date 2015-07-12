classdef CurveBase < handle
    % CurveBase - The base class of all curves
    % Abstract class to represent common procedures, functions and
    % properties of all cuves
    %
    % CurveBase Properties:
    % 
    % CurveBase Methods:
    % name - Returns the name by which the curve is to be identified
    % desc - Returns a description of the curve
    
    %% Properties
    properties
    end
    
    %% Methods
    methods (Abstract)
        % The name by which the curve is to be identified
        name(obj) 
        
        % A description of the curve
        desc(obj)   
    end
end

