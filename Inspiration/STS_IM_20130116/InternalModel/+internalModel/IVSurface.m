%% IVSurface class definition
% value class

classdef IVSurface
    %% Properties
    %
    % *_GetAccess = public, SetAccess = private_*
    %
    % * |Data|
    % * |Name|
    % * |Moneyness|
    % * |Term|
    
    properties(GetAccess = public, SetAccess = private)
        Data
        Name
        Moneyness
        Term
    end
    
    %% Methods
    %
    % * |obj    = IVSurface(name, moneyness, tenor, data)| _constructor_    
    
    methods
        function obj = IVSurface(name, moneyness, term, data)
            %% IVSurface _constructor_
            % |obj = IVSurface(name, moneyness, term, data)|
            %
            % An equity implied volatility curve
            %
            % Inputs:
            %
            % * |name|          _char
            % * |moneyness|     _double_
            % * |term|          _double_
            % * |data|          _double_
            
            % Checks that the input data is the right format:
            if numel(moneyness) ~= size(data, 2)
                error('STS_CM:IVSurface', ...
                    'The number of moneynesses in the axis does not match the number of columns in the input data')
            elseif numel(term) ~= size(data, 1)
                error('STS_CM:IVSurface',...
                    'The number of terms in the axis does not match the number of rows in the input data')
            end
            
            obj.Name        = name;
            obj.Moneyness   = moneyness;
            obj.Term        = term;
            
            % Data is in 2D format:
            % #rows = #terms
            % #columns = #moneynesses (strikes)
            obj.Data        = data;
            
        end

        
    end
end

