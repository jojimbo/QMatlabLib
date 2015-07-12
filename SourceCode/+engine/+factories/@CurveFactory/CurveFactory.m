classdef CurveFactory < engine.factories.BaseFactory    
    % CurveFactory - A factory class responsible for creating curve objects
    %
    % CurveFactory Properties:
    % 
    % CurveFactory Methods:
    % CurveFactory - The constructor
    methods (Access = public)
        function [factory] = CurveFactory() 
            % Explicit call to super class constructor     
            confman = engine.util.config.ConfMan.instance();
            factory = factory@engine.factories.BaseFactory(fullfile(confman.quant, '+curves'), '@*');
        end
    end
    
    methods (Access = protected)  
        function [curve] = instantiate(~, name, varargin)
            % instantiate  Return an instance of a specified curve
            %   This method instantiates the curve that will be returned by
            %   the generic get method from the BaseFactory class
            %
            %   See also get.

            curve = quant.curves.(name)(varargin{:});
        end
    end
end

