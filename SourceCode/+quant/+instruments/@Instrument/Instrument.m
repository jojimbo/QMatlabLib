
classdef (HandleCompatible) Instrument < matlab.mixin.SetGet
    %% Instrument - Create a generic financial Instrument
    %
    % Instrument SYNTAX:
    %
    % Instrument DESCRIPTION:
    %   General financial Instrument.
    %   Class to contain all common procedures, functions and
    %   properties of financial instruments
    %
    %
    %% Object class Instrument
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        ID; % ID for the instrument unique identifier
        Type; % Type of instrument
        
        Payoff; % Final Payoff for the Instrument
        MaturityDate; % MaturityDate of the Instrument
        Events = {}; % Contains events or rules that apply to the instrument (e.g. 'Terminate if underlying trades above X')
        Legs = {}; % Contains all legs that form the trade
        Currency; % Currency the Instrument is denominated on (could be left empty if Legs have different currencies)
        DiscountCurve; % Curve that should be used for discounting
        
        DayCountConvention = 1; %Default DayCountConvention is 1: 30/360 0 = actual/actual (default)
                                        % 1 = 30/360 (SIA)
                                        % 2 = actual/360
                                        % 3 = actual/365
                                        % 4 = 30/360 (BMA)
                                        % 5 = 30/360 (ISDA)
                                        % 6 = 30/360 (European)
                                        % 7 = actual/365 (Japanese)
                                        % 8 = actual/actual (ICMA)
                                        % 9 = actual/360 (ICMA)
                                        % 10 = actual/365 (ICMA)
                                        % 11 = 30/360E (ICMA)
                                        % 12 = actual/actual (ISDA)
                                        % 13 = BUS/252
        BusinessDaysRule = 'follow'; % Business Days rolling rule. Possible values: follow (default), modifiedfollow, previous, modifiedprevious
        EndMonthRule
        
        Features = containers.Map(); % Map that contains flags for all possible properties of the instrument
    end
    
    
    %%
    %% * * * * * * * * * * * Define Instrument Methods * * * * * * * * * * *
    %%
    
    %% Static methods - e.g. Constructor
    methods (Static)
        %% Constructor method
        function OBJ = Instrument(Payoff, Legs, Currency)
            OBJ.Type = class(OBJ);
            if nargin == 0
                OBJ.Currency = 'GBP';
            elseif nargin == 1
                OBJ.Currency = 'GBP';
           elseif nargin == 3
                OBJ.Currency = 'GBP';
                OBJ.Legs = Legs;
                OBJ.Currency = 'GBP';
            elseif nargin > 3
                OBJ.Payoff = Payoff;
                OBJ.Legs = Legs;
                OBJ.Currency = Currency;
            end
        end
    end
    
    %% Non-Static methods
    methods
    end
    
    
    % Class end
end
