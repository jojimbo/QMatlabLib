function makePruFiles(session_date, scenarioType, whatIfFlag, riskDrivers, scenarioSet, simulationOutputs, nBatches, pruFilesPath, isInMemory)
    % prepare inputs to Pru convertor
    tic;
    fprintf('makePruFiles - Msg: preparing inputs \n');    
    [fileID, dates, riskUniverse, detValues, stoValues, noRiskValues, shockDate, shockValues] = makePruInputs(session_date, riskDrivers, scenarioSet, simulationOutputs);
    toc;
    % make header files
    % NOTE: this would not work unless risk factor names are in the
    % standard Pru format format!
    fprintf('makePruFiles - Msg: writing header file \n');
    tic;
    makePruHeaders(fileID,riskDrivers, pruFilesPath);
    toc;
    fprintf('makePruFiles - Msg: writing data files \n');
    % create Pru aggregator files
    tic;
    prursg.Aggregator.makePruAggregatorFiles(fileID, scenarioType, whatIfFlag, dates, riskUniverse, detValues, stoValues, noRiskValues, nBatches, scenarioSet, shockDate, shockValues, pruFilesPath, isInMemory);
    toc;
end


function [fileID, dates, riskUniverse, detValues, stoValues, noRiskValues, shockDate shockValues] = makePruInputs(session_date, riskDrivers, scenarioSet, simulationOutputs)
    fileID = 'Test_Pru_output_';
    % pull out set of timestep dates
    detScenarios = scenarioSet.getDeterministicScenarios();
    dates = cell(length(detScenarios),1);
    for i = 1:length(detScenarios)
        dates{i} = datestr(prursg.Util.DateUtil.ReplaceLeapDate(detScenarios(i).date),24);
    end
    % get size of expanded risk universe
    numSubRisks = zeros(length(riskDrivers),1);
    for i = 1:length(riskDrivers)
        numSubRisks(i) =detScenarios(end).expandedUniverse(riskDrivers(i).name).getSize();
    end
    nSubRisks = sum(numSubRisks);
    riskUniverse = cell(3,nSubRisks);
    k = 0;
    for i = 1:length(riskDrivers)
        expandedNames = detScenarios(end).expandedUniverse(riskDrivers(i).name).getExpandedNames();
        for j = 1:numSubRisks(i)
        k = k + 1;
        riskUniverse{1,k} = riskDrivers(i).name;
        riskUniverse{2,k} = [riskDrivers(i).name expandedNames{j}];
            switch riskDrivers(i).pru_type
                case 'Credit'
                    riskUniverse{3,k} = 'creditspreads';
                case 'YC'
                    riskUniverse{3,k} = 'yieldcurves';
                case 'index'
                    riskUniverse{3,k} = 'indices';
                case 'Index'
                    riskUniverse{3,k} = 'indices';
                case 'Insurance'
                    riskUniverse{3,k} = 'indices';
                case 'FX'
                    riskUniverse{3,k} = 'fxrates';
                case 'Vol'
                    riskUniverse{3,k} = 'indexvols';
                case 'Svol'
                    riskUniverse{3,k} = 'swaptionvols';
            end
        end
    end
    
    detValues = [];
    shockValues = [];
    shockDate = [];
    stoValues = [];  
    noRiskValues = [];
    
    
    
    % organise the deterministic values
    for j = 1:length(detScenarios)
        detValuesNew = [];
        for i = 1:length(riskDrivers)
            newValues = detScenarios(j).expandedUniverse(riskDrivers(i).name).getFlatData(1);
            detValuesNew = [detValuesNew newValues]; %#ok<AGROW>
        end
        detValues = [detValues ; detValuesNew];
    end
    
    noRiskScenario = scenarioSet.noRiskScenario;
    if ~isempty(noRiskScenario)
        noRiskValuesNew = [];
        for i = 1:length(riskDrivers)
            newValues = noRiskScenario.expandedUniverse(riskDrivers(i).name).getFlatData(1);
            noRiskValuesNew = [noRiskValuesNew newValues]; %#ok<AGROW>
        end
        noRiskValues = [noRiskValues ; noRiskValuesNew];
    end
    
    %retrieve shocked base scenario.
    shockScenario = scenarioSet.getShockedBaseScenario();
    if ~isempty(shockScenario)
        shockDate = datestr(prursg.Util.DateUtil.ReplaceLeapDate(shockScenario.date), 24);
        
        shockValuesNew = [];
        for i = 1:length(riskDrivers)
            newValues = shockScenario.expandedUniverse(riskDrivers(i).name).getFlatData(1);
            shockValuesNew = [shockValuesNew newValues]; %#ok<AGROW>
        end
        shockValues = [shockValues ; shockValuesNew];
    end
    
    % stochastic values including no risk scenario.
    stoValues = simulationOutputs;
    
end

function makePruHeaders(fileID,riskDrivers, pruFilesPath)
% generates pru aggregator header files (.xlsx file)
    pruTypes = cell(length(riskDrivers),1);
    for i = 1:length(riskDrivers)
        switch riskDrivers(i).pru_type
            case 'Credit'
                pruTypes{i} = 'creditspreads';
            case 'YC'
                pruTypes{i} = 'yieldcurves';
            case 'index'
                pruTypes{i} = 'indices';
            case 'Index'
                pruTypes{i} = 'indices';
            case 'Insurance'
                pruTypes{i} = 'indices';
            case 'FX'
                pruTypes{i} = 'fxrates';
            case 'Vol'
                pruTypes{i} = 'indexvols';
            case 'Svol'
                pruTypes{i} = 'swaptionvols';
        end
    end
    
    % create header row of each sheet
    
    %indicesHeader = [{'Indices'} {'Type'} {'Risk Group'}];
    %ycHeader = [{'Name'} {'Currency'} {'Risk Group'}];
    %creditHeader = [{'Name'} {'Currency'} {'Risk Group'}];
    %indexvolHeader = [{'Indices'} {'Risk Group'}];
    %swaptionHeader = [{'Name'} {'Currency'} {'Risk Group'}];
    %fxHeader = [{'Currncies'} {'Risk Group'}];
    
    shrednames = getShredNames(riskDrivers);    
    indicesHeader = [{'Indices'} {'Type'} shrednames];
    ycHeader = [{'Name'} {'Currency'} shrednames];
    creditHeader = [{'Name'} {'Currency'} shrednames];
    indexvolHeader = [{'Indices'} shrednames];
    swaptionHeader = [{'Name'} {'Currency'} shrednames];
    fxHeader = [{'Currncies'} shrednames];
    
    % adding data to each header sheet
    for i = 1:length(pruTypes)
        if strcmp(pruTypes{i},'indices')
            %indicesHeader = [indicesHeader ; [{riskDrivers(i).name} {'absolute'} {riskDrivers(i).risk_group}]];
            indicesHeader = [indicesHeader ; [{riskDrivers(i).name} {'absolute'} RiskGroups(riskDrivers(i))]];
        end
        if strcmp(pruTypes{i},'yieldcurves')
            riskFullName = riskDrivers(i).name;
            ccyName = riskFullName(1:3);
            riskName = riskFullName(5:end);
            %ycHeader = [ycHeader ; [{riskName} {ccyName} {riskDrivers(i).risk_group}]];
            ycHeader = [ycHeader ; [{riskName} {ccyName} RiskGroups(riskDrivers(i))]];
        end
        if strcmp(pruTypes{i},'creditspreads')
            riskFullName = riskDrivers(i).name;
            ccyName = riskFullName(1:3);
            riskName = riskFullName(5:end);
            %creditHeader = [creditHeader ; [{riskName} {ccyName} {riskDrivers(i).risk_group}]];
            creditHeader = [creditHeader ; [{riskName} {ccyName} RiskGroups(riskDrivers(i))]];
        end
        if strcmp(pruTypes{i},'indexvols')
            %indexvolHeader = [indexvolHeader ; [{riskDrivers(i).name} {riskDrivers(i).risk_group}]];
            indexvolHeader = [indexvolHeader ; [{riskDrivers(i).name} RiskGroups(riskDrivers(i))]];
        end
        if strcmp(pruTypes{i},'swaptionvols')
            riskFullName = riskDrivers(i).name;
            ccyName = riskFullName(1:3);
            riskName = riskFullName(5:7);
            %swaptionHeader = [swaptionHeader ; [{riskName} {ccyName} {riskDrivers(i).risk_group}]];
            swaptionHeader = [swaptionHeader ; [{riskName} {ccyName} RiskGroups(riskDrivers(i))]];
        end
        if strcmp(pruTypes{i},'fxrates')
            riskFullName = riskDrivers(i).name;
            ccyName = riskFullName(1:3);
            %fxHeader = [fxHeader ; [{ccyName} {riskDrivers(i).risk_group}]];
            fxHeader = [fxHeader ; [{ccyName} RiskGroups(riskDrivers(i))]];
            % adds the riskDriver name and the riskGroups for the current riskDriver
        end
    end
    
    % override "IndexVols"    
    for i1 = 1:size(indexvolHeader,1)
        % directly map XXX_equityvol_YYY risk driver onto XXX_equitycri_YYY
        % risk driver as requested by actuaries
        if i1 > 1
            tempName = indexvolHeader{i1,1};
            temp = strfind(tempName,'_');
            tempName = [tempName(1:temp(1)-1) '_equitytri_' tempName(temp(2)+1:end)];
            indexvolHeader{i1,1} = tempName;
        end        
    end    
    
    % write header info into excel spreadsheet.
    filePath = fullfile(pruFilesPath, [fileID 'definition.xls']);
    SaveHeaders(filePath, indicesHeader, ycHeader, creditHeader, indexvolHeader, swaptionHeader, fxHeader);                      
    
end

% puts together the Risk Groups columns values for a particular RiskDriver
% NOTE THAT IT RETURNS A CELL ARRAY!
function riskGroups = RiskGroups(riskDriver)
    riskGroups = [];
    for i=1:length(riskDriver.risk_groups)
        riskGroups = [riskGroups {riskDriver.risk_groups(i).group}];
    end
end

% returns the names of the defined shreds in the input XML file
% NOTE THAT IT RETURNS A CELL ARRAY!
function shrednames = getShredNames(riskDrivers)
    shrednames = [];
    for i=1:length(riskDrivers(1).risk_groups)
    % We just take the first risk driver because we are expecting the same
    % number of risk_groups (shrednames) for every risk driver, we are not
    % checking if the input XML file is wrong in that way
        shrednames = [shrednames {riskDrivers(1).risk_groups(i).shredname}];
    end
end


% save header information in excel format.
function SaveHeaders(filePath, indicesHeader, ycHeader, creditHeader, indexvolHeader, swaptionHeader, fxHeader)
    import java.io.FileOutputStream;
    import org.apache.poi.hssf.usermodel.HSSFWorkbook;
    
    wb = HSSFWorkbook();
    out = FileOutputStream(filePath);

    WriteWorkSheet(wb, 'Indices', indicesHeader);
    WriteWorkSheet(wb, 'yieldCurves', ycHeader);
    WriteWorkSheet(wb, 'creditSpreads', creditHeader);
    WriteWorkSheet(wb, 'IndexVols', indexvolHeader);
    WriteWorkSheet(wb, 'swaptionVols', swaptionHeader);
    WriteWorkSheet(wb, 'Currencies', fxHeader);
    
    wb.write(out);
    out.close();
    
end

% add a worksheet to the given workbook.
function WriteWorkSheet(workbook, sheetName, data)

    import org.apache.poi.hssf.usermodel.HSSFWorkbook;
    import org.apache.poi.hssf.usermodel.HSSFSheet;
    import org.apache.poi.hssf.usermodel.HSSFRow;
    import org.apache.poi.hssf.usermodel.HSSFCell;
            
    sheet = workbook.createSheet(sheetName);        
    if ~isempty(data)
        nRows = size(data, 1);
        nCols = size(data, 2);
        for i = 1:nRows
            row = sheet.createRow(i - 1);            
            for j = 1:nCols
                cell = row.createCell(j -1);
                if isempty(data{i, j})
                    cell.setCellValue('');    
                else
                    cell.setCellValue(data{i, j});    
                end
                
            end
        end
    end
end