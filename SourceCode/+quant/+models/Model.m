
classdef (Abstract, HandleCompatible) Model
    %% Model - Abstract class for any Stochastic Model
    %
    % Model DESCRIPTION:
    %   General Stochastic Model.
    %   Abstract class to contain all common procedures, functions and
    %   properties of stochastic models
    %
    %% Abstract object class Model
    % Copyright 1994-2016 Riskcare Ltd.
    
    %% Properties
    properties
        Dimensionality
        Correlation % Correlation matrix with correlation structure of the different brownian process of the model
                    % Would be a scalar = 1 if Dimensionality ==1
                    % Would be a diagonal matrix otherwise with dimension == Dimensionality
    end
    
    %%
    %% * * * * * * * * * * * Define Model Methods * * * * * * * * * * *
    %%
    
    
    %% Abstract methods
    methods (Abstract)
        %% Simulation procedure
        % - Can be used for Risk Neutral and Real World indistinctively
        Simulate(OBJ, NPERIODS, varargin)
    end

    
    
%% Class end
end
