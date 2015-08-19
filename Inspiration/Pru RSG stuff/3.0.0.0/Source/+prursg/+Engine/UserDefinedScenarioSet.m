classdef UserDefinedScenarioSet < prursg.Engine.ScenarioSet
    %SCENARIOSET 
    % Covers User defined scenario-sets. In addition to determinisitc
    % scenarios, this one has also one or many stochastic scenarios
    %
    
    properties                          
        stochasticScenarios                                     
    end
    
    methods
        % convert an ordinary ScenarioSet into a User scenario set
        % by extracting the stochastic scenarios into a separate structure
        function obj = UserDefinedScenarioSet(scenarioSet)
            obj.name = scenarioSet.name;
            obj.sess_date = scenarioSet.sess_date;
            obj.noRiskScenario = scenarioSet.noRiskScenario;
            
            for i = 1:numel(scenarioSet.scenarios)
                s = scenarioSet.scenarios(i);
                if s.number == 0 % deterministic
                    obj.addScenario(s);
                else
                    obj.stochasticScenarios = [ obj.stochasticScenarios s ];
                end                
            end
        end
                        
        function stochasticOutputs = makeStochasticOutputs(obj, risks, scenarioId)
            stochasticOutputs = cell(1, numel(risks));
            for i = 1:numel(risks)                                
                riskOutputs = []; % cannot prealocate as the number of stochastic outputs per risk is not known!
                
                hyperCube = obj.stochasticScenarios(scenarioId).getRiskScenarioValues(risks(i).name);
                hyperCube = prursg.Engine.HyperCube.serialise(hyperCube);
                riskOutputs = [riskOutputs; hyperCube]; %#ok<AGROW>
                
                stochasticOutputs{i} = riskOutputs;
            end
        end
        
        function scenarios = getStochasticScenarios(obj)
            scenarios = obj.stochasticScenarios;
        end  
    end
        
end

