classdef Riskv3_0_0_0 < prursg.Engine.Risk.Risk
    methods
        function obj = Riskv3_0_0_0(model)
            obj = obj@prursg.Engine.Risk.Risk([], model)
        end
    end
    
    properties
        suppressOutput
        correlationGroup
    end
end