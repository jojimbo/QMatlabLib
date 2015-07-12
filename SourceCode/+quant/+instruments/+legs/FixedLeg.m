
classdef (HandleCompatible) FixedLeg < quant.instruments.Leg
    % FixedLeg - Creates a generic FixedLeg that can be part of a financial Instrument
    %
    % FixedLeg SYNTAX:
    %
    % FixedLeg DESCRIPTION:
    %   FixedLeg that can be part of a financial Instrument.
    %   Pays a fixed interest on every date of the Schedule
    %
    %% Object class Leg
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        FixedRate % FixedRate that the FixedLeg pays out
    end
    
    
    %%
    %% * * * * * * * * * * * Define FixedLeg Methods * * * * * * * * * * *
    %%
    
    methods (Access = 'public')
        %% CalculateCashflows method
        function CFs = CalculateCashflows(OBJ)
            OBJ.Cashflows = cellfun(@(x)OBJ.FixedRate.*OBJ.InitialNotional, OBJ.Schedule);
            CFs = OBJ.Cashflows;
        end
    end
    
    %% Static methods - e.g. Constructor
    methods (Static)
        function OBJ = FixedLeg(FixedRate, varargin)
            OBJ = OBJ@quant.instruments.Leg(varargin{:});
            OBJ.FixedRate = FixedRate;
        end
    end
    
    %% Non-Static methods
    methods
    end
    
    
    % Class end
end


