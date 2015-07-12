classdef BootstrapEngine < handle
    %BOOTSTRAPENGINE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        bs_method
    end
    
    methods
        function obj = BootstrapEngine()
            obj.bs_method = prursg.Bootstrap.BsNone();
        end
        function results = bootstrap(obj, data,param)
            results = obj.bs_method.bs(data,param);
        end
        function set_method(obj, method)
            obj.bs_method = method;
        end
    end
    
end
