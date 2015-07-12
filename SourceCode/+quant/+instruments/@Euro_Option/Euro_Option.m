
classdef Euro_Option < quant.instruments.Instrument & handle
    %% Euro_Option - Euro_Option instrument class
    %
    % Euro_Option SYNTAX:
    %   OBJ = Euro_Option(OptionType, Underlying, MaturityDate, Strike)
    %   OBJ = Euro_Option(OptionType, Underlying, MaturityDate, Strike, 'Name1', Value1, ...)
    %
    % Euro_Option DESCRIPTION:
    %   Euro_Option contract with Payoffs as specified below:
    %
    % CALL:
    % $\max(Spot - Strike, 0)$
    %
    % PUT:
    % $\max(Strike - Spot, 0)$
    %
    % Euro_Option PROPERTIES:
    % OptionType;
    % Underlying;
    % MaturityDate;
    % Strike;
    %
    % Euro_Option METHODS:
    % Euro_Option - The constructor
    % getUnderlying - Returns the underlying of the option
    %
    % Euro_Option INPUTS:
    %   1. OptionType
    %   2. Underlying
    %   3. MaturityDate
    %   4. Strike
    %
    % Euro_Option OPTIONAL INPUTS:
    %   [None]
    %
    % Euro_Option OUTPUTS:
    %   Euro_Option instrument object with the following properties:
    %       OptionType;
    %       Underlying;
    %       MaturityDate;
    %       Strike;
    %
    % Euro_Option VARIABLES:
    %   [None]
    %
    %% Object Class Euro_Option
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        OptionType; % Type of the option: 'PUT' or 'CALL'
        Underlying; % Underlying RiskFactor for the option
        Strike; % Strike of the option
    end
    
    
    %%
    %% * * * * * * * * * * * Define Euro_Option Methods * * * * * * * * * * * 
    %%
        
    
    %% Abstract methods of Public access
    methods (Access = public)
    end
    
    %% Static methods
    methods (Static)
        %% Constructor method
        function OBJ = Euro_Option(OptionType, Underlying, MaturityDate, Strike)
            % Euro_Option - The Euro_Option constructor
            %
            %   See also instruments.Instrument.
            OBJ.Type = class(OBJ);
            if nargin ==0
               OBJ.OptionType = 'CALL';
               OBJ.Underlying = 'NOT DEFINED';
               OBJ.MaturityDate = datestr(today+3650); % Approx 10 years from now
               OBJ.Strike = 100;
            elseif nargin > 0
               OBJ.OptionType = upper(OptionType);
               OBJ.Underlying = Underlying;
               OBJ.MaturityDate = MaturityDate;
               OBJ.Strike = Strike;
           end
           OBJ.Payoff = OBJ.Payoff_Euro_Option();
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