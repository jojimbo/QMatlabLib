%% ScenarioCollection
% value class

classdef ScenarioCollection

    %% Properties
    %
    % * |Curves|
    % * |IrCurveFile|
    % * |Headers|
    % * |Names|
    % * |PcaCurves|
    % * |ScenarioMatrix|
    properties
        Curves
        IrCurveFile
        Headers
        Names
        SetName
        PcaValues
        ScenarioMatrix
        
        forexIVSurfaces
        fxVolFactors
        
    end % # Properties

    %% Methods
    % 
    % * |obj = ScenarioCollection(calcObj)| _constructor_

    methods
        function obj = ScenarioCollection(calcObj)
            %% ScenarioCollection _constructor_
            % |obj = ScenarioCollection(calcObj)|
            % 
            % Inputs:
            % 
            % * |calcObj|       _Calculate_
            if nargin < 1
                % return empty object
                return
            end

            % Collect Scenario & PCA Data
            scenFileContents = calcObj.configuration.csvFileContents.('scenFile');
            pcaFileContents  = calcObj.configuration.csvFileContents.('pcaFile');

            % Prepare Scenario Object
            obj.Headers             = scenFileContents.Headers;
            obj.ScenarioMatrix      = scenFileContents.ScenarioMatrix;
            obj.IrCurveFile         = calcObj.parameters.irCurveFile;
            obj.PcaValues           = pcaFileContents;
            
            obj.Names               = scenFileContents.Names;
            obj.SetName             = scenFileContents.SetName;
            
            obj.Curves              = internalModel.CurveCollection(calcObj, 'irCurveFile');
            obj.forexIVSurfaces     = internalModel.SurfaceCollection(calcObj, 'fxImpVolData');
            obj.fxVolFactors        = internalModel.SurfaceCollection(calcObj, 'fxVolVolFile');
                        
        end

    end % # Methods

end
