classdef ValidationRules < handle
    %PRURSG.VALIDATIONRULES class
    %  Validation Rules is the base class for validation rules
    
    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.12 $  $Date: 2011/09/19 10:55:52BST $
    properties
    end
    
    methods
        function obj = ValidationRules()
        end
    end
    
    methods ( Abstract )
        validate( obj, nBatches, modelFile, risks , scenarioSet, simResults, reportPath)         
        % Inputs
        % modelFile : Model File
        % nBatches: no Of batches.
        % risks : array of Risk
        % scenarioSet : scenario set.
        % simResults : stochastic simulation results.        
        % reportPath : Path of validation report file.
    end
end

