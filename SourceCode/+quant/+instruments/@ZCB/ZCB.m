
classdef ZCB < quant.instruments.Instrument & handle
    %% ZCB - Create a ZCB instrument
    %
    % ZCB SYNTAX:
    %   OBJ = ZCB()
    %   OBJ = ZCB(MaturityDate)    
    %   OBJ = ZCB(MaturityDate, Notional, DiscountCurve)
    %   OBJ = ZCB(MaturityDate, Notional, DiscountCurve, 'Name1', Value1, ...)
    %
    % ZCB DESCRIPTION:
    %   ZCB contract with Payoff as specified below:
    %   1.*Notional
    %
    % ZCB PROPERTIES:
    % Notional;
    % MaturityDate;
    % DiscountCurve;
    %
    % ZCB METHODS:
    % ZCB - The constructor
    %
    % ZCB INPUTS:
    %   1. Notional
    %   2. MaturityDate
    %   3. DiscountCurve
    %
    % ZCB OPTIONAL INPUTS:
    %   [None]
    %
    % ZCB OUTPUTS:
    %   ZCB instrument object with the following properties:
    %       Notional;
    %       MaturityDate;
    %       DiscountCurve;
    %
    % ZCB VARIABLES:
    %   [None]
    %
    %% Object Class ZCB
    % Copyright 1994-2016 Riskcare Ltd.
    %

    
    %% Properties
    properties
        Notional;
        MaturityDate;
    end
    
    
    %%
    %% * * * * * * * * * * * Define ZCB Methods * * * * * * * * * * * 
    %%
        
    
    %% Abstract methods of Public access
    methods (Access = public)
    end
    
    %% Static methods
    methods (Static)
        %% Constructor method
        function OBJ = ZCB(Notional, MaturityDate, DiscountCurve)
           OBJ.Type = class(OBJ);
           if nargin ==0
               OBJ.Notional = 1;
               OBJ.MaturityDate = datestr(today+3650); % Approx 10 years from now
               OBJ.DiscountCurve = 'USD'; % Default value - TODO - Decide
           elseif nargin ==1
               OBJ.Notional = 1;
               OBJ.MaturityDate = MaturityDate;
               OBJ.DiscountCurve = 'USD'; % Default value - TODO - Decide
           else % nargin > 0
               OBJ.Notional = Notional;
               OBJ.MaturityDate = MaturityDate;
               OBJ.DiscountCurve = DiscountCurve;
           end
           OBJ.Payoff = @(x) x.*OBJ.Notional; % Simply multiply Notional by a number 'x'
       end
    end
    
    %% Non-Static methods
    methods
    end
    
end