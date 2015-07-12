%% Instrument 
% _Abstract_ value class

classdef Instrument < handle

    %% Properties
    % 
    % * InterestRate
    % 
    % *_GetAccess = public, SetAccess = protected_*
    % 
    % * |Name|
    % * |ID|
    % * |MarketRisk|
    % * |Currency|
    
    properties(GetAccess = public, SetAccess = protected)
        Name
        ID
        MarketRisk
        Currency
        ValuationDate
        CreditSpread
    end

    %% Methods
    % 
    % *_Abstract_*
    % 
    % * |vals = value(this)|

    methods ( Abstract )
        vals = value(this)
    end

end
