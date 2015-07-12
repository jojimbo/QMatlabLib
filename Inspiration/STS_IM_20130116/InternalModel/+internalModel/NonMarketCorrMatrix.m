%% NonMarketCorrMatrix 
% value class

classdef NonMarketCorrMatrix

    %% Properties    
    % * beTable             _cell_      conversion table for Base Entities
    % * correlationMatrix   _double_    correlation matrix
    % * headers             _cell_      correlation matrix headers
    % * rtTable             _cell_      conversion table for Risk Types

    properties
        beTable
        correlationMatrix
        headers
        rtTable
    end


    %% Methods    
    % * |obj = NonMarketCorrMatrix(matrixFile, beMapFile, rtMapFile)|    % _constructor_
    % * |[idx, msg] = lookupBEandRT(obj, baseEntity, riskType)|

    methods

        function obj = NonMarketCorrMatrix(matrixFile, beMapFile, rtMapFile)
            %% NonMarketCorrMatrix _constructor_
            % |obj = NonMarketCorrMatrix(matrixFile, beMapFile, rtMapFile)|
            % 
            % Input: 
            % 
            % * matrixFile  _char_
            % * beMapFile   _char_
            % * rtMapFile   _char_

            % Open matrixFile
            [fidMD1, errMsg] = fopen(matrixFile, 'r');

            if fidMD1 < 0
                error('ing:FileNotFound', errMsg);
            end

            % Second line of the file is needed to extract the number of
            % entries. The second line holds numbers corresponding to Base
            % Entities (BE)

            % Ignore first line
            fgetl(fidMD1);

            % Read second line
            lin     = fgetl(fidMD1);
            commas  = strfind(lin, ',');
            fclose(fidMD1);

            % matrixFile is build as ,,,x,y,z,aa,bb so nr of entries needs
            % to be increased by 1
            nrEntries = length(commas) + 1;

            % open matrixFile again
            [fidMD2, errMsg] = fopen(matrixFile, 'r');

            if fidMD2 < 0
                error('ing:FileNotFound', errMsg);
            end

            % Generate format
            % first four columns should be ignored, other elements are
            % doubles / floats
            matFormat = '%s %*s %s %*s';

            for iEntries = 1:nrEntries-4
                matFormat = strcat(matFormat, ' %f');
            end

            % Read matrixFile in as a cell matrix of strings (char-array)
            % row/column #5 and further contain actual matrixData
            headerAndMatrix = textscan(fidMD2, matFormat, 'delimiter', ',', ...
                                       'HeaderLines', 4, 'CollectOutput', true);

            fclose(fidMD2);
            obj.correlationMatrix   = headerAndMatrix{2};
            obj.headers             = strtrim(headerAndMatrix{1});

            % Base Entity names are not always filled for all rows, in
            % order to have nicer lookup this should be done
            currBE = '';

            for iHeader = 1:length(obj.headers(:, 1))

                if ~isempty(obj.headers{iHeader, 1}) && ~strcmp(obj.headers{iHeader, 1}, currBE)
                    % New header or same header
                    currBE = strtrim(obj.headers{iHeader, 1});

                else
                    % Header to be filled with previous (and same) base entity
                    obj.headers{iHeader, 1} = currBE;
                end
            end

            % Read base entity mapping table            
            beTableCll          = internalModel.Utilities.csvreadCell(beMapFile);
            rawBeTable          = strtrim(beTableCll);

            % Convert such that abbrevation is always in second column
            convBeTable         = internalModel.Converter.remapBEtable(rawBeTable);
            obj.beTable         = convBeTable;

            % Read risk type mapping table
            rtTableCll          = internalModel.Utilities.csvreadCell(rtMapFile);
            rawRtTable          = strtrim(rtTableCll);

            % Convert such that abbrevation is always in second column
            convRtTable         = internalModel.Converter.remapRTtable(rawRtTable);
            obj.rtTable         = convRtTable;

        end


        function [idx, msg] = lookupBEandRT(obj, NMR)
            %% lookupBEandRT
            % |[idx, msg] = lookupBEandRT(obj, baseEntity, riskType)|
            % 
            % Inputs:
            % 
            % * |NMR|       _NonMarketRisk_
            % 
            % Outputs:
            % 
            % * |idx|       _logical_
            % * |msg|       _char_
            idx        = [];
            msg        = '';
            baseEntity = NMR.BaseEntity;
            riskType   = NMR.RiskType;

            if      isempty(obj.beTable) || ...
                    isempty(obj.rtTable) || ...
                    (nargin < 2)         || ...
                    isempty(baseEntity)  || ...
                    isempty(riskType)

                return
            end

            % Find indices in conversion tables
            idxBE   = strcmp(baseEntity, obj.beTable(:, 2));
            idxRT   = strcmp(riskType, obj.rtTable(:, 2));

            % Convert baseEntity and riskType
            baseEntityConv  = obj.beTable{idxBE, 1};
            riskTypeConv    = obj.rtTable{idxRT, 1};

            % Find location in header
            idxBEinHeader   = strcmp(baseEntityConv, obj.headers(:, 1));
            idxRTinHeader   = strcmp(riskTypeConv, obj.headers(:, 2));
            idx             = idxBEinHeader & idxRTinHeader;

            % Output check, a single entry is wanted, warn user when
            % multiple or none entries are found
            sumidx = sum(idx);

            if sumidx > 1
                msg = 'Multiple entries found';

            elseif sumidx == 0
                msg = 'No entries found';
            end

        end

    end

end
