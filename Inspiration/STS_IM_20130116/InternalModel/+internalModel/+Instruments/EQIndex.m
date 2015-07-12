%% EQIndex
% subclass of internalModel.Instrument
%
% No additional properties

%%

classdef EQIndex < internalModel.Instrument
    
    %% Properties
    %
    % * |Notional|      _double_
    
    properties
        Type
        Underlyings
        
        DomesticCurrency
        DomesticCurve
        SpotPriceVAL % not clear what this represents in the input file, market price?
        
        % The following 2 properties should ideally not be part of the object
        spotPrice
        shockedEQ
        weights
    end % #Properties
    
    
    %% Methods
    %
    % * |obj = EQIndex(...)|
    % * |val = value(this)|
    
    methods
        function obj = EQIndex(name, instrID, currency, SpotPriceVAL,   ...
                type, underlyings,                          ...
                valuationDate...
                )
            %% EQIndex _constructor_
            % |obj = EQIndex(name, instrID, currency, valuationDate,...
            %           SpotPriceVAL..
            %           )|
            
            % Inputs:
            
            % * |instName|              _char_
            % * |instrID|               _char_
            % * |currency|              _char_
            % * |valuationDate|         _char_
            
            obj.Name                    = name;
            obj.ID                      = instrID;
            obj.Currency                = currency;
            obj.MarketRisk              = true;
            
            obj.SpotPriceVAL            = SpotPriceVAL;
            obj.ValuationDate           = valuationDate;
            
            obj.Type                    = type;
            obj.Underlyings             = underlyings;
            
            % Clean-up on the Domestic Curve - Support
            % EUR-SWAP as well as EUR-SWAP-SIM
            % if strcmpi(obj.DomesticCurve(end-3:end), '-SIM')
            %     obj.DomesticCurve = obj.DomesticCurve(1:end-4);
            % end
            
        end
        
        
        function val = value(obj)
            %% value
            % |val = value(obj)|
            %
            % Outputs:
            %
            % * |val|
            val = 1;
            
%             val = 0;
%             for iUnd= 1:numel(obj.Underlyings.componentWeight)
%                 val = val + obj.spotPrice.*sum(1+ obj.Underlyings.componentWeight(iUnd)...
%                     *(obj.Underlyings.shockedEQPrice{iUnd}./obj.Underlyings.baseEQPrice{iUnd} -1));
%             end
%             
%             val = 0;
%             for iUnd= 1:numel(obj.Underlyings)
%                 val = val + obj.spotPrice.*sum(1+ obj.Underlyings{iUnd}.Weight...
%                     *(obj.Underlyings{iUnd}.shockedEQPrice./obj.Underlyings{iUnd}.baseEQPrice -1));
%             end
        end
        
    end % #Methods
    
end
