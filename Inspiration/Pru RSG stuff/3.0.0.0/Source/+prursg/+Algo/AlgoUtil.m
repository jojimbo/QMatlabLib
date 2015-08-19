classdef AlgoUtil
    
    properties
    end
    
    methods(Static)
        
        % get scenario set name and scenario prefix info based on the given
        % scenario type.
        function [setName scenarioPrefix] = GetScenarioSetNameInfo(scenarioType)
            
            % Following the change to the Critical Scenario Engine, the
            % scenario type key could be a string with format 9:x, where 9 is the
            % Critical Scenario and x is the scenario type that the CS was run
            % against. If that's the case, grab the 9 and set the scenarioType.
            if (isa(scenarioType, 'char'))
                scenarioType = str2num(scenarioType(1:strfind(scenarioType, ':')-1));
            end
                            
            prefix = '_';            
            switch scenarioType                
                case int32(prursg.Engine.ScenarioType.BigBang)
                    setName = 'BB';                       
                case int32(prursg.Engine.ScenarioType.StandardFormula)
                    setName = 'SS_Standard_Formula_Full';                    
                case int32(prursg.Engine.ScenarioType.CriticalScenario)  
                    setName = 'CS';
                otherwise
                    setName = 'ST';
                    prefix = '';
            end
                        
            scenarioPrefix = [setName prefix];
            
        end
        
        % make scenario name based on the given parameters.
        function name = ConvertScenarioName(scenarioType, stoScenarios, scenarioIndex, prefix)
            
            % Following the change to the Critical Scenario Engine, the
            % scenario type key could be a string with format 9:x, where 9 is the
            % Critical Scenario and x is the scenario type that the CS was run
            % against. If that's the case, grab the 9 and set the scenarioType.
            if (isa(scenarioType, 'char'))
                scenarioType = str2num(scenarioType(1:strfind(scenarioType, ':')-1));
            end
            
            switch scenarioType
                case int32(prursg.Engine.ScenarioType.BigBang)
                    name = [prefix strrep(stoScenarios(scenarioIndex).name, '++BB', '') ];
                case int32(prursg.Engine.ScenarioType.StandardFormula)
                    name = strrep(stoScenarios(scenarioIndex).name, '__', '');
                    name = strrep(name, 'null', '');
                    name = [prefix name];   
                case int32(prursg.Engine.ScenarioType.CriticalScenario)
                    name = [prefix stoScenarios(scenarioIndex).name ];
                otherwise
                    name = [prefix num2str(scenarioIndex)];
            end
        end
    end
    
end

