classdef IRSGRisk < handle
    methods(Abstract)
        val = setSeniority(obj, risks, riskIndexResolver);
    end
end