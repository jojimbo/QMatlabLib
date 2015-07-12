%% EquityUnderlying
% 

classdef EquityUnderlying
    
    %% Properties
    %
    % * |Notional|      _double_
    
    properties
        Ref
        Weight
        
        baseEQPrice
        shockedEQPrice
    end % #Properties
    
    
    %% Methods
    %
    % * |obj = EquityUnderlying(...)|
    % * |val = value(this)|
    
    methods
        function obj = EquityUnderlying(ref, weight...
                )
            %% EquityUnderlying _constructor_
            % |obj = EquityUnderlying(ref, weight...
            %           )|
            
            % Inputs:
            
            % * |Ref|                   _char_
            % * |Weight|                _double_
                
            obj.Ref                     = ref;
            obj.Weight                  = weight;
            
        end
        
        
        function val = value(obj)
            %% value
            % |val = value(obj)|
            %
            % Outputs:
            %
            % * |val|
            val = obj.shockedEQPrice;
            
        end
        
    end
    
end % #Methods
