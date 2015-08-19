classdef ValueConverterFactory
    % creates value converter.    
    
    properties
    end
    
    methods(Static)
        % Creates a value converter from the given name.
        % The value converter should be implemented inside of Converter
        % package to be owned by the Pillar 1.
        function converter = Create(name)
            converter = Converter.([name 'ValueConverter']);
        end
    end
    
end

