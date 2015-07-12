function processCsvFile(obj, csvReference, csvFile)
% Process CSV file
idCol    = obj.identifierColId;

if exist(csvFile, 'file')~=2
    error('STS_CM:processCsvFile', ['File ' csvFile ' not found']);
end

% Switch case, processing is case-specific
switch csvReference

    case 'irCurveFile'
        %% Interest Rate Curve
        % User Story: P19-1
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'ZeroSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'ZeroSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'ZeroSPEC : Generic Zero Surface'));

        IR_Header       = obj.headerSpecs(headerRow, :);
        IR_Items        = data(itemRows, :);
        IR_Data         = data(dataRows, :);

        % +. Collect Column Identifiers & Relevant Data
        irCurveFile.identifiers = obj.getContents(IR_Items, IR_Header,       'IDENTIFIER');
        irCurveFile.tenorDATA   = obj.getContents(IR_Data,  obj.headerSpecs, 'GenZeroSurface0AXS');
        irCurveFile.valueDATA   = obj.getContents(IR_Data,  obj.headerSpecs, 'GenZeroSurfaceNODE');

        % +. Determine Item Separators and Item Line Count
        itemSeparators          = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt         = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines      = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines        = itemDataStartLines + itemDataLineCnt - 1;

        irCurveFile.itemLines   = [itemDataStartLines, itemDataEndLines];
        irCurveFile.itemLineCnt = itemDataLineCnt;

        % +. Propagate 'irCurveFile' to object member
        obj.csvFileNames{end+1}             = csvFile;
        obj.csvFileContents.('irCurveFile') = irCurveFile;

        % +. Create warning if data is negative
        if any(cell2mat(irCurveFile.valueDATA) < 0)
            warning('STS_CM:InputDataError', 'negative data found in IR Curve File!');
        end


    case 'spreadFile'
        %% Credit Spread File
        % User Story: P19-2
        % -----------------------------------------------------------------
        % NOTE: INCOMPLETE IMPLEMENTATION - SPECS NOT YET FINALIZED!!
        %       FORMAT DEVIATES FROM DEVELOPMENT CREDIT SPREAD FILE!!
        % -----------------------------------------------------------------
        % 
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'ZeroSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'ZeroSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'ZeroSPEC : Generic Zero Surface'));

        CS_Header       = obj.headerSpecs(headerRow, :);
        CS_Items        = data(itemRows, :);
        CS_Data         = data(dataRows, :);

        % +. Collect Column Identifiers & Relevant Data
        spreadFile.identifiers        = obj.getContents(CS_Items, CS_Header,       'IDENTIFIER');
        spreadFile.GenZeroSurface0AXS = obj.getContents(CS_Data,  obj.headerSpecs, 'GenZeroSurface0AXS');
        spreadFile.GenZeroSurfaceNODE = obj.getContents(CS_Data,  obj.headerSpecs, 'GenZeroSurfaceNODE');

        % +. Propagate 'irCurveFile' to object member
        obj.csvFileNames{end+1}            = csvFile;
        obj.csvFileContents.('spreadFile') = spreadFile;


    case 'equityReFile'
        %% Real Estate Equity Data
        % User Story: P19-3
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Index CurveSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Index CurveSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Index CurveSPEC : Generic Index Surface'));

        EQRE_Header     = obj.headerSpecs(headerRow, :);
        EQRE_Items      = data(itemRows, :);
        EQRE_Data       = data(dataRows, :);
        
        % +. Determine Item Separators and Item Line Count
        itemSeparators          = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt         = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines      = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines        = itemDataStartLines + itemDataLineCnt - 1;

        equityReFile.itemLines  = [itemDataStartLines, itemDataEndLines];
        equityReFile.itemLineCnt= itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        equityReFile.names        = obj.getContents(EQRE_Items, EQRE_Header, 'NAME');
        equityReFile.identifiers  = obj.getContents(EQRE_Items, EQRE_Header, 'IDENTIFIER');
        equityReFile.curveUnits   = obj.getContents(EQRE_Items, EQRE_Header, 'CurveUnitUNIT');
        equityReFile.dates        = obj.getContents(EQRE_Items, EQRE_Header, 'DatumDATE');
        equityReFile.RelCurveFlag = obj.getContents(EQRE_Items, EQRE_Header, 'RelativeCurveFlag');

        equityReFile.GeneIndxSuf0AXS = obj.getContents(EQRE_Data,  obj.headerSpecs, 'GeneIndxSuf0AXS');
        equityReFile.GeneIndxSuf1AXS = obj.getContents(EQRE_Data,  obj.headerSpecs, 'GeneIndxSuf1AXS');
        equityReFile.GeneIndxSufNODE = obj.getContents(EQRE_Data,  obj.headerSpecs, 'GeneIndxSufNODE');
        
        equityReFile.csvFileName      = csvFile;
        
        % +. Propagate 'equityReFile' to object member
        obj.csvFileNames{end+1}              = csvFile;
        obj.csvFileContents.('equityReFile') = equityReFile;

        % +. Create warning if data is negative
        if any(cell2mat(equityReFile.GeneIndxSufNODE) < 0)
            warning('STS_CM:InputDataError', 'negative data found in Equity RE File!');
        end


    case 'forexFile'
        %% Foreign Exchange Data
        % User Story: P19-4
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Foreign ExchangeSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Foreign ExchangeSPEC'));

        FX_Header       = obj.headerSpecs(headerRow, :);
        FX_Data         = data(dataRows, :);

        % +. Collect Column Identifiers & Relevant Data
        forexFile.identifiers      = obj.getContents(FX_Data, FX_Header, 'IDENTIFIER');
        forexFile.startCurrencies  = obj.getContents(FX_Data, FX_Header, 'CurrencyUNIT');
        forexFile.targetCurrencies = obj.getContents(FX_Data, FX_Header, 'NAME');
        forexFile.rates            = obj.getContents(FX_Data, FX_Header, 'SpotPriceVAL');
        forexFile.csvFileName      = csvFile;

        % +. Propagate 'forexFile' to object member
        obj.csvFileNames{end+1}           = csvFile;
        obj.csvFileContents.('forexFile') = forexFile;

        % +. Create warning if data is negative
        if any(cell2mat(forexFile.rates) < 0)
            warning('STS_CM:InputDataError', 'negative data found in FOREX File!');
        end


    case 'swaptionImpVolFile'
        %% Swaption Interest Rate Implied Volatility Data
        % User Story: P19-5
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Volatility - Term/TermSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Term/TermSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Term/TermSPEC : Generic Volatility Term Term Surface'));

        SWAPVOL_Header  = obj.headerSpecs(headerRow, :);
        SWAPVOL_Items   = data(itemRows, :);
        SWAPVOL_Data    = data(dataRows, :);

        % +. Determine Item Separators and Item Line Count
        itemSeparators                  = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt                 = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines              = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines                = itemDataStartLines + itemDataLineCnt - 1;

        swaptionImpVolFile.itemLines    = [itemDataStartLines, itemDataEndLines];
        swaptionImpVolFile.itemLineCnt  = itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        swaptionImpVolFile.names        = obj.getContents(SWAPVOL_Items, SWAPVOL_Header, 'NAME');
        swaptionImpVolFile.identifiers  = obj.getContents(SWAPVOL_Items, SWAPVOL_Header, 'IDENTIFIER');
        swaptionImpVolFile.dates        = obj.getContents(SWAPVOL_Items, SWAPVOL_Header, 'DatumDATE');

        swaptionImpVolFile.GenVolTrmTrmSf0AXS = obj.getContents(SWAPVOL_Data,  obj.headerSpecs, 'GenVolTrmTrmSf0AXS');
        swaptionImpVolFile.GenVolTrmTrmSf1AXS = obj.getContents(SWAPVOL_Data,  obj.headerSpecs, 'GenVolTrmTrmSf1AXS');
        swaptionImpVolFile.GenVolTrmTrmSfNODE = obj.getContents(SWAPVOL_Data,  obj.headerSpecs, 'GenVolTrmTrmSfNODE');

        % +. Propagate 'swaptionImpVolFile' to object member
        obj.csvFileNames{end+1}                    = csvFile;
        obj.csvFileContents.('swaptionImpVolFile') = swaptionImpVolFile;

        % +. Create warning if data is negative
        if      any(cell2mat(swaptionImpVolFile.GenVolTrmTrmSfNODE) < 0) || ...
                any(cell2mat(swaptionImpVolFile.GenVolTrmTrmSf1AXS) < 0) || ...
                any(cell2mat(swaptionImpVolFile.GenVolTrmTrmSf0AXS) < 0)

            warning('STS_CM:InputDataError', 'negative data found in swaption Imp Vol File!');
        end


    case 'eqIndFile'
        %% Equity Implied Volatility Data
        % User Story: P19-6
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Volatility - Moneyness/TermSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC : Generic Volatility Moneyness Term Surface'));

        EQIMP_Header    = obj.headerSpecs(headerRow, :);
        EQIMP_Items     = data(itemRows, :);
        EQIMP_Data      = data(dataRows, :);

        % +. Determine Item Separators and Item Line Count
        itemSeparators             = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt            = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines         = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines           = itemDataStartLines + itemDataLineCnt - 1;

        equityImpFile.itemLines    = [itemDataStartLines, itemDataEndLines];
        equityImpFile.itemLineCnt  = itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        equityImpFile.names        = obj.getContents(EQIMP_Items, EQIMP_Header, 'NAME');
        equityImpFile.identifiers  = obj.getContents(EQIMP_Items, EQIMP_Header, 'IDENTIFIER');
        equityImpFile.dates        = obj.getContents(EQIMP_Items, EQIMP_Header, 'DatumDATE');
        equityImpFile.RelCurveFlag = obj.getContents(EQIMP_Items, EQIMP_Header, 'RelativeCurveFlag');

        equityImpFile.GnVolMnyTrmSf0AXS = obj.getContents(EQIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSf0AXS');
        equityImpFile.GnVolMnyTrmSf1AXS = obj.getContents(EQIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSf1AXS');
        equityImpFile.GnVolMnyTrmSfNODE = obj.getContents(EQIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSfNODE');

        % +. Propagate 'eqIndFile' to object member
        obj.csvFileNames{end+1}           = csvFile;
        obj.csvFileContents.('eqIndFile') = equityImpFile;

        % +. Create warning if data is negative
        if      any(cell2mat(equityImpFile.GnVolMnyTrmSfNODE) < 0) || ...
                any(cell2mat(equityImpFile.GnVolMnyTrmSf1AXS) < 0) || ...
                any(cell2mat(equityImpFile.GnVolMnyTrmSf0AXS) < 0)

            warning('STS_CM:InputDataError', 'negative data found in equity Imp File!');
        end


    case 'fxImpVolData'
        %% FX Implied Volatility Data
        % User Story: P19-7
        % +. Collect Files Contents and Enumerators:
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Volatility - Moneyness/TermSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC : Generic Volatility Moneyness Term Surface'));

        FXIMP_Header    = obj.headerSpecs(headerRow, :);
        FXIMP_Items     = data(itemRows, :);
        FXIMP_Data      = data(dataRows, :);

        % +. Determine Item Separators and Item Line Count
        itemSeparators            = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt           = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines        = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines          = itemDataStartLines + itemDataLineCnt - 1;

        forexImpFile.itemLines    = [itemDataStartLines, itemDataEndLines];
        forexImpFile.itemLineCnt  = itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        forexImpFile.names          = obj.getContents(FXIMP_Items, FXIMP_Header, 'NAME');
        forexImpFile.identifiers    = obj.getContents(FXIMP_Items, FXIMP_Header, 'IDENTIFIER');
        forexImpFile.dates          = obj.getContents(FXIMP_Items, FXIMP_Header, 'DatumDATE');
        forexImpFile.RelCurveFlag   = obj.getContents(FXIMP_Items, FXIMP_Header, 'RelativeCurveFlag');

        forexImpFile.moneynessDATA  = obj.getContents(FXIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSf0AXS');
        forexImpFile.termDATA       = obj.getContents(FXIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSf1AXS');
        forexImpFile.valueDATA      = obj.getContents(FXIMP_Data,  obj.headerSpecs, 'GnVolMnyTrmSfNODE');

        % +. Propagate 'fxImpVolData' to object member
        obj.csvFileNames{end+1}              = csvFile;
        obj.csvFileContents.('fxImpVolData') = forexImpFile;

        % +. Create warning if data is negative
        if      any(any(cell2mat(forexImpFile.moneynessDATA) < 0)) || ...
                any(any(cell2mat(forexImpFile.termDATA) < 0)) || ...
                any(any(cell2mat(forexImpFile.valueDATA) < 0))

            warning('STS_CM:InputDataError', 'negative data found in for ex Imp File!');
        end


    case 'scenFile'
        %% Scenario File
        % User Story: P20-1
        
        % Check if the mat file already exists
        [Dir,file,~] = fileparts(csvFile);
        
        decision = 0;
        
        if exist([Dir filesep file '.mat'],'file') == 2
            fs = dir([Dir filesep file '.mat']);
            gs = dir(csvFile);            
            decision = datenum(fs.date,'dd-mmm-yyyy HH:MM:SS') > ...
                datenum(gs.date,'dd-mmm-yyyy HH:MM:SS');            
        end
        
        if decision
            load([Dir filesep file '.mat']);
        else
            % +. Collect Files Contents & Enumerators:
            rawData         = internalModel.Utilities.csvreadCell(csvFile);
            fileHeaderLine  = rawData(1, :);
            scenProbInd     = strcmpi(fileHeaderLine, 'scenProb');
            scenVarInd      = strcmpi(fileHeaderLine, 'scenVar');
            scenValueInd    = strcmpi(fileHeaderLine, 'scenValue');
            scenNameInd     = strcmpi(fileHeaderLine, 'scenName');
            setNameInd     = strcmpi(fileHeaderLine, 'setName');
            rawData(1, :)   = [];

            % NOTE: IN CASE THIS SCENARIO FILE DOES NOT RELATE TO THE HEADER
            %       FILE, USE A FALLBACK-OPTION ON HARDCODED INDICES
            % +. In case empty indices are found, revert to hardcoded indices
            if ~any(scenProbInd)
                scenProbInd  = 4;
            end
            if ~any(scenVarInd)
                scenVarInd   = 6;
            end
            if ~any(scenValueInd)
                scenValueInd = 14;
            end
            if ~any(scenNameInd)
                scenNameInd = 3;
            end    
            if ~any(setNameInd)
                setNameInd = 2;
            end

            % Identify all headers rows
            headerInd = find(eq(cellfun(@(x)isnan(x), rawData(:, scenProbInd)), 0));

            % Assuming all scenarios have the same RF's, find number of RF's
            nr_RF   = headerInd(2)- headerInd(1) - 1;
            nr_Inst = size(rawData, 1) / (nr_RF + 1);
            data    = zeros(numel(headerInd), nr_RF);
            scenNames = cell(nr_Inst, 1);

            % +. Compile Scenario Data
            % Loop over scenarios
            for iInst = 1:nr_Inst
                % Get data for each scenario
                endInd         = (iInst*nr_RF) + iInst;
                startInd       = endInd - nr_RF + 1;
                data(iInst, :) = cell2mat(rawData((startInd:endInd), scenValueInd));
                scenNames(iInst) = rawData(startInd-1, scenNameInd);
                % We retrieve the Set Name from the line corresponding to the
                % first scenario
                if iInst == 1
                    setName = rawData(startInd-1, setNameInd);
                end
            end

            % +. Collect Relevant Data
            %    Save the headers and scenario matrix to the object
            scenFile.Headers          = rawData(2:nr_RF+1, scenVarInd);
            scenFile.ScenarioMatrix   = data;
            scenFile.Names            = scenNames;
            scenFile.SetName          = setName;
            
            % Save mat file
            save([Dir filesep file '.mat'] , 'scenFile');

        end
        % +. Propagate 'scenFile' to object member
        obj.csvFileNames{end+1}          = csvFile;
        obj.csvFileContents.('scenFile') = scenFile;


    case 'pcaFile'
        %% Scenario File
        % User Story: P20-2
        % +. Collect Files Contents & Enumerators:
        rawData               = internalModel.Utilities.csvreadCell(csvFile);
        pcaHeaderKeyword      = 'Matrix Parameter CurveSPEC';
        pcaDataKeyword        = 'Matrix Parameter CurveSPEC : Matrix Parameter Surface';
        [pcaHeaderSpecRow, ~] = find(strcmpi(obj.headerSpecs, pcaHeaderKeyword));
        [pcaDataSpecRow, ~]   = find(strcmpi(obj.headerSpecs, pcaDataKeyword));

        PCA_HeaderRef  = obj.headerSpecs(pcaHeaderSpecRow, :);
        PCA_DataRef    = obj.headerSpecs(pcaDataSpecRow,   :);
        [~, idCOL]     = find(strcmpi(PCA_HeaderRef, 'IDENTIFIER'));
        [~, currCOL]   = find(strcmpi(PCA_DataRef,   'MatrixParmSurf0AXS'));
        [~, factorCOL] = find(strcmpi(PCA_DataRef,   'MatrixParmSurf1AXS'));
        [~, valueCOL]  = find(strcmpi(PCA_DataRef,   'MatrixParmSurfNODE'));

        % +. Create IM PCA Data Structure
        rawData(1, :)  = []; 
        PCA            = struct('currency', {}, 'EV', {}, 'Term', {});
        term           = [];
        value          = [];
        iTerm          = 1;
        iCurr          = 1;

        % First line contains headers. Read second line:
        line       = rawData(1, :);
        identifier = textscan(line{idCOL}, '%s', 'Delimiter', '_');
        currency   = identifier{1}{2};

        for iLine = 2:size(rawData, 1)
            if strcmp(rawData{iLine, obj.identifierColId}, pcaHeaderKeyword)

                PCA(iCurr).currency = currency;
                PCA(iCurr).EV       = value;
                PCA(iCurr).Term     = term;
                iCurr               = iCurr + 1;

                line       = rawData(iLine, :);
                identifier = textscan(line{idCOL}, '%s', 'Delimiter', '_');
                currency   = identifier{1}{2};
                iTerm      = 1;

            else

                line   = rawData(iLine, :);
                factor = line{factorCOL} + 1;
                value(iTerm, factor) = line{valueCOL}; %#ok<AGROW>

                if eq(factor, 4)
                    term(iTerm) = line{currCOL}; %#ok<AGROW>
                    iTerm = iTerm +1;
                end
            end
        end

        % Add the very last component
        PCA(iCurr).currency = currency;
        PCA(iCurr).EV       = value;
        PCA(iCurr).Term     = term';

        % +. Propagate 'PCA' to object member
        obj.csvFileNames{end+1}         = csvFile;
        obj.csvFileContents.('pcaFile') = PCA;


    case {'bfVolVolFile', ...
          'eqVolVolFile', ...
          'reVolVolFile', ...
          'fxVolVolFile', ...
          'volatilityCapFile'}

        %% Volatility Factor Data
        % User Story: P20-3 / 20-4
        % 1 Implementation serves all 'VolVolFiles'
        % +. Collect Files Contents and Enumerators: (Skip first line)
        data            = internalModel.Utilities.csvreadCell(csvFile);
        data(1, :)      = [];
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Volatility - Moneyness/TermSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Moneyness/TermSPEC : Generic Volatility Moneyness Term Surface'));

        VOL_Header      = obj.headerSpecs(headerRow, :);
        VOL_Items       = data(itemRows, :);
        VOL_Data        = data(dataRows, :);

        % +. Determine Item Separators and Item Line Count
        itemSeparators          = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt         = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines      = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines        = itemDataStartLines + itemDataLineCnt - 1;

        volVolFile.itemLines    = [itemDataStartLines, itemDataEndLines];
        volVolFile.itemLineCnt  = itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        volVolFile.names                = obj.getContents(VOL_Items, VOL_Header, 'NAME');
        volVolFile.identifiers          = obj.getContents(VOL_Items, VOL_Header, 'IDENTIFIER');
        volVolFile.dates                = obj.getContents(VOL_Items, VOL_Header, 'DatumDATE');
        volVolFile.RelCurveFlag         = obj.getContents(VOL_Items, VOL_Header, 'RelativeCurveFlag');

        volVolFile.moneynessDATA        = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSf0AXS');
        volVolFile.termDATA             = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSf1AXS');
        volVolFile.valueDATA           = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSfNODE');
        volVolFile.csvFileName          = csvFile;

        % +. Propagate 'VolVolFile' to object member
        obj.csvFileNames{end+1}            = csvFile;
        obj.csvFileContents.(csvReference) = volVolFile;


    case {'irVolVolFile'}
        %% Volatility Factor Data
        % User Story: P20-3
        % 1 Implementation specifically for 'irVolVolFile'
        % +. Collect Files Contents and Enumerators: (Skip first line)
        data            = internalModel.Utilities.csvreadCell(csvFile);
        [headerRow, ~]  = find(strcmpi(obj.headerSpecs, 'Volatility - Term/TermSPEC'));
        [itemRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Term/TermSPEC'));
        [dataRows, ~]   = find(strcmpi(data(:, idCol),  'Volatility - Term/TermSPEC : Generic Volatility Term Term Surface'));

        VOL_Header      = obj.headerSpecs(headerRow, :);
        VOL_Items       = data(itemRows, :);
        VOL_Data        = data(dataRows, :);

        % +. Determine Item Separators and Item Line Count
        itemSeparators          = [itemRows; (size(data, 1)+1)];
        itemDataLineCnt         = (itemSeparators(2:end)  - itemSeparators(1:end-1)) - 1;
        itemDataStartLines      = cumsum(itemDataLineCnt) - itemDataLineCnt + 1;
        itemDataEndLines        = itemDataStartLines + itemDataLineCnt - 1;

        volVolFile.itemLines    = [itemDataStartLines, itemDataEndLines];
        volVolFile.itemLineCnt  = itemDataLineCnt;

        % +. Collect Column Identifiers & Relevant Data
        volVolFile.names        = obj.getContents(VOL_Items, VOL_Header, 'NAME');
        volVolFile.identifiers  = obj.getContents(VOL_Items, VOL_Header, 'IDENTIFIER');
        volVolFile.dates        = obj.getContents(VOL_Items, VOL_Header, 'DatumDATE');
        volVolFile.RelCurveFlag = obj.getContents(VOL_Items, VOL_Header, 'RelativeCurveFlag');

        volVolFile.GnVolMnyTrmSf0AXS = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSf0AXS');
        volVolFile.GnVolMnyTrmSf1AXS = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSf1AXS');
        volVolFile.GnVolMnyTrmSfNODE = obj.getContents(VOL_Data, obj.headerSpecs, 'GnVolMnyTrmSfNODE');
        volVolFile.csvFileName       = csvFile;

        % +. Propagate 'VolVolFile' to object member
        obj.csvFileNames{end+1}            = csvFile;
        obj.csvFileContents.(csvReference) = volVolFile;


    case 'instFile'
        %% Instruments File
        % User Story: P20-7a
        % Collect Complete File: processing is done by 'processInstrData' method
        % +. Collect Files Contents and Enumerators:
        data = internalModel.Utilities.csvreadCell(csvFile);

        % +. Propagate 'instFile' to object member
        obj.csvFileNames{end+1}          = csvFile;
        obj.csvFileContents.('instFile') = data;

end

end % #processCsvFile
