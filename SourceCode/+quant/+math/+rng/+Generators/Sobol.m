classdef Sobol < prursg.RandomNumberGeneration.BaseRandomNumberGenerator
    %PRURSG.MT_RNG Sobol sequence Generator
    %
    
    properties ( SetAccess = public )
		skip
		dimension
    end
    properties ( SetAccess = private )
		Randstream
    end
	
    methods
        function obj = Sobol()
			%obj = obj@prursg.Engine.RandomNumberGenerator('sobol');
            obj = obj@prursg.RandomNumberGeneration.BaseRandomNumberGenerator('sobol');
            obj.skip = 1; %default value
            obj.dimension = 1; %default value
        end
        
    end
    
    methods
		function obj = Initiate(obj)
			obj.Randstream = qrandstream('sobol', obj.dimension, 'Skip', obj.skip);
			%aux = scramble(obj.randstream.PointSet, 'MatousekAffineOwen')
			%obj.Randstream = qrandstream(aux)
		end
		
        function randomnumbers = Rand(obj , m, ~)
			randomnumbers = rand(obj.Randstream, m, obj.dimension);
        end
        
		
    end
end