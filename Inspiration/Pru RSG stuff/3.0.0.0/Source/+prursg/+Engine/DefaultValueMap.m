classdef DefaultValueMap < containers.Map
    %RISKNAMERESOLVER overrides Map::operator()(key) to return []
    %   instead of raising an error, when isKey(map, key) == false
    
    methods
                
        function value = subsref(obj, key)
            if isKey(obj, key.subs{1})
                value = subsref@containers.Map(obj, key);
            else
                value = [];
            end
        end
    end
    
end

