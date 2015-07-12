
classdef Gbm_RC_01 < quant.models.Model
    %% Gbm_RC_01 - Create a Heston stochastic volatility model
    %
    % Gbm_RC_01 SYNTAX:
    %   OBJ = Gbm_RC_01(drift, sigma)
    %   OBJ = Gbm_RC_01(drift, sigma, 'Name1', Value1, ...)
    %
    % Gbm_RC_01 DESCRIPTION:
    %   Gbm_RC_01 model specified as below:
    %   dSt = St*(drift-D)*dt + sqrt(sigma)*dX1
    %
    % Gbm_RC_01 INPUTS:
    %   1. drift
    %   2. sigma
    %   3. S0
    %
    % Gbm_RC_01 OPTIONAL INPUTS:
    %   1. nTrials
    %   2. DeltaTime
    %   3. Processes
    %   4. Z
    %   5. nSteps
    %   6. Antithetic
    %   7. StartState
    %   8. StorePaths
    %   9. Method
    %   10.
    %
    % Gbm_RC_01 OUTPUTS:
    %   Gbm_RC_01 model object with the following properties:
    %       ; 
    %
    % Gbm_RC_01 VARIABLES:
    %   [None]
    %
    %% Object class Gbm_RC_01
    % Copyright 1994-2016 Riskcare Ltd.
    %
        

    %% Properties
    % To store the original inputs Return, Speed, Level, and Volatility:
    properties
        drift       = []; %drift, can be risk neutral or real - (Return)
        sigma       = 0; %volatility
    end
    
    
    %%
    %% * * * * * * * * * * * Define Gbm_RC_01 Methods * * * * * * * * * * * 
    %%
    
    
    methods (Access = 'public')
        %% Constructor method
        function OBJ = Gbm_RC_01(drift, sigma)
            OBJ.Dimensionality      = 1;
            OBJ.Correlation         = 1;

            OBJ.drift               = drift; %drift - (Return)
            OBJ.sigma               = sigma; %volatility
        end
    end
    
    methods (Hidden)
    end
    
%% Class end
end