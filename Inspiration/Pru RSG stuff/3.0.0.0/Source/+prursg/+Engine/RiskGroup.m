classdef RiskGroup
    %RiskGroup Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        shredname % the name of the corresponding shred for this risk_group
        group % the group to which the risk drivers belongs in that shred
    end
    
    methods
        function obj = RiskGroup(shred_name, groupname)
            obj.shredname = shred_name;
            obj.group = groupname;
        end
    end
    
    
end
