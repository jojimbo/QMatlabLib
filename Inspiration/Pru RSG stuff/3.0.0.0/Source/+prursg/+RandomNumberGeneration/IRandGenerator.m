classdef IRandGenerator < handle
    %Interface for Random Number Generators
    
    
    methods (Abstract)
        % Initiates the Random Number Generator so it can return Random Numbers
		Initiate(obj)
		
		% Returns a sequence of m Random Numbers according to the Generator we are using
		% The output is going to be a matrix of m-by-n Random Numbers
        Rand(obj , m, n)
        
    end
    
end

