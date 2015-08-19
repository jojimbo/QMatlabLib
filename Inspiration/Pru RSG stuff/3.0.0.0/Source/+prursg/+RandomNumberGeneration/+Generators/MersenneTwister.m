classdef MersenneTwister < prursg.RandomNumberGeneration.BaseRandomNumberGenerator
    %PRURSG.MT_RNG Mersenne Twister Generator
    %

    properties ( SetAccess = public )
		seed
		antithetic
    end
    properties ( SetAccess = private )
		Randstream
    end
	
    methods
        function obj = MersenneTwister()
			%obj = obj@prursg.Engine.RandomNumberGenerator('mt19937ar');
            obj = obj@prursg.RandomNumberGeneration.BaseRandomNumberGenerator('MersenneTwister');
            obj.seed = 0; %default value
			obj.antithetic = false; %default value
        end
        
    end
    
    methods
		function Initiate(obj)
			obj.Randstream = RandStream.create('mt19937ar', 'seed', obj.seed);
		end
		
        function randomnumbers = Rand(obj , m, n)
            if obj.antithetic == false
                randomnumbers = rand(obj.Randstream, m, n);
            elseif obj.antithetic == true
                if mod(m/2, 1) == 0
                    randomnumbers = rand(obj.Randstream, m/2, n);
                    randomnumbers = [randomnumbers; 1-randomnumbers];
                else
                    randomnumbers = rand(obj.Randstream, floor(m/2), n);
                    randomnumbers = [randomnumbers; 1-randomnumbers];
                    randomnumbers = [randomnumbers; rand(obj.Randstream, 1, n)];
                end
            else
                error('Undefined adequate property "antithetic", its value should be true (1) or false (0)');
            end
            
        end
		
        
    end
end
