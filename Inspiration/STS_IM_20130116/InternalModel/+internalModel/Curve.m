%% Curve class definition
% value class

classdef Curve
    %% Properties
    %
    % *_GetAccess = public, SetAccess = private_*
    %
    % * |Data|
    % * |Name|
    % * |Tenor|
    
    properties(GetAccess = public, SetAccess = private)
        Data
        Name
        Tenor        
    end
    
    %% Methods
    %
    % * |obj    = Curve(name, tenor, data)| _constructor_
    methods
        
        function obj = Curve(name, tenor, data)
            %% Curve _constructor_
            % |obj = Curve(name, tenor, data)|
            %
            % An equity implied volatility curve or interest rate curve
            %
            % Inputs:
            %
            % * |name|  _char
            % * |tenor| _double_
            % * |data|  _double_
            
            obj.Name    = name;
            obj.Tenor   = tenor;
            obj.Data    = data;
            
        end

    end
end

