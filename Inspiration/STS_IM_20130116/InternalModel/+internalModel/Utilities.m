%% Utilities
% Static value class
% 
% Serves as a container for STS Math & I/O utils

classdef Utilities

    %% Properties
    properties

    end % #Properties


    %% Methods
    % 
    % * |raw = csvreadCell(filename)|
    % * |paramStruct = loadParamsFromConfigFile(configFile)|
    % * |cell2csv(fileName, cellArray, separator)|

    methods(Static)

        function raw = csvreadCell(filename)
            %% csvreadCell
            % |raw = csvreadCell(filename)|
            % 
            % Reads mixed numeric and string data from a comma-separated-value
            % file into a cell array.
            % 
            % Read data from text file into a cell array. File contains mixed text
            % and numeric data in comma-separated-value format. File can have
            % different numbers of entries on each row, those entries can be empty.
            % 
            % Inputs:
            % 
            % * |filename|  _char_
            % 
            % Outputs:
            % 
            % * |raw|       _cell_
            [fid, errMsg] = fopen(filename);

            if fid < 0
                disp(['Couldn''t open file ' filename]);
                error(errMsg);
            end

            % Count columns
            nrows = 0;
            ncols = 0;

            while ~feof(fid)
                nrows  = nrows + 1;
                nwLine = fgetl(fid);

                if ~isempty(nwLine)
                    oneLineTxt = textscan(nwLine, '%s', 'delimiter', ',');
                    ncols      = max(ncols, length(oneLineTxt{1}));
                end
            end

            % Read text data
            frewind(fid);
            formatString = repmat('%s', 1, ncols);
            raw = textscan(fid, formatString, 'delimiter', ',', 'CollectOutput', true);
            raw = raw{1};

            % Swap empty cells for empty strings - raw must contain strings in every
            % cell in order for sscanf to work on it
            emptyCells      = cellfun(@isempty, raw);
            raw(emptyCells) = {''};

            % Convert numeric data to numbers and extract numeric data

            data = cellfun(@str2doubleq, raw, 'UniformOutput', false);


            nonnumericCells       = cellfun(@isnan, data);
            raw(~nonnumericCells) = data(~nonnumericCells);

            % Convert empty cells to NaNs in raw and numeric data
            raw(emptyCells)  = {nan};

        end % #csvreadCell


        function paramStruct = loadParamsFromConfigFile(configFile)
            %% loadParamsFromConfigFile
            % |paramStruct = loadParamsFromConfigFile(configFile)|
            % Loads parameters from configuration file.
            % 
            % Inputs:
            % 
            % * configFile  _char_
            % 
            % Outputs:
            % 
            % * paramStruct _struct_
            % Initialize
            paramStruct.riskDrivers = [];

            if ~ischar(configFile)
                error('loadParamsFromConfigFile:BadArgs', ...
                        'Argument must be a string of characters');
            end

            % Open file
            fid = fopen(configFile,'r');
            if fid < 0
                error('loadParamsFromConfigFile:FailedOpen', ...
                    'Failed opening config file %s',configFile);
            end

            while ~feof(fid)

                tf = textscan(fid,'%s %s\n', 'Delimiter', '=');

                if isempty(tf{1})
                    break
                end

                f1 = tf{1};
                f1 = strtrim(f1{1});
                f2 = tf{2};
                f2 = strtrim(f2{1});

                if regexp(f1, '%.*')
                    % Either '%' or '%%' in file, considered comment
                else
                    % If we have relative paths, we add the present working
                    % directory to the path to the file
                    if (f2(1)== filesep) || (f2(1)== '\') || (f2(1)== '/')
                        f2 = [pwd() f2];
                        disp(['Info: Relative path provided for ' ...
                            f1 ', using file: ' f2]);
                    end
                    

                    switch upper(f1)

                        case 'INSTFILE'
                            paramStruct.instFile            = f2;

                        case 'SCENFILE'
                            paramStruct.scenFile            = f2;

                        case 'HEADERFILE'
                            paramStruct.headerFile          = f2;

                        case 'PORTFILE'
                            paramStruct.portFile            = f2;

                        case 'CREDITSPREADFILE'
                            paramStruct.spreadFile          = f2;

                        case 'IRCURVEFILE'
                            paramStruct.irCurveFile         = f2;

                        case 'FOREXFILE'
                            paramStruct.forexFile           = f2;

                        case 'FXIMPVOLDATA'
                            paramStruct.fxImpVolData        = f2;

                        case 'CORRMATFILE'
                            paramStruct.corrMatFile         = f2;

                        case 'BASEENTITYFILE'
                            paramStruct.baseEntityFile      = f2;

                        case 'RISKTYPEFILE'
                            paramStruct.riskTypeFile        = f2;

                        case 'PCAFILE'
                            paramStruct.pcaFile             = f2;

                        case 'EQINDFILE'
                            paramStruct.eqIndFile           = f2;

                        case 'EQUITYREFILE'
                            paramStruct.equityReFile        = f2;

                        case 'SWAPTIONIMPVOLFILE'
                            paramStruct.swaptionImpVolFile  = f2;

                        case 'CONFIDENCELVL'
                            match = regexp(f2, '([0-9\.]+)', 'tokens');
                            paramStruct.confidenceLvl = cellfun(@(x)str2doubleq(x), match);

                        case 'VALUATIONDATE'
                            paramStruct.valuationDate       = f2;
                        
                        case 'REPORTINGCURRENCY'
                            match      = regexp(f2, '([A-Z\.]+)', 'tokens');
                            currencies = cell(1, numel(match));

                            for iTok = 1:numel(match)
                                curr_iTok = match{iTok};
                                currencies{iTok} = curr_iTok{1};
                            end

                            paramStruct.reportingCurrency   = currencies;

                        case 'OUTPUTFILE'
                            paramStruct.outputFile          = f2;

                        case 'FIXEDRATEBONDFILE'
                            paramStruct.frbFile             = f2;

                        case 'FIXEDRATEBONDREFDATE'
                            paramStruct.frbRefDate          = f2;

                        case 'BFVOLVOLFILE'
                            paramStruct.bfVolVolFile        = f2;

                        case 'EQVOLVOLFILE'
                            paramStruct.eqVolVolFile        = f2;

                        case 'REVOLVOLFILE'
                            paramStruct.reVolVolFile        = f2;

                        case 'IRVOLVOLFILE'
                            paramStruct.irVolVolFile        = f2;

                        case 'FXVOLVOLFILE'
                            paramStruct.fxVolVolFile        = f2;

                        case 'VOLATILITYCAPFILE'
                            paramStruct.volatilityCapFile   = f2;

                        otherwise
                            error('loadParamsFromConfigFile:NotImpl', ...
                                'Case %s is not implemented',f1);
                    end
                end
            end

            % Close config file
            fclose(fid);

            % Check parameter struct
            varNmsNeeded = {'instFile',  'scenFile',      'portFile',          'irCurveFile',  ...
                            'forexFile', 'corrMatFile',   'baseEntityFile',    'riskTypeFile', ...
                            'pcaFile',   'confidenceLvl', 'reportingCurrency', 'outputFile'};

            for iVar = 1:length(varNmsNeeded)

                if ~isfield(paramStruct, varNmsNeeded{iVar})
                    error('loadParamsFromConfigFile:BadInput', ...
                        ['An ' varNmsNeeded{iVar} ' has to be provided']);
                end
            end

            if ~isnumeric(paramStruct.confidenceLvl) || all(isnan(paramStruct.confidenceLvl))
                error('loadParamsFromConfigFile:BadInput', ...
                    'confidenceLvl is not proper in configFile');
            end

        end % #loadParamsFromConfigFile


        function cell2csv(fileName, cellArray, separator)
            %% cell2csv
            % |cell2csv(fileName, cellArray, separator)|
            % 
            % Writes cell array content into a *.csv file.
            % 
            % Inputs
            % 
            % |fileName|    _char_
            % |cellArray|   _cell_
            % |separator|   _char_

            % Checking inputs
            if ~exist('separator', 'var')
                separator = ',';
            end

            % Write file
            data = fopen(fileName, 'w');

            for iRow = 1:size(cellArray, 1)
                for iCol = 1:size(cellArray, 2)

                    var = cellArray{iRow, iCol};

                    if size(var, 1) == 0
                        % is empty cell
                        var = '';
                    end

                    % If numeric -> String
                    if isnumeric(var)
                        var = num2str(var, '%8.20f');                        
                    end

                    % If logical -> 'true' or 'false'
                    if islogical(var)
                        if var == 1
                            var = 'TRUE';
                        else
                            var = 'FALSE';
                        end
                    end

                    % OUTPUT value
                    fprintf(data, '%s', var);

                    % OUTPUT separator
                    if iCol ~= size(cellArray, 2)
                        fprintf(data, separator);
                    end
                end

                if iRow ~= size(cellArray, 1) % prevent a empty line at EOF
                    % OUTPUT newline
                    fprintf(data, '\n');
                end
            end

            % Close file
            fclose(data);

        end % #cell2csv

    end  % #Methods

end % #Utilities
