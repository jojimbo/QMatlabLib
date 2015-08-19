classdef MissingDataTreatmentRuleFactory
    %MISSINGDATATREATMENTRULEFACTORY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        ruleMap
    end
    
    methods
        function obj = MissingDataTreatmentRuleFactory()
            cm = prursg.Configuration.ConfigurationManager();
            obj.ruleMap = cm.MissingDataTreatmentRuleMap;
        end
    
        function rule = Create(obj, name)
            rule = [];
            if isempty(obj.ruleMap)
                ex = MException('MissingDataTreatmentRuleFactory:Create', 'Internal map is empty.');
                throw(ex);
            end
            
            if ~isKey(obj.ruleMap, name)
                ex = MException('MissingDataTreatmentRuleFactory:Create', ['The given name(' name ') is not found in the internal map.']);                
                throw(ex);
            end
            
            item = obj.ruleMap(name);
            
            expression = ['rule = ' item.Class ';'];
            eval(expression);            
        end
    end
    
end

