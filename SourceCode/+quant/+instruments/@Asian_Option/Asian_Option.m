
classdef Asian_Option < quant.instruments.Instrument & handle
    %% Asian_Option - Asian_Option instrument class
    %
    % Asian_Option SYNTAX:
    %   OBJ = Asian_Option(OptionType, Underlying, MaturityDate, Strike)
    %   OBJ = Asian_Option(OptionType, Underlying, MaturityDate, Strike, 'Name1', Value1, ...)
    %
    % Asian_Option DESCRIPTION:
    %   Euro_Option contract with Payoffs as specified below:
    %
    % CALL:
    % $\max(Spot - Strike, 0)$
    %
    % PUT:
    % $\max(Strike - Spot, 0)$
    %
    % Asian_Option PROPERTIES:
    % OptionType;
    % Underlying;
    % MaturityDate;
    % Strike;
    % Asian;
    %
    % Asian_Option METHODS:
    % Asian_Option - The constructor
    % getUnderlying - Returns the underlying of the option
    %
    % Asian_Option INPUTS:
    %   1. OptionType
    %   2. Underlying
    %   3. MaturityDate
    %   4. Strike
    %
    % Asian_Option OPTIONAL INPUTS:
    %   [None]
    %
    % Asian_Option OUTPUTS:
    %   Asian_Option instrument object with the following properties:
    %       OptionType;
    %       Underlying;
    %       MaturityDate;
    %       Strike;
    %       Asian;
    %
    % Asian_Option VARIABLES:
    %   [None]
    %
    %% Object Class Asian_Option
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        OptionType; % Type of the option: 'PUT' or 'CALL'
        Underlying; % Underlying RiskFactor for the option
        Strike; % Strike of the option
    end
    
    
    %%
    %% * * * * * * * * * * * Define Asian_Option Methods * * * * * * * * * * *
    %%
    
    
    %% Abstract methods of Public access
    methods (Access = public)
    end
    
    %% Static methods
    methods (Static)
        %% Constructor method
        function OBJ = Asian_Option(OptionType, Underlying, MaturityDate, Strike)
            % Euro_Option - The Euro_Option constructor
            %
            %   See also instruments.Instrument.
            OBJ.Type = class(OBJ);
            OBJ.Features = [OBJ.Features; containers.Map('Asian', true)];
            if nargin ==0
                OBJ.OptionType = 'CALL';
                OBJ.Underlying = 'NOT DEFINED';
                OBJ.MaturityDate = datestr(today+3650); % Approx 10 years from now
                OBJ.Strike = 100;
            end
            if nargin > 0
                OBJ.OptionType = upper(OptionType);
                OBJ.Underlying = Underlying;
                OBJ.MaturityDate = MaturityDate;
                OBJ.Strike = Strike;
            end
            OBJ.Payoff = quant.payoffs.Asian(OBJ.OptionType, OBJ.Strike);
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
    end
    
end