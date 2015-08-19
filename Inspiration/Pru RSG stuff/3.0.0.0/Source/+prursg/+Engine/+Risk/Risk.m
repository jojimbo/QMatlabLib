classdef Risk < prursg.Engine.Risk.IRSGRisk & handle
    %PRURSG.RISK - Class representing a risk driver
    %   Risk class
    
    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.1 $  $Date: 2012/10/24 01:57:25BST $

    
    properties
        model % an instance of the Model class
%         randstream
        seniority % level of seniority in model dependency tree
    end
    
    properties % as per common public xml tags as of 2011/02/23
        name % Name of risk
        risk_family %fx, nyc etc.
        pru_type    % string
        algo_type   % string 
        pru_group
        %risk_group  % for shredding in Algo
        risk_groups  % for shredding in Algo
        currency  % make sure to capitalise this        
        %random_seed % different seed per risk driver for results producability
        randomnumbergenerator % random number generator instance with all the required properties to generate random numbers
    end
    
    
    methods
        function obj = Risk(name , model)
            % Risk - Constructor
            %   obj = Risk( name, model, children)
            % Inputs:
            %   name - name of risk
            %   model - Model object for simulating risk
            %   children - cells containing number of risks this risk
            %   depends on
            obj.name = name;
            obj.model = model;
%             obj.randstream = RandStream('mt19937ar');
%             obj.seed = -1;
            obj.seniority = [];
            %obj.random_seed = [];
            obj.randomnumbergenerator = [];
        end
        
        function val = setSeniority(obj, risks, riskIndexResolver)
            dependsOn = obj.model.getPrecedentNames();
            if isempty(dependsOn)|dependsOn{1} == '0'
                level = 0;
            else
                for i = 1:length(dependsOn)
                   childRiskObj = riskIndexResolver.getRisk(dependsOn{i});
                   childLevels(i) = setSeniority(childRiskObj,risks, riskIndexResolver); %#ok<AGROW>
                end
                level = 1 + max(childLevels);
            end
            obj.seniority = level;
            val = level;
        end
                
        function setSeed(obj, s)
            obj.random_seed = s;
        end
        
        %capitalisation required by Algo
        function set.currency(obj, curr)
            obj.currency = upper(curr);
        end
        
        function setRandomNumberGenerator(obj, rng)
            obj.randomnumbergenerator = rng;
        end
        
    end
    
end

