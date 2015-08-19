classdef DependencyModel < handle
    %PRURSG.DEPENDENCYMODEL Base class for dependency models
    %
    
    %   Copyright 2010 The MathWorks, Inc.
    properties ( SetAccess = private )
        risks
    end
    methods
        function obj = DependencyModel()
            obj.risks = [];
        end
        
        function setRisks( obj , risks)
            obj.risks = risks;
        end
    end
    
    
    methods ( Abstract )
        buildCorrMat( obj , corrMat , riskNames )
        % DependenciesEngine.buildCorrMat - build correlation matrix
        %   obj.buildCorrMat( corrMat, riskNames)
        % Decompose input correlation matrix into Cholesky factors to
        % produce correlated random number streams.
        % Inputs:
        %   corrMat - correlation matrix
        %   riskNames - cell array of strings of risk names
        %   corresponding to the columns and rows of corrMat
        % Outputs:
        %   None.
        
        correlNumbers = correlate(obj, uncorrNumbers)
        % DependenciesEngine.correlate - produce correlations in uncorrelated random number streams
        %   correlNumbers = obj.correlate( uncorrNumbers )
        % Generates correlated random numbers from uncorrelated
        % random numbers
        % Inputs:
        %   uncorrNumbers - uncorrelated Gaussian random numbers
        % Outputs:
        %   corrNumbers - correlated Gaussian random numbers
    end
end

