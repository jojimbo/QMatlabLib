classdef InstrumentFactory < engine.factories.BaseFactory    
    % InstrumentFactory - A factory class responsible for creating curve objects
    %
    % InstrumentFactory Properties:
    % 
    % InstrumentFactory Methods:
    % InstrumentFactory - The constructor
    methods (Access = public)
        function [factory] = InstrumentFactory() 
            % Explicit call to super class constructor  
            confman = engine.util.config.ConfMan.instance();
            factory = factory@engine.factories.BaseFactory(fullfile(confman.quant, '+instruments'), '@*');
        end
    end
    
    methods (Access = protected)  
        function [model] = instantiate(~, name, varargin)
            % instantiate  Return an instance of a specified curve
            %   This method instantiates the curve that will be returned by
            %   the generic get method from the BaseFactory class
            %
            %   See also get.

            model = quant.instruments.(name)(varargin{:});
        end
    end
end

