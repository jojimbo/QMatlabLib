classdef ValidationEngine < prursg.Engine.Engine
    
    properties
        % ref % Risks to be validated
        ruleSet % a validation rule set object        
    end
    
    methods
        function obj = ValidationEngine()
            % ValidationEngine - constructor
            %   obj = ValidationEngine()
            obj = obj@prursg.Engine.Engine();
            % obj.ref = [];
        end
        
        function validate(obj, nBatches, modelFile, scenarioSet, stoValues, reportPath)
            ruleSetName = modelFile.validation_rules;
            % stoValues is a cell array of all simulation results
            
            if ~isdeployed
                addpath(prursg.Util.ConfigurationUtil.GetModelsPackage());
            end
            
            import Model.*;
    
            try
                eval(['obj.ruleSet = Model.' ruleSetName '();']);
            catch % default to validation rules set 1
                eval(['obj.ruleSet = Model.ValidationRulesSet1();']);
            end
                        
            obj.ruleSet.validate(nBatches, modelFile, obj.risks , scenarioSet, stoValues, reportPath);
        end
    end
end



