classdef ScenarioSet < handle
    %SCENARIOSET 
    % Covers scenario-sets for base t=0,t>0, What-if and User defined
    % scenarios
    %
    
    properties
        name  % unique natural key maintained in robust excel sheets
        sess_date % the earliest date in a simulation. That's the only date we need from 
                     % relevant XML tag
        
        scenarios % ordered vector of deterministic scenarios     
        
        noRiskScenario % noRiskScenario.
        shockScenario % shockedBase.
    end
    
    methods
        
        function addScenario(obj, scenario)
            obj.scenarios = [ obj.scenarios scenario ];
        end
                
        
        % useful uin test cases, required cos matlab's isqual does not always work on
        % Axis objects. 
        function yesNo = equals(obj, sset)
            yesNo = isequal(class(obj), class(sset)) ...
                 && isequal(obj.name, sset.name) && obj.sess_date == sset.sess_date ...
                 && prursg.Engine.Scenario.areEqual(obj.scenarios, sset.scenarios);
        end
        
        function scenarios = getDeterministicScenarios(obj)
            scenarios = [];
            if ~isempty(obj.scenarios)
                scenarios = obj.scenarios(find(cell2mat(arrayfun(@(x)(x.isStochasticScenario == 0 && x.isNoRiskScenario == 0 && x.isShockedBase == 0), obj.scenarios, 'UniformOutput', 0))));
            end            
        end
        
        function scenario = getShockedBaseScenario(obj)
            scenario = [];
            if ~isempty(obj.scenarios)
                scenario = obj.scenarios(find(cell2mat(arrayfun(@(x)(x.isStochasticScenario == 0 && x.isNoRiskScenario == 0 && x.isShockedBase == 1), obj.scenarios, 'UniformOutput', 0))));
            end            
        end
        
        function scenario = getBaseScenario(obj)
            scenario = [];
            detScenarios = obj.getDeterministicScenarios();
            if ~isempty(detScenarios)
                scenario = detScenarios(end);
            end
        end
        
        function scenarios = getStochasticScenarios(obj)
            scenarios = [];
            if ~isempty(obj.scenarios)
                scenarios = obj.scenarios(find(cell2mat(arrayfun(@(x)(x.isStochasticScenario == 1 && x.isNoRiskScenario == 0), obj.scenarios, 'UniformOutput', 0))));
            end
        end        
                                
    end        
        
end

