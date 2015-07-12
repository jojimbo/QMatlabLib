
classdef Amer_Option < quant.instruments.Instrument & handle
    %% Amer_Option - Amer_Option instrument class
    %
    % Amer_Option SYNTAX:
    %   OBJ = Amer_Option(OptionType, Underlying, MaturityDate, Strike)
    %   OBJ = Amer_Option(OptionType, Underlying, MaturityDate, Strike, 'Name1', Value1, ...)
    %
    % Amer_Option DESCRIPTION:
    %   Amer_Option contract with Payoffs as specified below:
    %
    % CALL:
    % $\max(Spot - Strike, 0)$
    %
    % PUT:
    % $\max(Strike - Spot, 0)$
    %
    % Amer_Option PROPERTIES:
    % OptionType;
    % Underlying;
    % MaturityDate;
    % Strike;
    % DiscountCurve;
    % ExerciseDates;
    %
    % Amer_Option METHODS:
    % Amer_Option - The constructor
    % getUnderlying - Returns the underlying of the option
    %
    % Amer_Option INPUTS:
    %   1. OptionType
    %   2. Underlying
    %   3. MaturityDate
    %   4. Strike
    %
    % Amer_Option OPTIONAL INPUTS:
    %   [None]
    %
    % Amer_Option OUTPUTS:
    %   Amer_Option instrument object with the following properties:
    %       OptionType;
    %       Underlying;
    %       MaturityDate;
    %       Strike;
    %       DiscountCurve;
    %       ExerciseDates;
    %
    % Amer_Option VARIABLES:
    %   [None]
    %
    %% Object Class Amer_Option
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties %(Access = protected) - TODO - we should make properties either protected and create get methods to prevent the user
                % from changing properties without changing the Payoff
        OptionType; % Type of the option: 'PUT' or 'CALL'
        Underlying; % Underlying RiskFactor for the option
        Strike; % Strike of the option

        ExerciseDates; % List of dates when exercise is possible
    end
    
    
    %%
    %% * * * * * * * * * * * Define Amer_Option Methods * * * * * * * * * * * 
    %%
        
    
    %% Abstract methods of Public access
    methods (Access = public)
    end
    
    %% Static methods
    methods (Static)
        %% Constructor method
        function OBJ = Amer_Option(OptionType, Underlying, MaturityDate, Strike)
            % Amer_Option - The Amer_Option constructor
            %
            %   See also instruments.Instrument.
            OBJ.Type = class(OBJ);
            OBJ.Features = [OBJ.Features; containers.Map('American', true)];
            if nargin ==0
               OBJ.OptionType = 'CALL';
               OBJ.Underlying = 'NOT DEFINED';
               OBJ.MaturityDate = datestr(today+3650); % Approx 10 years from now
               OBJ.Strike = 100;
               OBJ.ExerciseDates = arrayfun(@datestr, (0:365:3650)+today, 'UniformOutput', false); % Default - Exercise possible once every year
            elseif nargin > 0
               OBJ.OptionType = upper(OptionType);
               OBJ.Underlying = Underlying;
               OBJ.MaturityDate = MaturityDate;
               OBJ.Strike = Strike;
               OBJ.ExerciseDates = arrayfun(@datestr, (0:30:3650)+today, 'UniformOutput', false); % Exercise possible every 30 days - TODO - Change to use proper business days convention
           end
           OBJ.Payoff = quant.payoffs.Vanilla(OBJ.OptionType, OBJ.Strike); % Uses same payoff as European Options
       end
    end
    
    %% Non-Static methods
    methods
        %% getUnderlying method
        function U = getUnderlying(OBJ)
            % getUnderlying - Returns the Underlying of the option
            %
            U = OBJ.Underlying;
        end
        % TODO - We can actually use the get syntax inherited from
        % matlab.mixin.SetGet (which quant.instruments inherits) - We may
        % be able to make properties private with this as well
        %v = get(amer_put, 'Payoff')
    end
    
end