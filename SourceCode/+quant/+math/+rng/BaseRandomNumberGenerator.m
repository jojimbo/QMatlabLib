classdef BaseRandomNumberGenerator < prursg.RandomNumberGeneration.IRandGenerator
    %PRURSG.RandomNumberGeneration.BaseRandomNumberGenerator Base class for Random Number Generators
    %
    
    properties ( SetAccess = public )
        Identifier
    end
	
    methods
        function obj = BaseRandomNumberGenerator(identifier)
		% USE TRY CATCH TO CAPTURE ERRORS IN CASE THEY TRY TO USE A
		% GENERATOR THAT IS NOT SUPPORTED
			obj.Identifier = identifier;
        end
        
    end
    
    %We still need to implement the Abstract classes from the Interface
    %IRandGenerator
    
end
