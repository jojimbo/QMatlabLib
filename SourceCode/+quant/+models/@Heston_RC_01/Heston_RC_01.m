
classdef Heston_RC_01 < quant.models.Model
    %% Heston_RC_01 - Create a Heston stochastic volatility model
    %
    % Heston_RC_01 SYNTAX:
    %   OBJ = Heston_RC_01(rho, theta, kappa, eta, drift, v0, S0)
    %   OBJ = Heston_RC_01(rho, theta, kappa, eta, drift, v0, S0, 'Name1', Value1, ...)
    %
    % Heston_RC_01 DESCRIPTION:
    %   Heston volatility model specified as below:
    %   dSt = St*(r-q)*dt + sqrt(vt)*dX1
    %   dvt = k*(eta - vt)*dt + theta*sqrt(vt)*dX2
    %
    % Heston_RC_01 INPUTS:
    %   1. 
    %   2.
    %
    % Heston_RC_01 OPTIONAL INPUTS:
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
    % Heston_RC_01 OUTPUTS:
    %
    %   Heston_RC_01 model object with the following properties:
    %       rho; %correlacion between the BM of the Stock and the Vol - (Correlation)
    %       theta; %Vol of Variance (lambda in Heston Little Trap) - (Volatility)
    %       kappa; %speed of reversion - (Speed)
    %       eta; %long run variance - (Level)
    %       drift; %drift, can be risk neutral or real - (Return)
    %
    % Heston_RC_01 VARIABLES:
    %   [None]
    %
    %% Object class Heston_RC_01
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    % To store the original inputs Return, Speed, Level, and Volatility:
    properties
        rho         = []; %correlacion between the BM of the Stock and the Vol - (Correlation)
        theta       = []; %Vol of Variance (lambda in Heston Little Trap) - (Volatility)
        kappa       = []; %speed of reversion - (Speed)
        eta         = []; %long run variance - (Level)
        drift       = []; %drift, can be risk neutral or real - (Return)
        q           = 0; %continuous dividend yield
    end
    
    
    %%
    %% * * * * * * * * * * * Define Heston_RC_01 Methods * * * * * * * * * * * 
    %%
    
    
    methods (Access = 'public')
        %% Constructor method
        function OBJ = Heston_RC_01(rho, theta, kappa, eta, drift)
            OBJ.Dimensionality      = 2;
            OBJ.Correlation         = [1 rho; rho 1];
            
            OBJ.rho                 = rho; %correlacion between the BM of the Stock and the Vol - (Correlation)
            OBJ.theta               = theta; %Vol of Variance (lambda in Heston Little Trap) - (Volatility)
            OBJ.kappa               = kappa; %speed of reversion - (Speed)
            OBJ.eta                 = eta; %long term Vol - (Level)
            OBJ.drift               = drift; %drift - (Return)
            OBJ.q                   = 0; %continuous dividend yield
        end
    end
    
    methods (Hidden)
    end
    
%% Class end
end