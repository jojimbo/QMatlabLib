
classdef Hold_Underlying < quant.instruments.Instrument & handle
    %% Hold_Underlying - Hold_Underlying instrument class
    %
    % Hold_Underlying SYNTAX:
    %   OBJ = Hold_Underlying(Underlying, HoldToDate)
    %   OBJ = Hold_Underlying(Underlying, HoldToDate, 'Name1', Value1, ...)
    %
    % Hold_Underlying DESCRIPTION:
    %   Euro_Option contract with Payoffs as specified below:
    %
    % Hold_Underlying PROPERTIES:
    % Underlying;
    % MaturityDate;
    %
    % Hold_Underlying METHODS:
    % Hold_Underlying - The constructor
    % getUnderlying - Returns the underlying of the option
    %
    % Hold_Underlying INPUTS:
    %   1. OptionType
    %   2. Underlying
    %   3. MaturityDate
    %   4. Strike
    %
    % Hold_Underlying OPTIONAL INPUTS:
    %   [None]
    %
    % Hold_Underlying OUTPUTS:
    %   Hold_Underlying instrument object with the following properties:
    %       Underlying;
    %       MaturityDate;
    %
    % Hold_Underlying VARIABLES:
    %   [None]
    %
    %% Object Class Hold_Underlying
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        Underlying; % Underlying RiskFactor
    end
    
    
    %%
    %% * * * * * * * * * * * Define Hold_Underlying Methods * * * * * * * * * * * 
    %%
        
    
    %% Abstract methods of Public access
    methods (Access = public)
    end
    
    %% Static methods
    methods (Static)
        %% Constructor method
        function OBJ = Hold_Underlying(Underlying, HoldToDate)
            % Hold_Underlying - The Hold_Underlying constructor
            %
            %   See also instruments.Instrument.
            OBJ.Type = class(OBJ);
            if nargin ==0
               OBJ.Underlying = 'NOT DEFINED';
               OBJ.MaturityDate = datestr(today+3650); % Approx 10 years from now
            elseif nargin > 0
               OBJ.Underlying = Underlying;
               OBJ.MaturityDate = HoldToDate;
           end
           OBJ.Payoff = @(Spot) Spot;
       end
    end
    
    %% Non-Static methods
    methods
        %% getUnderlying method
        function U = getUnderlying(OBJ)
            % getUnderlying - Returns the Underlying
            %
            U = OBJ.Underlying;
        end
    end
    
end