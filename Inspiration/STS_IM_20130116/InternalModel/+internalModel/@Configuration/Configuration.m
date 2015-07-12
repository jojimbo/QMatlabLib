%% Configuration
% This class represents the STS - IM calculation configuration
classdef Configuration < handle

    %% Properties
    % 
    % * |sourceFileName|    _Char_
    % * |headerFileName|    _Char_
    % * |headerSpecs|       _Cell_
    % * |identifierColId|   _Double_
    % * |csvFileNames|      _Cell_
    % * |csvFileContents|   _Struct_

    properties

        sourceFileName
        headerFileName
        headerSpecs
        identifierColId
        csvFileNames
        csvFileContents

    end % #Properties


    methods
        %% Methods
        % 
        % * |obj = Configuration(configFile)|   _constructor_

        function obj = Configuration(calcObj)
            %% Configuration _constructor_
            % |obj = Configuration(calcObj)|
            % 
            % Input:
            % 
            % * |calcObj|    _Calculation_

            % 1. Initialize
            obj.sourceFileName  = calcObj.configFile;
            obj.headerFileName  = calcObj.parameters.headerFile;
            obj.headerSpecs     = calcObj.header;
            obj.identifierColId = 2; % NOTE: HARD-CODED!!!
            obj.csvFileNames    = {};
            obj.csvFileContents = [];

            % 2. Process all CSV files in configuration file
            obj.processConfiguration(calcObj.parameters);

        end % #Constructor



        function processConfiguration(obj, parameters)
            % Process all CSV files listed in the configuration file

            % Loop over all parameter entries, process all CSV's
            fieldNames = fieldnames(parameters);

            for ii = 1:numel(fieldNames)
                % Check if entry represents an existing CSV file
                if      ischar(parameters.(fieldNames{ii})) && ...
                        eq(exist(parameters.(fieldNames{ii}), 'file'), 2)

                    % Configuration entry refers to an existing file
                    [~, ~, ext] = fileparts(parameters.(fieldNames{ii}));

                    % If it is a CSV file: process it...
                    if strcmpi(ext, '.csv')
                        obj.processCsvFile(fieldNames{ii}, parameters.(fieldNames{ii}));
                    end
                end
            end

        end % #processConfiguration

    end % %Methods Public


    methods (Static)

        function dataReturn = getContents(dataSet, dataHeader, enumerator)
            % Collect contents
            [~, identifierCOL] = find(strcmpi(dataHeader, enumerator));
            dataReturn = dataSet(:, identifierCOL);

        end % #getContents

     end % #Methods Static

end
