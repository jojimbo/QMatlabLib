classdef FactoryItem < handle
    %FACTORYITEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name
        Class
        Properties
    end
    
    methods
        function obj = FactoryItem()
            obj.Properties = containers.Map('KeyType', 'char', 'ValueType', 'char');
        end
    end
    
end

