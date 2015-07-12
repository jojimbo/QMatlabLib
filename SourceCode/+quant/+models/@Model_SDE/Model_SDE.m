
classdef Model_SDE < quant.models.Model
    %% Model_SDE - Create a Model using a wrapper around Matlab's SDE class
    %
    % Model_SDE SYNTAX:
    %   OBJ = Model_SDE(drift, diffusion)
    %   OBJ = Model_SDE(drift, diffusion, 'Name1', Value1, ...)
    %
    % Model_SDE DESCRIPTION:
    % Thin wrapper around Matlab's native SDE class
    %
    % Model_SDE INPUTS:
    %   1. 
    %   2.
    %
    % Model_SDE OPTIONAL INPUTS:
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
    % Model_SDE OUTPUTS:
    %
    %   Model_SDE model object with the following properties:
    %       Drift;
    %       Diffusion;
    %       Correlation;
    %
    % Model_SDE VARIABLES:
    %   [None]
    %
    %% Object class Model_SDE
    % Copyright 1994-2016 Riskcare Ltd.
    %
    
    %% Properties
    properties
        Drift           = [];
        Diffusion       = [];
        Correlation     = [];
    end
    
    
    %%
    %% * * * * * * * * * * * Define Model_SDE Methods * * * * * * * * * * * 
    %%
    
    
    methods (Access = 'public')
        %% Constructor method
        function OBJ = Model_SDE(drift, diffusion, correlation)
            if nargin       == 2
                OBJ.Dimensionality      = 1;
                OBJ.Drift               = drift;
                OBJ.Diffusion           = diffusion;
                OBJ.Correlation         = [];
            elseif nargin   == 3
                OBJ.Dimensionality      = size(correlation, 1);
                OBJ.Drift               = drift;
                OBJ.Diffusion           = diffusion;
                OBJ.Correlation         = correlation;
            end
        end
    end
    
    
    methods (Hidden)
    end
    
%% Class end
end