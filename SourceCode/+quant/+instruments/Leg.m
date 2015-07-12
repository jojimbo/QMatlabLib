
classdef (HandleCompatible) Leg < matlab.mixin.SetGet
    % Leg - Create a generic Leg that can be part of a financial Instrument
    %
    % Leg SYNTAX:
    %
    % Leg DESCRIPTION:
    %   General Leg that can be part of a financial Instrument.
    %   Class to contain all common procedures, functions and
    %   properties of Legs
    %
    %% Object class Leg
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        ID; % ID for the Leg unique identifier
        Type; % Class type of the Leg
        
        LegDirection; % Type of Leg (e.g. 'Pay' or 'Receive')
        InitialNotional; % InitialNotional amount of the Leg
        IssueDate; % Issue date of the Leg
        Payoff; % Final Payoff for the Leg (if exists)
        Schedule; % Contains schedule for cashflows of the Leg
        Cashflows; % Reserved to store calculated cashflows (when those have been calculated
        Currency; % Currency the Leg is denominated on - DEFAULT is 'GBP'
        DiscountCurve; % Curve that should be used for discounting
        
        DayCountConvention = 1; %Default DayCountConvention is 1: 30/360
        BusinessDaysRule = 'follow'; % Business Days rolling rule. Possible values: follow (default), modifiedfollow, previous, modifiedprevious
        
    end
    
    
    %%
    %% * * * * * * * * * * * Define Leg Methods * * * * * * * * * * *
    %%
    
    methods (Access = 'public')
        %% CalculateCashflows method
        CFs = CalculateCashflows(OBJ)
        
        %% haveCashflowsBeenCalculated method
        function bool = haveCashflowsBeenCalculated(OBJ)
            if isempty(OBJ.Cashflows)
                bool = false;
            else
                bool = true;
            end
        end
        
        %% CalculatedDiscountedCashflows method
        function DCFs = CalculateDiscountedCashflows(OBJ, AsOfDate)
            % Returns discounted CF to AsOfDate
            
            % Capture error if trying to price on a date before the settle of the DiscountCurve
            if datenum(AsOfDate) < OBJ.DiscountCurve.Settle
                error('AsOfDate cannot be before the DiscountCurve Settle date')
            end
            
            if ~(OBJ.haveCashflowsBeenCalculated)
                OBJ.CalculateCashflows;
            end
            datesinschedule = cellfun(@datenum, OBJ.Schedule);
            DFs = OBJ.DiscountCurve.getDiscountFactors(datesinschedule);
            DFtoAsOfDate = OBJ.DiscountCurve.getDiscountFactors(AsOfDate); % DF from AsOfDate to DiscountCurve.Settle
            DCFs = (OBJ.Cashflows).*DFs*(1/DFtoAsOfDate);
        end
        
        %% PresentValue method
        function PV = PresentValue(OBJ, AsOfDate)
            PV = sum(OBJ.CalculateDiscountedCashflows(AsOfDate));
        end
        
    end
    
    %% Static methods - e.g. Constructor
    methods (Static)
        function OBJ = Leg(varargin)
            OBJ.Type = class(OBJ);
            if nargin ==0           % New = quant.instruments.Leg('PAY')
                OBJ.LegDirection = 'RECEIVE';
                OBJ.InitialNotional = 1;
                OBJ.Currency = 'GBP';
                OBJ.DiscountCurve = 'GBP';
            elseif nargin == 1      % New = quant.instruments.Leg('PAY', 100)
                direction   = varargin{1};
                OBJ.LegDirection = direction;
                OBJ.InitialNotional = 1;
                OBJ.Currency = 'GBP';
                OBJ.DiscountCurve = 'GBP';
            elseif nargin == 2      % New = quant.instruments.Leg('RECEIVE', 100, scheduleobject)
                direction   = varargin{1};
                notional    = varargin{2};
                OBJ.LegDirection = upper(direction);
                OBJ.InitialNotional = notional;
                OBJ.Currency = 'GBP';
                OBJ.DiscountCurve = 'GBP';
            elseif nargin == 3      % New = quant.instruments.Leg('RECEIVE', 100, scheduleobject, 'USD')
                direction   = varargin{1};
                notional    = varargin{2};
                schedule    = varargin{3};
                OBJ.LegDirection = upper(direction);
                OBJ.InitialNotional = notional;
                OBJ.Schedule = schedule;
                OBJ.Currency = 'GBP';
                OBJ.DiscountCurve = 'GBP';
            elseif nargin == 4      % New = quant.instruments.Leg('RECEIVE', 100, scheduleobject, 'USD')
                direction   = varargin{1};
                notional    = varargin{2};
                schedule    = varargin{3};
                currency    = varargin{4};
                OBJ.LegDirection = upper(direction);
                OBJ.InitialNotional = notional;
                OBJ.Schedule = schedule;
                OBJ.Currency = currency;
                OBJ.DiscountCurve = 'GBP';
            end
            % Remove all of this, since OBJ.DiscountCurve will be just a
            % reference to an existing curve somewhere else
            r = 0.04;
            cf = engine.factories.CurveFactory;
            OBJ.DiscountCurve = cf.get('Flat_IRCurve', today, OBJ.Schedule, r,'Compounding', -1, 'Basis', 0);
        end
    end
    
    %% Non-Static methods
    methods
    end
    
    
    % Class end
end


