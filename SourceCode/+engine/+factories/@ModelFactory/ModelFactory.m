classdef ModelFactory < engine.factories.BaseFactory    
    % CurveFactory - A factory class responsible for creating curve objects
    %
    % CurveFactory Properties:
    % 
    % CurveFactory Methods:
    % CurveFactory - The constructor
    methods (Access = public)
        function [factory] = ModelFactory() 
            % Explicit call to super class constructor  
            confman = engine.util.config.ConfMan.instance();
            factory = factory@engine.factories.BaseFactory(fullfile(confman.quant, '+models'), '@*');
        end
    end
    
    methods (Access = protected)  
        function [model] = instantiate(~, name, varargin)
            % instantiate  Return an instance of a specified curve
            %   This method instantiates the curve that will be returned by
            %   the generic get method from the BaseFactory class
            %
            %   See also get.

            model = quant.models.(name)(varargin{:});
        end
    end
end

