classdef Engine < handle
    %PRURSG.ENGINE Base class providing general purpose risk-handling capabilities.
    %  Calculation engines are used to evaluate risks for calibration,
    %  simulation, correlation and validation.
    
    %   Copyright 2010 The MathWorks, Inc. 
    %   $Revision: 1.12 $  $Date: 2012/10/24 01:13:11BST $

    properties ( SetAccess = protected )
        risks % Array of Risk objects
    end
    
    methods
        function obj = Engine()
            % Engine - Constructor
            %   obj = Engine()
            
            % Previously this method constructed an empty Engine.Risk array
            % i.e prursg.Engine.Risk.empty(1, 0), however, this was a
            % problem when we created derived Risk objects - creating an
            % empty array of double seems to work.
            obj.risks = 1:0;
        end
        
        function addRisk( obj , risks )
            % Engine.addRisk - add risks to the engine
            %   obj.addRisk( risks )
            % Add the risk objects to the engine
            % Inputs:
            %    risks - row vector of Risk objects
            % Outputs:
            %    None
            
            % FIXME: need to prevent a risk from being added twice?
            obj.risks = [obj.risks, risks];
        end

    end
    
end

