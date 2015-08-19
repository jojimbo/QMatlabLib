classdef WhatIfScenarioSet < prursg.Engine.ScenarioSet
    %SCENARIOSET 
    % Covers What-if scenario-sets 
    % appart from optional deterministic scenario/points it has also a shock
    % definition for another basic scenarioset
    %
    
    properties
        baseScenarioShock % instance of ShockBaseScenario class
    end

    methods
        % convert an ordinary ScenarioSet into a what-if scenario set
        % scenarioSet and shock has been populated by the Xml dao
        function obj = WhatIfScenarioSet(scenarioSet, shock)
            obj.name = scenarioSet.name;
            obj.sess_date = scenarioSet.sess_date;
            obj.scenarios = scenarioSet.scenarios;
            obj.baseScenarioShock = shock;    
            obj.noRiskScenario = scenarioSet.noRiskScenario;
        end
        
        % merge both sets deterministic points and shock the baseScenarioSet last deterministic point
        function resultScenarioSet = makeResultScenarioSet(obj, baseScenarioSet)
            resultScenarioSet = prursg.Engine.ScenarioSet();
            resultScenarioSet.name = obj.name;
            resultScenarioSet.sess_date = obj.sess_date;
            %
            %
            % the difference between t=0 and t>0 what ifs is that the former
            % does not include the baseScenarioSet's last deterministic
            % scenario, as it gets overriden by the what if t=0 shocked
            % deterministic scenario
            %
            baseScenario = baseScenarioSet.getBaseScenario();
            detScenarios = baseScenarioSet.getDeterministicScenarios();            
            resultScenarioSet.scenarios = [ ...
                detScenarios ...
                obj.scenarios ...
                makeSchockBaseDeterministicScenario(obj.baseScenarioShock)
            ];
            for i = 1:numel(resultScenarioSet.scenarios)
                resultScenarioSet.scenarios(i).scen_step = i; %pru file format consistency
            end
        end
        
        
        % The ordering in risks and refChunks
        % coincides!!!
        function stochasticOutputs = makeStochasticOutputs(obj, risks, baseScenario, baseChunk, numSubRisks)
            startIndex = 0;
            endIndex = 0;
            for i = 1:numel(risks)
                Vb = serialise(baseScenario.expandedUniverse(risks(i).name));                
                V = serialise(obj.baseScenarioShock.shiftCoefficients(risks(i).name));
                M = serialise(obj.baseScenarioShock.stretchCoefficients(risks(i).name));
                
                multishock = obj.baseScenarioShock.multishock(risks(i).name);
                
                startIndex = endIndex + 1;
                endIndex = startIndex + numSubRisks(i) - 1;
                                
                s = baseChunk(:, startIndex:endIndex);                
                Vb = repmat(Vb, size(baseChunk, 1), 1);
                V = repmat(V, size(baseChunk, 1), 1);
                M = repmat(M, size(baseChunk, 1), 1);
                
                if multishock
                    s = (1 + (s ./ Vb - 1) .* M) .* V;    
                else
                    s = (s - Vb) .* M + V;
                end
                
                
                if ~isempty(obj.baseScenarioShock.manualShiftCoefficients(risks(i).name))
                    F = serialise(obj.baseScenarioShock.manualShiftCoefficients(risks(i).name));
                    F = repmat(F, size(baseChunk, 1), 1);
                    s = s + F;
                end
                
                if ~isempty(obj.baseScenarioShock.floorCoefficients(risks(i).name))
                    Vf = serialise(obj.baseScenarioShock.floorCoefficients(risks(i).name));
                    Vf = repmat(Vf, size(baseChunk, 1), 1);
                    s = max(s, Vf);
                end
                
                
                baseChunk(:, startIndex:endIndex) = s;
            end
            stochasticOutputs = baseChunk;
        end
        
    end

end

function vector = serialise(dataSeriesObject)
    vector = prursg.Engine.HyperCube.serialise(dataSeriesObject.values{1});
end

function scenario = makeSchockBaseDeterministicScenario(shock)
    scenario = prursg.Engine.Scenario();
    scenario.name = shock.name;
    scenario.number = 0;
    scenario.date = shock.date;
    scenario.scen_step = 0;
    scenario.isShockedBase = 1;
    
    scenario.expandedUniverse = shock.shiftCoefficients;
end


